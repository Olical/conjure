-- [nfnl] fnl/conjure/client/clojure/nrepl/server.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local debugger = autoload("conjure.client.clojure.nrepl.debugger")
local extract = autoload("conjure.extract")
local log = autoload("conjure.log")
local nrepl = autoload("conjure.remote.nrepl")
local state = autoload("conjure.client.clojure.nrepl.state")
local str = autoload("conjure.aniseed.string")
local timer = autoload("conjure.timer")
local ui = autoload("conjure.client.clojure.nrepl.ui")
local uuid = autoload("conjure.uuid")
local fs = autoload("conjure.nfnl.fs")
local function with_conn_or_warn(f, opts)
  local conn = state.get("conn")
  if conn then
    return f(conn)
  else
    if not a.get(opts, "silent?") then
      log.append({"; No connection"})
    else
    end
    if a.get(opts, "else") then
      return opts["else"]()
    else
      return nil
    end
  end
end
local function connected_3f()
  if state.get("conn") then
    return true
  else
    return false
  end
end
local function send(msg, cb)
  local function _6_(conn)
    return conn.send(msg, cb)
  end
  return with_conn_or_warn(_6_)
end
local function display_conn_status(status)
  local function _7_(conn)
    local function _8_()
      if conn.port_file_path then
        return str.join({": ", conn.port_file_path})
      else
        return nil
      end
    end
    return log.append({str.join({"; ", conn.host, ":", conn.port, " (", status, ")", _8_()})}, {["break?"] = true})
  end
  return with_conn_or_warn(_7_)
end
local function disconnect()
  local function _9_(conn)
    conn.destroy()
    display_conn_status("disconnected")
    return a.assoc(state.get(), "conn", nil)
  end
  return with_conn_or_warn(_9_)
end
local function close_session(session, cb)
  return send({op = "close", session = a.get(session, "id")}, cb)
end
local function assume_session(session)
  a.assoc(state.get("conn"), "session", a.get(session, "id"))
  return log.append({str.join({"; Assumed session: ", session.str()})}, {["break?"] = true})
end
local function un_comment(code)
  if code then
    return string.gsub(code, "^#_", "")
  else
    return nil
  end
end
local function print_opts()
  local print_fn = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_function"})
  if (config["get-in"]({"client", "clojure", "nrepl", "eval", "pretty_print"}) and print_fn) then
    return {["nrepl.middleware.print/print"] = print_fn, ["nrepl.middleware.print/options"] = {associative = 1, level = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "level"}) or nil), length = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "length"}) or nil), ["right-margin"] = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "right_margin"}) or nil)}, ["nrepl.middleware.print/quota"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_quota"}), ["nrepl.middleware.print/buffer-size"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_buffer_size"})}
  else
    return nil
  end
end
local function eval(opts, cb)
  local function _12_(_)
    local _13_
    do
      local tmp_3_ = a["get-in"](opts, {"range", "start", 2})
      if (nil ~= tmp_3_) then
        _13_ = a.inc(tmp_3_)
      else
        _13_ = nil
      end
    end
    return send(a.merge({op = "eval", ns = opts.context, code = un_comment(opts.code), file = opts["file-path"], line = a["get-in"](opts, {"range", "start", 1}), column = _13_, session = opts.session}, print_opts()), cb)
  end
  return with_conn_or_warn(_12_)
end
local function load_file(opts, cb)
  local function _15_(_)
    return send(a.merge({op = "load-file", file = opts.code, ["file-name"] = fs.filename(opts["file-path"]), ["file-path"] = opts["file-path"], session = opts.session}, print_opts()), cb)
  end
  return with_conn_or_warn(_15_)
end
local function with_session_ids(cb)
  local function _16_(_)
    local function _17_(msg)
      local sessions = a.get(msg, "sessions")
      if ("table" == type(sessions)) then
        table.sort(sessions)
      else
      end
      return cb(sessions)
    end
    return send({op = "ls-sessions", session = "no-session"}, _17_)
  end
  return with_conn_or_warn(_16_)
end
local function pretty_session_type(st)
  return a.get({clj = "Clojure", cljs = "ClojureScript", cljr = "ClojureCLR"}, st, "Unknown https://github.com/Olical/conjure/wiki/Frequently-asked-questions#what-does-unknown-mean-in-the-log-when-connecting-to-a-clojure-nrepl")
