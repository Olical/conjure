local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.clojure.nrepl.server"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.config"), require("conjure.log"), require("conjure.remote.nrepl"), require("conjure.client.clojure.nrepl.state"), require("conjure.aniseed.string"), require("conjure.timer"), require("conjure.client.clojure.nrepl.ui"), require("conjure.uuid")}
local a = _local_0_[1]
local config = _local_0_[2]
local log = _local_0_[3]
local nrepl = _local_0_[4]
local state = _local_0_[5]
local str = _local_0_[6]
local timer = _local_0_[7]
local ui = _local_0_[8]
local uuid = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl.server"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local with_conn_or_warn
do
  local v_0_
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
  v_0_ = with_conn_or_warn0
  _0_0["with-conn-or-warn"] = v_0_
  with_conn_or_warn = v_0_
end
local connected_3f
do
  local v_0_
  local function connected_3f0()
    if state.get("conn") then
      return true
    else
      return false
    end
  end
  v_0_ = connected_3f0
  _0_0["connected?"] = v_0_
  connected_3f = v_0_
end
local send
do
  local v_0_
  local function send0(msg, cb)
    local function _1_(conn)
      return conn.send(msg, cb)
    end
    return with_conn_or_warn(_1_)
  end
  v_0_ = send0
  _0_0["send"] = v_0_
  send = v_0_
