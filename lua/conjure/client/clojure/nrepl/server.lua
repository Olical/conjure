local _2afile_2a = "fnl/conjure/client/clojure/nrepl/server.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.server"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, client, config, debugger, extract, log, nrepl, state, str, timer, ui, uuid = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.client.clojure.nrepl.debugger"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.remote.nrepl"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.timer"), autoload("conjure.client.clojure.nrepl.ui"), autoload("conjure.uuid")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["debugger"] = debugger
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nrepl"] = nrepl
_2amodule_locals_2a["state"] = state
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["timer"] = timer
_2amodule_locals_2a["ui"] = ui
_2amodule_locals_2a["uuid"] = uuid
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
_2amodule_2a["with-conn-or-warn"] = with_conn_or_warn
local function connected_3f()
  if state.get("conn") then
    return true
  else
    return false
  end
end
_2amodule_2a["connected?"] = connected_3f
local function send(msg, cb)
  local function _5_(conn)
    return conn.send(msg, cb)
  end
  return with_conn_or_warn(_5_)
end
_2amodule_2a["send"] = send
local function display_conn_status(status)
  local function _6_(conn)
    local function _7_()
      if conn.port_file_path then
        return str.join({": ", conn.port_file_path})
      else
        return nil
      end
    end
    return log.append({str.join({"; ", conn.host, ":", conn.port, " (", status, ")", _7_()})}, {["break?"] = true})
  end
  return with_conn_or_warn(_6_)
end
_2amodule_locals_2a["display-conn-status"] = display_conn_status
local function disconnect()
  local function _8_(conn)
    conn.destroy()
    display_conn_status("disconnected")
    return a.assoc(state.get(), "conn", nil)
  end
  return with_conn_or_warn(_8_)
end
_2amodule_2a["disconnect"] = disconnect
local function close_session(session, cb)
  return send({op = "close", session = a.get(session, "id")}, cb)
end
_2amodule_2a["close-session"] = close_session
local function assume_session(session)
  a.assoc(state.get("conn"), "session", a.get(session, "id"))
  return log.append({str.join({"; Assumed session: ", session.str()})}, {["break?"] = true})
end
_2amodule_2a["assume-session"] = assume_session
local function un_comment(code)
  if code then
    return string.gsub(code, "^#_", "")
  else
    return nil
  end
end
_2amodule_2a["un-comment"] = un_comment
local function eval(opts, cb)
  local function _10_(_)
    local _12_
    do
      local _11_ = a["get-in"](opts, {"range", "start", 2})
      if (nil ~= _11_) then
        _12_ = a.inc(_11_)
      else
        _12_ = _11_
      end
    end
    local _14_
    if config["get-in"]({"client", "clojure", "nrepl", "eval", "pretty_print"}) then
      _14_ = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_function"})
    else
      _14_ = nil
    end
    return send({op = "eval", ns = opts.context, code = un_comment(opts.code), file = opts["file-path"], line = a["get-in"](opts, {"range", "start", 1}), column = _12_, session = opts.session, ["nrepl.middleware.print/options"] = {associative = 1, level = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "level"}) or nil), length = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "length"}) or nil)}, ["nrepl.middleware.print/quota"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_quota"}), ["nrepl.middleware.print/buffer-size"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_buffer_size"}), ["nrepl.middleware.print/print"] = _14_}, cb)
  end
  return with_conn_or_warn(_10_)
end
_2amodule_2a["eval"] = eval
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
_2amodule_locals_2a["with-session-ids"] = with_session_ids
local function pretty_session_type(st)
  return a.get({clj = "Clojure", cljs = "ClojureScript", cljr = "ClojureCLR"}, st, "Unknown https://conjure.fun/unknown-env")
