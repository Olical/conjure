local _2afile_2a = "fnl/conjure/client/clojure/nrepl/server.fnl"
local _0_0
do
  local name_0_ = "conjure.client.clojure.nrepl.server"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.remote.nrepl"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.timer"), autoload("conjure.client.clojure.nrepl.ui"), autoload("conjure.uuid")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", config = "conjure.config", log = "conjure.log", nrepl = "conjure.remote.nrepl", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", timer = "conjure.timer", ui = "conjure.client.clojure.nrepl.ui", uuid = "conjure.uuid"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
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
do local _ = ({nil, _0_0, nil, {{}, nil, nil, nil}})[2] end
local with_conn_or_warn
do
  local v_0_
  do
    local v_0_0
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
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["with-conn-or-warn"] = v_0_
  with_conn_or_warn = v_0_
end
local connected_3f
do
  local v_0_
  do
    local v_0_0
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
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["connected?"] = v_0_
  connected_3f = v_0_
end
local send
do
  local v_0_
  do
    local v_0_0
    local function send0(msg, cb)
      local function _2_(conn)
        return conn.send(msg, cb)
      end
      return with_conn_or_warn(_2_)
    end
    v_0_0 = send0
    _0_0["send"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["send"] = v_0_
  send = v_0_
end
local display_conn_status
do
  local v_0_
  local function display_conn_status0(status)
    local function _2_(conn)
      local function _3_()
        if conn.port_file_path then
          return (": " .. conn.port_file_path .. "")
        end
      end
      return log.append({str.join({"; ", conn.host, ":", conn.port, " (", status, ")", _3_()})}, {["break?"] = true})
    end
    return with_conn_or_warn(_2_)
  end
  v_0_ = display_conn_status0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["display-conn-status"] = v_0_
  display_conn_status = v_0_
end
local disconnect
do
  local v_0_
  do
    local v_0_0
    local function disconnect0()
      local function _2_(conn)
        conn.destroy()
        display_conn_status("disconnected")
        return a.assoc(state.get(), "conn", nil)
      end
      return with_conn_or_warn(_2_)
    end
    v_0_0 = disconnect0
    _0_0["disconnect"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["disconnect"] = v_0_
  disconnect = v_0_
end
local close_session
do
  local v_0_
  do
    local v_0_0
    local function close_session0(session, cb)
      return send({op = "close", session = a.get(session, "id")}, cb)
    end
    v_0_0 = close_session0
    _0_0["close-session"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["close-session"] = v_0_
  close_session = v_0_
end
local assume_session
do
  local v_0_
  do
    local v_0_0
    local function assume_session0(session)
      a.assoc(state.get("conn"), "session", a.get(session, "id"))
      return log.append({("; Assumed session: " .. session.str())}, {["break?"] = true})
    end
    v_0_0 = assume_session0
    _0_0["assume-session"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["assume-session"] = v_0_
  assume_session = v_0_
end
local eval
do
  local v_0_
  do
    local v_0_0
    local function eval0(opts, cb)
      local function _2_(_)
        local _3_
        if config["get-in"]({"client", "clojure", "nrepl", "eval", "pretty_print"}) then
          _3_ = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_function"})
        else
        _3_ = nil
        end
        local _6_
        do
          local _5_0 = a["get-in"](opts, {"range", "start", 2})
          if _5_0 then
            _6_ = a.inc(_5_0)
          else
            _6_ = _5_0
          end
        end
        return send({["nrepl.middleware.print/buffer-size"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_buffer_size"}), ["nrepl.middleware.print/options"] = {associative = 1, length = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "length"}) or nil), level = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "level"}) or nil)}, ["nrepl.middleware.print/print"] = _3_, ["nrepl.middleware.print/quota"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_quota"}), code = opts.code, column = _6_, file = opts["file-path"], line = a["get-in"](opts, {"range", "start", 1}), ns = opts.context, op = "eval", session = opts.session}, cb)
      end
      return with_conn_or_warn(_2_)
    end
    v_0_0 = eval0
    _0_0["eval"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["eval"] = v_0_
  eval = v_0_
end
local with_session_ids
do
  local v_0_
  local function with_session_ids0(cb)
    local function _2_(_)
      local function _3_(msg)
        local sessions = a.get(msg, "sessions")
        if ("table" == type(sessions)) then
          table.sort(sessions)
        end
        return cb(sessions)
      end
      return send({op = "ls-sessions"}, _3_)
    end
    return with_conn_or_warn(_2_)
  end
  v_0_ = with_session_ids0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["with-session-ids"] = v_0_
  with_session_ids = v_0_
end
local pretty_session_type
do
  local v_0_
  do
    local v_0_0
    local function pretty_session_type0(st)
      local function _2_()
        if a["string?"](st) then
          return (st .. "?")
        else
          return "https://conjure.fun/no-env"
        end
      end
      return a.get({clj = "Clojure", cljr = "ClojureCLR", cljs = "ClojureScript", timeout = "Timeout", unknown = "Unknown"}, st, _2_())
    end
    v_0_0 = pretty_session_type0
    _0_0["pretty-session-type"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["pretty-session-type"] = v_0_
  pretty_session_type = v_0_
end
local session_type
do
  local v_0_
  do
    local v_0_0
    local function session_type0(id, cb)
      local timeout
      local function _2_()
        return cb("timeout")
      end
      timeout = timer.defer(_2_, 300)
      local function _3_(msgs)
        timer.destroy(timeout)
        local st
        local function _4_(_241)
          return a.get(_241, "value")
        end
        st = a.some(_4_, msgs)
        local function _5_()
          if st then
            return str.trim(st)
          end
        end
        return cb(_5_())
      end
      return send({code = ("#?(" .. str.join(" ", {":clj 'clj", ":cljs 'cljs", ":cljr 'cljr", ":default 'unknown"}) .. ")"), op = "eval", session = id}, nrepl["with-all-msgs-fn"](_3_))
    end
    v_0_0 = session_type0
    _0_0["session-type"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["session-type"] = v_0_
  session_type = v_0_
end
local enrich_session_id
do
  local v_0_
  do
    local v_0_0
    local function enrich_session_id0(id, cb)
      local function _2_(st)
        local t = {["pretty-type"] = pretty_session_type(st), id = id, name = uuid.pretty(id), type = st}
        local function _3_()
          return (t.name .. " (" .. t["pretty-type"] .. ")")
        end
        a.assoc(t, "str", _3_)
        return cb(t)
      end
      return session_type(id, _2_)
    end
    v_0_0 = enrich_session_id0
    _0_0["enrich-session-id"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["enrich-session-id"] = v_0_
  enrich_session_id = v_0_
end
local with_sessions
do
  local v_0_
  do
    local v_0_0
    local function with_sessions0(cb)
      local function _2_(sess_ids)
        local rich = {}
        local total = a.count(sess_ids)
        if (0 == total) then
          return cb({})
        else
          local function _3_(id)
            local function _4_(t)
              table.insert(rich, t)
              if (total == a.count(rich)) then
                local function _5_(_241, _242)
                  return (a.get(_241, "name") < a.get(_242, "name"))
                end
                table.sort(rich, _5_)
                return cb(rich)
              end
            end
            return enrich_session_id(id, _4_)
          end
          return a["run!"](_3_, sess_ids)
        end
      end
      return with_session_ids(_2_)
    end
    v_0_0 = with_sessions0
    _0_0["with-sessions"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["with-sessions"] = v_0_
  with_sessions = v_0_
end
local clone_session
do
  local v_0_
  do
    local v_0_0
    local function clone_session0(session)
      local function _2_(msgs)
        local function _3_(_241)
          return a.get(_241, "new-session")
        end
        return enrich_session_id(a.some(_3_, msgs), assume_session)
      end
      return send({op = "clone", session = a.get(session, "id")}, nrepl["with-all-msgs-fn"](_2_))
    end
    v_0_0 = clone_session0
    _0_0["clone-session"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["clone-session"] = v_0_
  clone_session = v_0_
end
local assume_or_create_session
do
  local v_0_
  do
    local v_0_0
    local function assume_or_create_session0()
      local function _2_(sessions)
        if a["empty?"](sessions) then
          return clone_session()
        else
          return assume_session(a.first(sessions))
        end
      end
      return with_sessions(_2_)
    end
    v_0_0 = assume_or_create_session0
    _0_0["assume-or-create-session"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["assume-or-create-session"] = v_0_
  assume_or_create_session = v_0_
end
local eval_preamble
do
  local v_0_
  local function eval_preamble0(cb)
    local function _2_()
      if cb then
        return nrepl["with-all-msgs-fn"](cb)
      end
    end
    return send({code = ("(ns conjure.internal" .. "  (:require [clojure.pprint :as pp]))" .. "(defn pprint [val w opts]" .. "  (apply pp/write val" .. "    (mapcat identity (assoc opts :stream w))))"), op = "eval"}, _2_())
  end
  v_0_ = eval_preamble0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["eval-preamble"] = v_0_
  eval_preamble = v_0_
end
local capture_describe
do
  local v_0_
  local function capture_describe0()
    local function _2_(msg)
      return a.assoc(state.get("conn"), "describe", msg)
    end
    return send({op = "describe"}, _2_)
  end
  v_0_ = capture_describe0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["capture-describe"] = v_0_
  capture_describe = v_0_
end
local with_conn_and_op_or_warn
do
  local v_0_
  do
    local v_0_0
    local function with_conn_and_op_or_warn0(op, f, opts)
      local function _2_(conn)
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
      return with_conn_or_warn(_2_, opts)
    end
    v_0_0 = with_conn_and_op_or_warn0
    _0_0["with-conn-and-op-or-warn"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["with-conn-and-op-or-warn"] = v_0_
  with_conn_and_op_or_warn = v_0_
end
local connect
do
  local v_0_
  do
    local v_0_0
    local function connect0(_2_0)
      local _arg_0_ = _2_0
      local cb = _arg_0_["cb"]
      local host = _arg_0_["host"]
      local port = _arg_0_["port"]
      local port_file_path = _arg_0_["port_file_path"]
      if state.get("conn") then
        disconnect()
      end
      local function _4_(result)
        return ui["display-result"](result)
      end
      local function _5_(err)
        if err then
          return display_conn_status(err)
        else
          return disconnect()
        end
      end
      local function _6_(err)
        display_conn_status(err)
        return disconnect()
      end
      local function _7_(msg)
        if msg.status["unknown-session"] then
          log.append({"; Unknown session, correcting"})
          assume_or_create_session()
        end
        if msg.status["namespace-not-found"] then
          return log.append({("; Namespace not found: " .. msg.ns)})
        end
      end
      local function _8_()
        display_conn_status("connected")
        capture_describe()
        assume_or_create_session()
        return eval_preamble(cb)
      end
      return a.assoc(state.get(), "conn", a["merge!"](nrepl.connect({["default-callback"] = _4_, ["on-error"] = _5_, ["on-failure"] = _6_, ["on-message"] = _7_, ["on-success"] = _8_, host = host, port = port}), {["seen-ns"] = {}, port_file_path = port_file_path}))
    end
    v_0_0 = connect0
    _0_0["connect"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["connect"] = v_0_
  connect = v_0_
end
return nil