end
local function display_conn_status(status)
  local function _1_(conn)
    return log.append({("; " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
  end
  return with_conn_or_warn(_1_)
end
local disconnect
do
  local v_0_
  local function disconnect0()
    local function _1_(conn)
      conn.destroy()
      display_conn_status("disconnected")
      return a.assoc(state.get(), "conn", nil)
    end
    return with_conn_or_warn(_1_)
  end
  v_0_ = disconnect0
  _0_0["disconnect"] = v_0_
  disconnect = v_0_
end
local close_session
do
  local v_0_
  local function close_session0(session, cb)
    return send({op = "close", session = a.get(session, "id")}, cb)
  end
  v_0_ = close_session0
  _0_0["close-session"] = v_0_
  close_session = v_0_
end
local assume_session
do
  local v_0_
  local function assume_session0(session)
    a.assoc(state.get("conn"), "session", a.get(session, "id"))
    return log.append({("; Assumed session: " .. session.str())}, {["break?"] = true})
  end
  v_0_ = assume_session0
  _0_0["assume-session"] = v_0_
  assume_session = v_0_
end
local eval
do
  local v_0_
  local function eval0(opts, cb)
    local function _1_(_)
      local _2_
      if config["get-in"]({"client", "clojure", "nrepl", "eval", "pretty_print"}) then
        _2_ = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_function"})
      else
      _2_ = nil
      end
      local _5_
      do
        local _4_0 = a["get-in"](opts, {"range", "start", 2})
        if _4_0 then
          _5_ = a.inc(_4_0)
        else
          _5_ = _4_0
        end
      end
      return send({["nrepl.middleware.print/buffer-size"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_buffer_size"}), ["nrepl.middleware.print/options"] = {associative = 1, length = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "length"}) or nil), level = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "level"}) or nil)}, ["nrepl.middleware.print/print"] = _2_, ["nrepl.middleware.print/quota"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_quota"}), code = opts.code, column = _5_, file = opts["file-path"], line = a["get-in"](opts, {"range", "start", 1}), ns = opts.context, op = "eval", session = opts.session}, cb)
    end
    return with_conn_or_warn(_1_)
  end
  v_0_ = eval0
  _0_0["eval"] = v_0_
  eval = v_0_
end
local function with_session_ids(cb)
  local function _1_(_)
    local function _2_(msg)
      local sessions = a.get(msg, "sessions")
      if ("table" == type(sessions)) then
        table.sort(sessions)
      end
      return cb(sessions)
    end
    return send({op = "ls-sessions"}, _2_)
  end
  return with_conn_or_warn(_1_)
end
local pretty_session_type
do
  local v_0_
  local function pretty_session_type0(st)
    local function _1_()
      if a["string?"](st) then
        return (st .. "?")
      else
        return "https://conjure.fun/no-env"
      end
    end
    return a.get({clj = "Clojure", cljr = "ClojureCLR", cljs = "ClojureScript", timeout = "Timeout", unknown = "Unknown"}, st, _1_())
  end
  v_0_ = pretty_session_type0
  _0_0["pretty-session-type"] = v_0_
  pretty_session_type = v_0_
end
local session_type
do
  local v_0_
  local function session_type0(id, cb)
    local timeout
    local function _1_()
      return cb("timeout")
    end
    timeout = timer.defer(_1_, 300)
    local function _2_(msgs)
      timer.destroy(timeout)
      local st
      local function _3_(_241)
        return a.get(_241, "value")
      end
      st = a.some(_3_, msgs)
      local function _4_()
        if st then
          return str.trim(st)
        end
      end
      return cb(_4_())
    end
    return send({code = ("#?(" .. str.join(" ", {":clj 'clj", ":cljs 'cljs", ":cljr 'cljr", ":default 'unknown"}) .. ")"), op = "eval", session = id}, nrepl["with-all-msgs-fn"](_2_))
  end
  v_0_ = session_type0
  _0_0["session-type"] = v_0_
  session_type = v_0_
end
local enrich_session_id
do
  local v_0_
  local function enrich_session_id0(id, cb)
    local function _1_(st)
      local t = {["pretty-type"] = pretty_session_type(st), id = id, name = uuid.pretty(id), type = st}
      local function _2_()
        return (t.name .. " (" .. t["pretty-type"] .. ")")
      end
      a.assoc(t, "str", _2_)
      return cb(t)
    end
    return session_type(id, _1_)
  end
  v_0_ = enrich_session_id0
  _0_0["enrich-session-id"] = v_0_
  enrich_session_id = v_0_
end
local with_sessions
do
  local v_0_
  local function with_sessions0(cb)
    local function _1_(sess_ids)
      local rich = {}
      local total = a.count(sess_ids)
      if (0 == total) then
        return cb({})
      else
        local function _2_(id)
          local function _3_(t)
            table.insert(rich, t)
            if (total == a.count(rich)) then
              local function _4_(_241, _242)
                return (a.get(_241, "name") < a.get(_242, "name"))
              end
              table.sort(rich, _4_)
              return cb(rich)
            end
          end
          return enrich_session_id(id, _3_)
        end
        return a["run!"](_2_, sess_ids)
      end
    end
    return with_session_ids(_1_)
  end
  v_0_ = with_sessions0
  _0_0["with-sessions"] = v_0_
  with_sessions = v_0_
end
local clone_session
do
  local v_0_
  local function clone_session0(session)
    local function _1_(msgs)
      local function _2_(_241)
        return a.get(_241, "new-session")
      end
      return enrich_session_id(a.some(_2_, msgs), assume_session)
    end
    return send({op = "clone", session = a.get(session, "id")}, nrepl["with-all-msgs-fn"](_1_))
  end
  v_0_ = clone_session0
  _0_0["clone-session"] = v_0_
  clone_session = v_0_
end
local assume_or_create_session
do
  local v_0_
  local function assume_or_create_session0()
    local function _1_(sessions)
      if a["empty?"](sessions) then
        return clone_session()
      else
        return assume_session(a.first(sessions))
      end
    end
    return with_sessions(_1_)
  end
  v_0_ = assume_or_create_session0
  _0_0["assume-or-create-session"] = v_0_
  assume_or_create_session = v_0_
end
local function eval_preamble(cb)
  local function _1_()
    if cb then
      return nrepl["with-all-msgs-fn"](cb)
    end
  end
  return send({code = ("(ns conjure.internal" .. "  (:require [clojure.pprint :as pp]))" .. "(defn pprint [val w opts]" .. "  (apply pp/write val" .. "    (mapcat identity (assoc opts :stream w))))"), op = "eval"}, _1_())
end
local function capture_describe()
  local function _1_(msg)
    return a.assoc(state.get("conn"), "describe", msg)
  end
  return send({op = "describe"}, _1_)
end
local with_conn_and_op_or_warn
do
  local v_0_
  local function with_conn_and_op_or_warn0(op, f, opts)
    local function _1_(conn)
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
    return with_conn_or_warn(_1_, opts)
  end
  v_0_ = with_conn_and_op_or_warn0
  _0_0["with-conn-and-op-or-warn"] = v_0_
  with_conn_and_op_or_warn = v_0_
end
local connect
do
  local v_0_
  local function connect0(_1_0)
    local _arg_0_ = _1_0
    local cb = _arg_0_["cb"]
    local host = _arg_0_["host"]
    local port = _arg_0_["port"]
    if state.get("conn") then
      disconnect()
    end
    local function _3_(result)
      return ui["display-result"](result)
    end
    local function _4_(err)
      if err then
        return display_conn_status(err)
      else
        return disconnect()
      end
    end
    local function _5_(err)
      display_conn_status(err)
      return disconnect()
    end
    local function _6_(msg)
      if msg.status["unknown-session"] then
        log.append({"; Unknown session, correcting"})
        assume_or_create_session()
      end
      if msg.status["namespace-not-found"] then
        return log.append({("; Namespace not found: " .. msg.ns)})
      end
    end
    local function _7_()
      display_conn_status("connected")
      capture_describe()
      assume_or_create_session()
      return eval_preamble(cb)
    end
    return a.assoc(state.get(), "conn", a["merge!"](nrepl.connect({["default-callback"] = _3_, ["on-error"] = _4_, ["on-failure"] = _5_, ["on-message"] = _6_, ["on-success"] = _7_, host = host, port = port}), {["seen-ns"] = {}}))
  end
  v_0_ = connect0
  _0_0["connect"] = v_0_
  connect = v_0_
end
return nil