local _2afile_2a = "fnl/conjure/client/clojure/nrepl/server.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.server"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["_LOCALS"] = {}
  _2amodule_locals_2a = (_2amodule_2a)._LOCALS
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, config, log, nrepl, state, str, timer, ui, uuid = autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.remote.nrepl"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.timer"), autoload("conjure.client.clojure.nrepl.ui"), autoload("conjure.uuid")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["config"] = config
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
    end
    if a.get(opts, "else") then
      return opts["else"]()
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
        return (": " .. conn.port_file_path .. "")
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
  return log.append({("; Assumed session: " .. session.str())}, {["break?"] = true})
end
_2amodule_2a["assume-session"] = assume_session
local function eval(opts, cb)
  local function _9_(_)
    local _10_
    if config["get-in"]({"client", "clojure", "nrepl", "eval", "pretty_print"}) then
      _10_ = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_function"})
    else
    _10_ = nil
    end
    local _13_
    do
      local _12_ = a["get-in"](opts, {"range", "start", 2})
      if _12_ then
        _13_ = a.inc(_12_)
      else
        _13_ = _12_
      end
    end
    return send({["nrepl.middleware.print/buffer-size"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_buffer_size"}), ["nrepl.middleware.print/options"] = {associative = 1, length = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "length"}) or nil), level = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "level"}) or nil)}, ["nrepl.middleware.print/print"] = _10_, ["nrepl.middleware.print/quota"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_quota"}), code = opts.code, column = _13_, file = opts["file-path"], line = a["get-in"](opts, {"range", "start", 1}), ns = opts.context, op = "eval", session = opts.session}, cb)
  end
  return with_conn_or_warn(_9_)
end
_2amodule_2a["eval"] = eval
local function with_session_ids(cb)
  local function _15_(_)
    local function _16_(msg)
      local sessions = a.get(msg, "sessions")
      if ("table" == type(sessions)) then
        table.sort(sessions)
      end
      return cb(sessions)
    end
    return send({op = "ls-sessions"}, _16_)
  end
  return with_conn_or_warn(_15_)
end
_2amodule_locals_2a["with-session-ids"] = with_session_ids
local function pretty_session_type(st)
  local function _18_()
    if a["string?"](st) then
      return (st .. "?")
    else
      return "https://conjure.fun/no-env"
    end
  end
  return a.get({clj = "Clojure", cljr = "ClojureCLR", cljs = "ClojureScript", timeout = "Timeout", unknown = "Unknown"}, st, _18_())
end
_2amodule_2a["pretty-session-type"] = pretty_session_type
local function session_type(id, cb)
  local timeout
  local function _19_()
    return cb("timeout")
  end
  timeout = timer.defer(_19_, 300)
  local function _20_(msgs)
    timer.destroy(timeout)
    local st
    local function _21_(_241)
      return a.get(_241, "value")
    end
    st = a.some(_21_, msgs)
    local function _22_()
      if st then
        return str.trim(st)
      end
    end
    return cb(_22_())
  end
  return send({code = ("#?(" .. str.join(" ", {":clj 'clj", ":cljs 'cljs", ":cljr 'cljr", ":default 'unknown"}) .. ")"), op = "eval", session = id}, nrepl["with-all-msgs-fn"](_20_))
end
_2amodule_2a["session-type"] = session_type
local function enrich_session_id(id, cb)
  local function _23_(st)
    local t = {["pretty-type"] = pretty_session_type(st), id = id, name = uuid.pretty(id), type = st}
    local function _24_()
      return (t.name .. " (" .. t["pretty-type"] .. ")")
    end
    a.assoc(t, "str", _24_)
    return cb(t)
  end
  return session_type(id, _23_)
end
_2amodule_2a["enrich-session-id"] = enrich_session_id
local function with_sessions(cb)
  local function _25_(sess_ids)
    local rich = {}
    local total = a.count(sess_ids)
    if (0 == total) then
      return cb({})
    else
      local function _26_(id)
        local function _27_(t)
          table.insert(rich, t)
          if (total == a.count(rich)) then
            local function _28_(_241, _242)
              return (a.get(_241, "name") < a.get(_242, "name"))
            end
            table.sort(rich, _28_)
            return cb(rich)
          end
        end
        return enrich_session_id(id, _27_)
      end
      return a["run!"](_26_, sess_ids)
    end
  end
  return with_session_ids(_25_)
end
_2amodule_2a["with-sessions"] = with_sessions
local function clone_session(session)
  local function _31_(msgs)
    local function _32_(_241)
      return a.get(_241, "new-session")
    end
    return enrich_session_id(a.some(_32_, msgs), assume_session)
  end
  return send({op = "clone", session = a.get(session, "id")}, nrepl["with-all-msgs-fn"](_31_))
end
_2amodule_2a["clone-session"] = clone_session
local function assume_or_create_session()
  local function _33_(sessions)
    if a["empty?"](sessions) then
      return clone_session()
    else
      return assume_session(a.first(sessions))
    end
  end
  return with_sessions(_33_)
end
_2amodule_2a["assume-or-create-session"] = assume_or_create_session
local function eval_preamble(cb)
  local function _35_()
    if cb then
      return nrepl["with-all-msgs-fn"](cb)
    end
  end
  return send({code = ("(ns conjure.internal" .. "  (:require [clojure.pprint :as pp]))" .. "(defn pprint [val w opts]" .. "  (apply pp/write val" .. "    (mapcat identity (assoc opts :stream w))))"), op = "eval"}, _35_())
end
_2amodule_locals_2a["eval-preamble"] = eval_preamble
local function capture_describe()
  local function _36_(msg)
    return a.assoc(state.get("conn"), "describe", msg)
  end
  return send({op = "describe"}, _36_)
end
_2amodule_locals_2a["capture-describe"] = capture_describe
local function with_conn_and_op_or_warn(op, f, opts)
  local function _37_(conn)
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
  return with_conn_or_warn(_37_, opts)
end
_2amodule_2a["with-conn-and-op-or-warn"] = with_conn_and_op_or_warn
local function connect(_41_)
  local _arg_42_ = _41_
  local cb = _arg_42_["cb"]
  local host = _arg_42_["host"]
  local port = _arg_42_["port"]
  local port_file_path = _arg_42_["port_file_path"]
  if state.get("conn") then
    disconnect()
  end
  local function _44_(result)
    return ui["display-result"](result)
  end
  local function _45_(err)
    if err then
      return display_conn_status(err)
    else
      return disconnect()
    end
  end
  local function _47_(err)
    display_conn_status(err)
    return disconnect()
  end
  local function _48_(msg)
    if msg.status["unknown-session"] then
      log.append({"; Unknown session, correcting"})
      assume_or_create_session()
    end
    if msg.status["namespace-not-found"] then
      return log.append({("; Namespace not found: " .. msg.ns)})
    end
  end
  local function _51_()
    display_conn_status("connected")
    capture_describe()
    assume_or_create_session()
    return eval_preamble(cb)
  end
  return a.assoc(state.get(), "conn", a["merge!"](nrepl.connect({["default-callback"] = _44_, ["on-error"] = _45_, ["on-failure"] = _47_, ["on-message"] = _48_, ["on-success"] = _51_, host = host, port = port}), {["seen-ns"] = {}, port_file_path = port_file_path}))
end
_2amodule_2a["connect"] = connect