end
local function session_type(id, cb)
  local state0 = {["done?"] = false}
  local function _19_()
    if not state0["done?"] then
      state0["done?"] = true
      return cb("unknown")
    else
      return nil
    end
  end
  timer.defer(_19_, 200)
  local function _21_(msgs)
    local st
    local function _22_(_241)
      return a.get(_241, "value")
    end
    st = a.some(_22_, msgs)
    if not state0["done?"] then
      state0["done?"] = true
      local function _23_()
        if st then
          return str.trim(st)
        else
          return nil
        end
      end
      return cb(_23_())
    else
      return nil
    end
  end
  return send({op = "eval", code = ("#?(" .. str.join(" ", {":clj 'clj", ":cljs 'cljs", ":cljr 'cljr", ":default 'unknown"}) .. ")"), session = id}, nrepl["with-all-msgs-fn"](_21_))
end
local function enrich_session_id(id, cb)
  local function _25_(st)
    local t = {id = id, type = st, ["pretty-type"] = pretty_session_type(st), name = uuid.pretty(id)}
    local function _26_()
      return str.join({t.name, " (", t["pretty-type"], ")"})
    end
    a.assoc(t, "str", _26_)
    return cb(t)
  end
  return session_type(id, _25_)
end
local function with_sessions(cb)
  local function _27_(sess_ids)
    local rich = {}
    local total = a.count(sess_ids)
    if (0 == total) then
      return cb({})
    else
      local function _28_(id)
        log.dbg("with-sessions id for enrichment", id)
        if id then
          local function _29_(t)
            table.insert(rich, t)
            if (total == a.count(rich)) then
              local function _30_(_241, _242)
                return (a.get(_241, "name") < a.get(_242, "name"))
              end
              table.sort(rich, _30_)
              return cb(rich)
            else
              return nil
            end
          end
          return enrich_session_id(id, _29_)
        else
          return nil
        end
      end
      return a["run!"](_28_, sess_ids)
    end
  end
  return with_session_ids(_27_)
end
local function clone_session(session)
  local function _34_(msgs)
    local session_id
    local function _35_(_241)
      return a.get(_241, "new-session")
    end
    session_id = a.some(_35_, msgs)
    log.dbg("clone-session id for enrichment", id)
    if session_id then
      return enrich_session_id(session_id, assume_session)
    else
      return nil
    end
  end
  return send({op = "clone", session = a.get(session, "id"), ["client-name"] = "Conjure"}, nrepl["with-all-msgs-fn"](_34_))
end
local function assume_or_create_session()
  a.assoc(state.get("conn"), "session", nil)
  local function _37_(sessions)
    if a["empty?"](sessions) then
      return clone_session()
    else
      return assume_session(a.first(sessions))
    end
  end
  return with_sessions(_37_)
end
local function eval_preamble(cb)
  local queue_size = config["get-in"]({"client", "clojure", "nrepl", "tap", "queue_size"})
  local pretty_print_test_failures_3f = config["get-in"]({"client", "clojure", "nrepl", "test", "pretty_print_test_failures"})
  local _39_
  if pretty_print_test_failures_3f then
    _39_ = {"(defmethod clojure.test/report :fail [m]", "  (clojure.test/with-test-out", "    (clojure.test/inc-report-counter :fail)", "    (println \"\nFAIL in\" (clojure.test/testing-vars-str m))", "    (when (seq clojure.test/*testing-contexts*) (println (clojure.test/testing-contexts-str)))", "    (when-let [message (:message m)] (println message))", "    (print \"expected:\" (with-out-str (prn (:expected m))))", "    (print \"  actual:\" (with-out-str (prn (:actual m))))", "    (when (and (seq? (:actual m))", "               (= #'clojure.core/not (resolve (first (:actual m))))", "               (seq? (second (:actual m)))", "               (= #'clojure.core/= (resolve (first (second (:actual m)))))", "               (= 3 (count (second (:actual m)))))", "      (let [[missing extra _] (clojure.data/diff (second (second (:actual m))) (last (second (:actual m))))", "            missing-str (with-out-str (pp/pprint missing))", "            missing-lines (clojure.string/split-lines missing-str)", "            extra-str (with-out-str (pp/pprint extra))", "            extra-lines (clojure.string/split-lines extra-str)]", "        (when (some? missing) (doseq [m missing-lines] (println \"- \" m)))", "        (when (some? extra) (doseq [e extra-lines] (println \"+ \" e)))))))"}
  else
    _39_ = nil
  end
  local function _41_()
    if cb then
      return nrepl["with-all-msgs-fn"](cb)
    else
      return nil
    end
  end
  return send({op = "eval", code = str.join("\n", a.concat({"(create-ns 'conjure.internal)", "(intern 'conjure.internal 'initial-ns (symbol (str *ns*)))", "(ns conjure.internal", "  (:require [clojure.pprint :as pp] [clojure.test] [clojure.data] [clojure.string]))", "(when-not (find-ns 'cider.nrepl.pprint)", "  (create-ns 'cider.nrepl.pprint)", "  (intern 'cider.nrepl.pprint 'pprint", "    (fn pprint [val w opts]", "      (apply pp/write val", "        (mapcat identity (assoc opts :stream w))))))", "(defn bounded-conj [queue x limit]", "  (->> x (conj queue) (take limit)))", ("(def tap-queue-size " .. queue_size .. ")"), "(defonce tap-queue! (atom (list)))", "(defonce enqueue-tap!", "  (fn [x] (swap! tap-queue! bounded-conj x tap-queue-size)))", "(when (resolve 'add-tap)", "  (remove-tap enqueue-tap!)", "  (add-tap enqueue-tap!))", "(defn dump-tap-queue! []", "  (reverse (first (reset-vals! tap-queue! (list)))))"}, _39_, {"(in-ns initial-ns)"}))}, _41_())