end
_2amodule_2a["pretty-session-type"] = pretty_session_type
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
_2amodule_2a["session-type"] = session_type
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
_2amodule_2a["enrich-session-id"] = enrich_session_id
local function with_sessions(cb)
  local function _27_(sess_ids)
    local rich = {}
    local total = a.count(sess_ids)
    if (0 == total) then
      return cb({})
    else
      local function _28_(id)
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
      end
      return a["run!"](_28_, sess_ids)
    end
  end
  return with_session_ids(_27_)
end
_2amodule_2a["with-sessions"] = with_sessions
local function clone_session(session)
  local function _33_(msgs)
    local function _34_(_241)
      return a.get(_241, "new-session")
    end
    return enrich_session_id(a.some(_34_, msgs), assume_session)
  end
  return send({op = "clone", session = a.get(session, "id")}, nrepl["with-all-msgs-fn"](_33_))
end
_2amodule_2a["clone-session"] = clone_session
local function assume_or_create_session()
  a.assoc(state.get("conn"), "session", nil)
  local function _35_(sessions)
    if a["empty?"](sessions) then
      return clone_session()
    else
      return assume_session(a.first(sessions))
    end
  end
  return with_sessions(_35_)
end
_2amodule_2a["assume-or-create-session"] = assume_or_create_session
local function eval_preamble(cb)
  local function _37_()
    if cb then
      return nrepl["with-all-msgs-fn"](cb)
    else
      return nil
    end
  end
  return send({op = "eval", code = ("(ns conjure.internal" .. "  (:require [clojure.pprint :as pp]))" .. "(defn pprint [val w opts]" .. "  (apply pp/write val" .. "    (mapcat identity (assoc opts :stream w))))")}, _37_())
end
_2amodule_locals_2a["eval-preamble"] = eval_preamble
local function capture_describe()
  local function _38_(msg)
    return a.assoc(state.get("conn"), "describe", msg)
  end
  return send({op = "describe"}, _38_)
end
_2amodule_locals_2a["capture-describe"] = capture_describe
local function with_conn_and_ops_or_warn(op_names, f, opts)
  local function _39_(conn)
    local found_ops
    local function _40_(acc, op)
      if a["get-in"](conn, {"describe", "ops", op}) then
        return a.assoc(acc, op, true)
      else
        return acc
      end
    end
    found_ops = a.reduce(_40_, {}, op_names)
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
  return with_conn_or_warn(_39_, opts)
end
_2amodule_2a["with-conn-and-ops-or-warn"] = with_conn_and_ops_or_warn
local function handle_input_request(msg)
  return send({op = "stdin", stdin = ((extract.prompt("Input required: ") or "") .. "\n"), session = msg.session})
end
_2amodule_2a["handle-input-request"] = handle_input_request
local function connect(_45_)
  local _arg_46_ = _45_
  local host = _arg_46_["host"]
  local port = _arg_46_["port"]
  local cb = _arg_46_["cb"]
  local port_file_path = _arg_46_["port_file_path"]
  local connect_opts = _arg_46_["connect-opts"]
  if state.get("conn") then
    disconnect()
  else
  end
  local function _48_(err)
    display_conn_status(err)
    return disconnect()
  end
  local function _49_()
    display_conn_status("connected")
    capture_describe()
    assume_or_create_session()
    return eval_preamble(cb)
  end
  local function _50_(err)
    if err then
      return display_conn_status(err)
    else
      return disconnect()
    end
  end
  local function _52_(msg)
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
  local function _55_(msg)
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
  local function _58_(msg)
    return ui["display-result"](msg)
  end
  return a.assoc(state.get(), "conn", a["merge!"](nrepl.connect(a.merge({host = host, port = port, ["on-failure"] = _48_, ["on-success"] = _49_, ["on-error"] = _50_, ["on-message"] = _52_, ["side-effect-callback"] = _55_, ["default-callback"] = _58_}, connect_opts)), {["seen-ns"] = {}, port_file_path = port_file_path}))
end
_2amodule_2a["connect"] = connect
return _2amodule_2a