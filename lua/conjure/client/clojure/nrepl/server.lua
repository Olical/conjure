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
local function eval(opts, cb)
  local function _9_(_)
    local _11_
    do
      local _10_ = a["get-in"](opts, {"range", "start", 2})
      if (nil ~= _10_) then
        _11_ = a.inc(_10_)
      else
        _11_ = _10_
      end
    end
    local _13_
    if config["get-in"]({"client", "clojure", "nrepl", "eval", "pretty_print"}) then
      _13_ = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_function"})
    else
      _13_ = nil
    end
    return send({op = "eval", ns = opts.context, code = opts.code, file = opts["file-path"], line = a["get-in"](opts, {"range", "start", 1}), column = _11_, session = opts.session, ["nrepl.middleware.print/options"] = {associative = 1, level = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "level"}) or nil), length = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "length"}) or nil)}, ["nrepl.middleware.print/quota"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_quota"}), ["nrepl.middleware.print/buffer-size"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_buffer_size"}), ["nrepl.middleware.print/print"] = _13_}, cb)
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
      else
      end
      return cb(sessions)
    end
    return send({op = "ls-sessions", session = "no-session"}, _16_)
  end
  return with_conn_or_warn(_15_)
end
_2amodule_locals_2a["with-session-ids"] = with_session_ids
local function pretty_session_type(st)
  return a.get({clj = "Clojure", cljs = "ClojureScript", cljr = "ClojureCLR"}, st, "Unknown https://conjure.fun/unknown-env")
end
_2amodule_2a["pretty-session-type"] = pretty_session_type
local function session_type(id, cb)
  local state0 = {["done?"] = false}
  local function _18_()
    if not state0["done?"] then
      state0["done?"] = true
      return cb("unknown")
    else
      return nil
    end
  end
  timer.defer(_18_, 200)
  local function _20_(msgs)
    local st
    local function _21_(_241)
      return a.get(_241, "value")
    end
    st = a.some(_21_, msgs)
    if not state0["done?"] then
      state0["done?"] = true
      local function _22_()
        if st then
          return str.trim(st)
        else
          return nil
        end
      end
      return cb(_22_())
    else
      return nil
    end
  end
  return send({op = "eval", code = ("#?(" .. str.join(" ", {":clj 'clj", ":cljs 'cljs", ":cljr 'cljr", ":default 'unknown"}) .. ")"), session = id}, nrepl["with-all-msgs-fn"](_20_))
end
_2amodule_2a["session-type"] = session_type
local function enrich_session_id(id, cb)
  local function _24_(st)
    local t = {id = id, type = st, ["pretty-type"] = pretty_session_type(st), name = uuid.pretty(id)}
    local function _25_()
      return str.join({t.name, " (", t["pretty-type"], ")"})
    end
    a.assoc(t, "str", _25_)
    return cb(t)
  end
  return session_type(id, _24_)
end
_2amodule_2a["enrich-session-id"] = enrich_session_id
local function with_sessions(cb)
  local function _26_(sess_ids)
    local rich = {}
    local total = a.count(sess_ids)
    if (0 == total) then
      return cb({})
    else
      local function _27_(id)
        local function _28_(t)
          table.insert(rich, t)
          if (total == a.count(rich)) then
            local function _29_(_241, _242)
              return (a.get(_241, "name") < a.get(_242, "name"))
            end
            table.sort(rich, _29_)
            return cb(rich)
          else
            return nil
          end
        end
        return enrich_session_id(id, _28_)
      end
      return a["run!"](_27_, sess_ids)
    end
  end
  return with_session_ids(_26_)
end
_2amodule_2a["with-sessions"] = with_sessions
local function clone_session(session)
  local function _32_(msgs)
    local function _33_(_241)
      return a.get(_241, "new-session")
    end
    return enrich_session_id(a.some(_33_, msgs), assume_session)
  end
  return send({op = "clone", session = a.get(session, "id")}, nrepl["with-all-msgs-fn"](_32_))
end
_2amodule_2a["clone-session"] = clone_session
local function assume_or_create_session()
  a.assoc(state.get("conn"), "session", nil)
  local function _34_(sessions)
    if a["empty?"](sessions) then
      return clone_session()
    else
      return assume_session(a.first(sessions))
    end
  end
  return with_sessions(_34_)
end
_2amodule_2a["assume-or-create-session"] = assume_or_create_session
local function eval_preamble(cb)
  local function _36_()
    if cb then
      return nrepl["with-all-msgs-fn"](cb)
    else
      return nil
    end
  end
  return send({op = "eval", code = ("(ns conjure.internal" .. "  (:require [clojure.pprint :as pp]))" .. "(defn pprint [val w opts]" .. "  (apply pp/write val" .. "    (mapcat identity (assoc opts :stream w))))")}, _36_())
end
_2amodule_locals_2a["eval-preamble"] = eval_preamble
local function capture_describe()
  local function _37_(msg)
    return a.assoc(state.get("conn"), "describe", msg)
  end
  return send({op = "describe"}, _37_)
end
_2amodule_locals_2a["capture-describe"] = capture_describe
local function with_conn_and_ops_or_warn(op_names, f, opts)
  local function _38_(conn)
    local found_ops
    local function _39_(acc, op)
      if a["get-in"](conn, {"describe", "ops", op}) then
        return a.assoc(acc, op, true)
      else
        return acc
      end
    end
    found_ops = a.reduce(_39_, {}, op_names)
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
  return with_conn_or_warn(_38_, opts)
end
_2amodule_2a["with-conn-and-ops-or-warn"] = with_conn_and_ops_or_warn
local function connect(_44_)
  local _arg_45_ = _44_
  local host = _arg_45_["host"]
  local port = _arg_45_["port"]
  local cb = _arg_45_["cb"]
  local port_file_path = _arg_45_["port_file_path"]
  if state.get("conn") then
    disconnect()
  else
  end
  local function _47_(err)
    display_conn_status(err)
    return disconnect()
  end
  local function _48_()
    display_conn_status("connected")
    capture_describe()
    assume_or_create_session()
    return eval_preamble(cb)
  end
  local function _49_(err)
    if err then
      return display_conn_status(err)
    else
      return disconnect()
    end
  end
  local function _51_(msg)
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
  local function _54_(result)
    return ui["display-result"](result)
  end
  return a.assoc(state.get(), "conn", a["merge!"](nrepl.connect({host = host, port = port, ["on-failure"] = _47_, ["on-success"] = _48_, ["on-error"] = _49_, ["on-message"] = _51_, ["default-callback"] = _54_}), {["seen-ns"] = {}, port_file_path = port_file_path}))
end
_2amodule_2a["connect"] = connect
return _2amodule_2a