end
local function capture_describe()
  local function _42_(msg)
    return a.assoc(state.get("conn"), "describe", msg)
  end
  return send({op = "describe"}, _42_)
end
local function with_conn_and_ops_or_warn(op_names, f, opts)
  local function _43_(conn)
    local found_ops
    local function _44_(acc, op)
      if a["get-in"](conn, {"describe", "ops", op}) then
        return a.assoc(acc, op, true)
      else
        return acc
      end
    end
    found_ops = a.reduce(_44_, {}, op_names)
    if not a["empty?"](found_ops) then
      return f(conn, found_ops)
    else
      if not a.get(opts, "silent?") then
        log.append({"; None of the required operations are supported by this nREPL.", "; Ensure your nREPL is up to date.", "; Consider installing or updating the CIDER middleware.", "; https://docs.cider.mx/cider-nrepl/usage.html"})
      else
      end
      if a.get(opts, "else") then
        return opts["else"]()
      else
        return nil
      end
    end
  end
  return with_conn_or_warn(_43_, opts)
end
local function handle_input_request(msg)
  return send({op = "stdin", stdin = ((extract.prompt("Input required: ") or "") .. "\n"), session = msg.session})
end
local function connect(_49_)
  local host = _49_["host"]
  local port = _49_["port"]
  local cb = _49_["cb"]
  local port_file_path = _49_["port_file_path"]
  local connect_opts = _49_["connect-opts"]
  if state.get("conn") then
    disconnect()
  else
  end
  local function _51_(err)
    display_conn_status(err)
    return disconnect()
  end
  local function _52_()
    display_conn_status("connected")
    capture_describe()
    assume_or_create_session()
    return eval_preamble(cb)
  end
  local function _53_(err)
    if err then
      return display_conn_status(err)
    else
      return disconnect()
    end
  end
  local function _55_(msg)
    if msg.status["unknown-session"] then
      log.append({"; Unknown session, correcting"})
      assume_or_create_session()
    else
    end
    if msg.status["namespace-not-found"] then
      return log.append({str.join({"; Namespace not found: ", msg.ns})})
    else
      return nil
    end
  end
  local function _58_(msg)
    if msg.status["need-input"] then
      client.schedule(handle_input_request, msg)
    else
    end
    if msg.status["need-debug-input"] then
      return client.schedule(debugger["handle-input-request"], msg)
    else
      return nil
    end
  end
  local function _61_(msg)
    return ui["display-result"](msg)
  end
  return a.assoc(state.get(), "conn", a["merge!"](nrepl.connect(a.merge({host = host, port = port, ["on-failure"] = _51_, ["on-success"] = _52_, ["on-error"] = _53_, ["on-message"] = _55_, ["side-effect-callback"] = _58_, ["default-callback"] = _61_}, connect_opts)), {["seen-ns"] = {}, port_file_path = port_file_path}))
end
return {["assume-or-create-session"] = assume_or_create_session, ["assume-session"] = assume_session, ["clone-session"] = clone_session, ["close-session"] = close_session, connect = connect, ["connected?"] = connected_3f, disconnect = disconnect, ["enrich-session-id"] = enrich_session_id, eval = eval, ["handle-input-request"] = handle_input_request, ["pretty-session-type"] = pretty_session_type, send = send, ["session-type"] = session_type, ["un-comment"] = un_comment, ["with-conn-and-ops-or-warn"] = with_conn_and_ops_or_warn, ["with-conn-or-warn"] = with_conn_or_warn, ["with-sessions"] = with_sessions, ["load-file"] = load_file}
