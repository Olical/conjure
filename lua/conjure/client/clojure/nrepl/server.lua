local _0_0 = nil
do
  local name_0_ = "conjure.client.clojure.nrepl.server"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.config"), require("conjure.log"), require("conjure.remote.nrepl"), require("conjure.client.clojure.nrepl.state"), require("conjure.aniseed.string"), require("conjure.timer"), require("conjure.client.clojure.nrepl.ui"), require("conjure.uuid")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", config = "conjure.config", log = "conjure.log", nrepl = "conjure.remote.nrepl", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", timer = "conjure.timer", ui = "conjure.client.clojure.nrepl.ui", uuid = "conjure.uuid"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local config = _1_[2]
local log = _1_[3]
local nrepl = _1_[4]
local state = _1_[5]
local str = _1_[6]
local timer = _1_[7]
local ui = _1_[8]
local uuid = _1_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl.server"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local with_conn_or_warn = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function with_conn_or_warn0(f, opts)
      local conn = state.get("conn")
      if conn then
        return f(conn)
      else
        if not a.get(opts, "silent?") then
          log.append({"; No connection"})
        end
        if a.get(opts, "else") then
          return opts["else"]()
        end
      end
    end
    v_0_0 = with_conn_or_warn0
    _0_0["with-conn-or-warn"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["with-conn-or-warn"] = v_0_
  with_conn_or_warn = v_0_
end
local connected_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connected_3f0()
      if state.get("conn") then
        return true
      else
        return false
      end
    end
    v_0_0 = connected_3f0
    _0_0["connected?"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connected?"] = v_0_
  connected_3f = v_0_
end
local send = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function send0(msg, cb)
      local function _3_(conn)
        return conn.send(msg, cb)
      end
      return with_conn_or_warn(_3_)
    end
    v_0_0 = send0
    _0_0["send"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["send"] = v_0_
  send = v_0_
end
local display_conn_status = nil
do
  local v_0_ = nil
  local function display_conn_status0(status)
    local function _3_(conn)
      return log.append({("; " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
    end
    return with_conn_or_warn(_3_)
  end
  v_0_ = display_conn_status0
  _0_0["aniseed/locals"]["display-conn-status"] = v_0_
  display_conn_status = v_0_
end
local disconnect = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function disconnect0()
      local function _3_(conn)
        conn.destroy()
        display_conn_status("disconnected")
        return a.assoc(state.get(), "conn", nil)
      end
      return with_conn_or_warn(_3_)
    end
    v_0_0 = disconnect0
    _0_0["disconnect"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["disconnect"] = v_0_
  disconnect = v_0_
end
local close_session = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function close_session0(session, cb)
      return send({op = "close", session = a.get(session, "id")}, cb)
    end
    v_0_0 = close_session0
    _0_0["close-session"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["close-session"] = v_0_
  close_session = v_0_
end
local assume_session = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function assume_session0(session)
      a.assoc(state.get("conn"), "session", a.get(session, "id"))
      return log.append({("; Assumed session: " .. session.str())}, {["break?"] = true})
    end
    v_0_0 = assume_session0
    _0_0["assume-session"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["assume-session"] = v_0_
  assume_session = v_0_
end
local eval = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval0(opts, cb)
      local function _3_(_)
        local _4_
        if config["get-in"]({"client", "clojure", "nrepl", "eval", "pretty_print"}) then
          _4_ = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_function"})
        else
        _4_ = nil
        end
        local _7_
        do
          local _6_0 = a["get-in"](opts, {"range", "start", 2})
          if _6_0 then
            _7_ = a.inc(_6_0)
          else
            _7_ = _6_0
          end
        end
        return send({["nrepl.middleware.print/buffer-size"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_buffer_size"}), ["nrepl.middleware.print/options"] = {associative = 1, length = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "length"}) or nil), level = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "level"}) or nil)}, ["nrepl.middleware.print/print"] = _4_, ["nrepl.middleware.print/quota"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_quota"}), code = opts.code, column = _7_, file = opts["file-path"], line = a["get-in"](opts, {"range", "start", 1}), ns = opts.context, op = "eval", session = opts.session}, cb)
      end
      return with_conn_or_warn(_3_)
    end
    v_0_0 = eval0
    _0_0["eval"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval"] = v_0_
  eval = v_0_
end
local with_session_ids = nil
do
  local v_0_ = nil
  local function with_session_ids0(cb)
    local function _3_(_)
      local function _4_(msg)
        local sessions = a.get(msg, "sessions")
        if ("table" == type(sessions)) then
          table.sort(sessions)
        end
        return cb(sessions)
      end
      return send({op = "ls-sessions"}, _4_)
    end
    return with_conn_or_warn(_3_)
  end
  v_0_ = with_session_ids0
  _0_0["aniseed/locals"]["with-session-ids"] = v_0_
  with_session_ids = v_0_
end
local pretty_session_type = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function pretty_session_type0(st)
      local function _3_()
        if a["string?"](st) then
          return (st .. "?")
        else
          return "https://conjure.fun/no-env"
        end
      end
      return a.get({clj = "Clojure", cljr = "ClojureCLR", cljs = "ClojureScript", timeout = "Timeout", unknown = "Unknown"}, st, _3_())
    end
    v_0_0 = pretty_session_type0
    _0_0["pretty-session-type"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["pretty-session-type"] = v_0_
  pretty_session_type = v_0_
end
local session_type = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function session_type0(id, cb)
      local timeout = nil
      local function _3_()
        return cb("timeout")
      end
      timeout = timer.defer(_3_, 300)
      local function _4_(msgs)
        timer.destroy(timeout)
        local st = nil
        local function _5_(_241)
          return a.get(_241, "value")
        end
        st = a.some(_5_, msgs)
        local function _6_()
          if st then
            return str.trim(st)
          end
        end
        return cb(_6_())
      end
      return send({code = ("#?(" .. str.join(" ", {":clj 'clj", ":cljs 'cljs", ":cljr 'cljr", ":default 'unknown"}) .. ")"), op = "eval", session = id}, nrepl["with-all-msgs-fn"](_4_))
    end
    v_0_0 = session_type0
    _0_0["session-type"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["session-type"] = v_0_
  session_type = v_0_
end
local enrich_session_id = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function enrich_session_id0(id, cb)
      local function _3_(st)
        local t = {["pretty-type"] = pretty_session_type(st), id = id, name = uuid.pretty(id), type = st}
        local function _4_()
          return (t.name .. " (" .. t["pretty-type"] .. ")")
        end
        a.assoc(t, "str", _4_)
        return cb(t)
      end
      return session_type(id, _3_)
    end
    v_0_0 = enrich_session_id0
    _0_0["enrich-session-id"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["enrich-session-id"] = v_0_
  enrich_session_id = v_0_
end
local with_sessions = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function with_sessions0(cb)
      local function _3_(sess_ids)
        local rich = {}
        local total = a.count(sess_ids)
        if (0 == total) then
          return cb({})
        else
          local function _4_(id)
            local function _5_(t)
              table.insert(rich, t)
              if (total == a.count(rich)) then
                local function _6_(_241, _242)
                  return (a.get(_241, "name") < a.get(_242, "name"))
                end
                table.sort(rich, _6_)
                return cb(rich)
              end
            end
            return enrich_session_id(id, _5_)
          end
          return a["run!"](_4_, sess_ids)
        end
      end
      return with_session_ids(_3_)
    end
    v_0_0 = with_sessions0
    _0_0["with-sessions"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["with-sessions"] = v_0_
  with_sessions = v_0_
end
local clone_session = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function clone_session0(session)
      local function _3_(msgs)
        local function _4_(_241)
          return a.get(_241, "new-session")
        end
        return enrich_session_id(a.some(_4_, msgs), assume_session)
      end
      return send({op = "clone", session = a.get(session, "id")}, nrepl["with-all-msgs-fn"](_3_))
    end
    v_0_0 = clone_session0
    _0_0["clone-session"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["clone-session"] = v_0_
  clone_session = v_0_
end
local assume_or_create_session = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function assume_or_create_session0()
      local function _3_(sessions)
        if a["empty?"](sessions) then
          return clone_session()
        else
          return assume_session(a.first(sessions))
        end
      end
      return with_sessions(_3_)
    end
    v_0_0 = assume_or_create_session0
    _0_0["assume-or-create-session"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["assume-or-create-session"] = v_0_
  assume_or_create_session = v_0_
end
local eval_preamble = nil
do
  local v_0_ = nil
  local function eval_preamble0(cb)
    local function _3_()
      if cb then
        return nrepl["with-all-msgs-fn"](cb)
      end
    end
    return send({code = ("(ns conjure.internal" .. "  (:require [clojure.pprint :as pp]))" .. "(defn pprint [val w opts]" .. "  (apply pp/write val" .. "    (mapcat identity (assoc opts :stream w))))"), op = "eval"}, _3_())
  end
  v_0_ = eval_preamble0
  _0_0["aniseed/locals"]["eval-preamble"] = v_0_
  eval_preamble = v_0_
end
local capture_describe = nil
do
  local v_0_ = nil
  local function capture_describe0()
    local function _3_(msg)
      return a.assoc(state.get("conn"), "describe", msg)
    end
    return send({op = "describe"}, _3_)
  end
  v_0_ = capture_describe0
  _0_0["aniseed/locals"]["capture-describe"] = v_0_
  capture_describe = v_0_
end
local with_conn_and_op_or_warn = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function with_conn_and_op_or_warn0(op, f, opts)
      local function _3_(conn)
        if a["get-in"](conn, {"describe", "ops", op}) then
          return f(conn)
        else
          if not a.get(opts, "silent?") then
            log.append({("; Unsupported operation: " .. op), "; Ensure the CIDER middleware is installed and up to date", "; https://docs.cider.mx/cider-nrepl/usage.html"})
          end
          if a.get(opts, "else") then
            return opts["else"]()
          end
        end
      end
      return with_conn_or_warn(_3_, opts)
    end
    v_0_0 = with_conn_and_op_or_warn0
    _0_0["with-conn-and-op-or-warn"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["with-conn-and-op-or-warn"] = v_0_
  with_conn_and_op_or_warn = v_0_
end
local connect = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connect0(_3_0)
      local _4_ = _3_0
      local cb = _4_["cb"]
      local host = _4_["host"]
      local port = _4_["port"]
      if state.get("conn") then
        disconnect()
      end
      local function _6_(result)
        return ui["display-result"](result)
      end
      local function _7_(err)
        if err then
          return display_conn_status(err)
        else
          return disconnect()
        end
      end
      local function _8_(err)
        display_conn_status(err)
        return disconnect()
      end
      local function _9_(msg)
        if msg.status["unknown-session"] then
          log.append({"; Unknown session, correcting"})
          assume_or_create_session()
        end
        if msg.status["namespace-not-found"] then
          return log.append({("; Namespace not found: " .. msg.ns)})
        end
      end
      local function _10_()
        display_conn_status("connected")
        capture_describe()
        assume_or_create_session()
        return eval_preamble(cb)
      end
      return a.assoc(state.get(), "conn", a["merge!"](nrepl.connect({["default-callback"] = _6_, ["on-error"] = _7_, ["on-failure"] = _8_, ["on-message"] = _9_, ["on-success"] = _10_, host = host, port = port}), {["seen-ns"] = {}}))
    end
    v_0_0 = connect0
    _0_0["connect"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connect"] = v_0_
  connect = v_0_
end
return nil