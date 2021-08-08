local _2afile_2a = "fnl/conjure/client/clojure/nrepl/server.fnl"
local _1_
do
  local name_4_auto = "conjure.client.clojure.nrepl.server"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.remote.nrepl"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.timer"), autoload("conjure.client.clojure.nrepl.ui"), autoload("conjure.uuid")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", config = "conjure.config", log = "conjure.log", nrepl = "conjure.remote.nrepl", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", timer = "conjure.timer", ui = "conjure.client.clojure.nrepl.ui", uuid = "conjure.uuid"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local config = _local_4_[2]
local log = _local_4_[3]
local nrepl = _local_4_[4]
local state = _local_4_[5]
local str = _local_4_[6]
local timer = _local_4_[7]
local ui = _local_4_[8]
local uuid = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client.clojure.nrepl.server"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local with_conn_or_warn
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = with_conn_or_warn0
    _1_["with-conn-or-warn"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-conn-or-warn"] = v_23_auto
  with_conn_or_warn = v_23_auto
end
local connected_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function connected_3f0()
      if state.get("conn") then
        return true
      else
        return false
      end
    end
    v_25_auto = connected_3f0
    _1_["connected?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connected?"] = v_23_auto
  connected_3f = v_23_auto
end
local send
do
  local v_23_auto
  do
    local v_25_auto
    local function send0(msg, cb)
      local function _12_(conn)
        return conn.send(msg, cb)
      end
      return with_conn_or_warn(_12_)
    end
    v_25_auto = send0
    _1_["send"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["send"] = v_23_auto
  send = v_23_auto
end
local display_conn_status
do
  local v_23_auto
  local function display_conn_status0(status)
    local function _13_(conn)
      local function _14_()
        if conn.port_file_path then
          return (": " .. conn.port_file_path .. "")
        end
      end
      return log.append({str.join({"; ", conn.host, ":", conn.port, " (", status, ")", _14_()})}, {["break?"] = true})
    end
    return with_conn_or_warn(_13_)
  end
  v_23_auto = display_conn_status0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-conn-status"] = v_23_auto
  display_conn_status = v_23_auto
end
local disconnect
do
  local v_23_auto
  do
    local v_25_auto
    local function disconnect0()
      local function _15_(conn)
        conn.destroy()
        display_conn_status("disconnected")
        return a.assoc(state.get(), "conn", nil)
      end
      return with_conn_or_warn(_15_)
    end
    v_25_auto = disconnect0
    _1_["disconnect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["disconnect"] = v_23_auto
  disconnect = v_23_auto
end
local close_session
do
  local v_23_auto
  do
    local v_25_auto
    local function close_session0(session, cb)
      return send({op = "close", session = a.get(session, "id")}, cb)
    end
    v_25_auto = close_session0
    _1_["close-session"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["close-session"] = v_23_auto
  close_session = v_23_auto
end
local assume_session
do
  local v_23_auto
  do
    local v_25_auto
    local function assume_session0(session)
      a.assoc(state.get("conn"), "session", a.get(session, "id"))
      return log.append({("; Assumed session: " .. session.str())}, {["break?"] = true})
    end
    v_25_auto = assume_session0
    _1_["assume-session"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["assume-session"] = v_23_auto
  assume_session = v_23_auto
end
local eval
do
  local v_23_auto
  do
    local v_25_auto
    local function eval0(opts, cb)
      local function _16_(_)
        local _17_
        if config["get-in"]({"client", "clojure", "nrepl", "eval", "pretty_print"}) then
          _17_ = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_function"})
        else
        _17_ = nil
        end
        local _20_
        do
          local _19_ = a["get-in"](opts, {"range", "start", 2})
          if _19_ then
            _20_ = a.inc(_19_)
          else
            _20_ = _19_
          end
        end
        return send({["nrepl.middleware.print/buffer-size"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_buffer_size"}), ["nrepl.middleware.print/options"] = {associative = 1, length = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "length"}) or nil), level = (config["get-in"]({"client", "clojure", "nrepl", "eval", "print_options", "level"}) or nil)}, ["nrepl.middleware.print/print"] = _17_, ["nrepl.middleware.print/quota"] = config["get-in"]({"client", "clojure", "nrepl", "eval", "print_quota"}), code = opts.code, column = _20_, file = opts["file-path"], line = a["get-in"](opts, {"range", "start", 1}), ns = opts.context, op = "eval", session = opts.session}, cb)
      end
      return with_conn_or_warn(_16_)
    end
    v_25_auto = eval0
    _1_["eval"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval"] = v_23_auto
  eval = v_23_auto
end
local with_session_ids
do
  local v_23_auto
  local function with_session_ids0(cb)
    local function _22_(_)
      local function _23_(msg)
        local sessions = a.get(msg, "sessions")
        if ("table" == type(sessions)) then
          table.sort(sessions)
        end
        return cb(sessions)
      end
      return send({op = "ls-sessions"}, _23_)
    end
    return with_conn_or_warn(_22_)
  end
  v_23_auto = with_session_ids0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-session-ids"] = v_23_auto
  with_session_ids = v_23_auto
end
local pretty_session_type
do
  local v_23_auto
  do
    local v_25_auto
    local function pretty_session_type0(st)
      local function _25_()
        if a["string?"](st) then
          return (st .. "?")
        else
          return "https://conjure.fun/no-env"
        end
      end
      return a.get({clj = "Clojure", cljr = "ClojureCLR", cljs = "ClojureScript", timeout = "Timeout", unknown = "Unknown"}, st, _25_())
    end
    v_25_auto = pretty_session_type0
    _1_["pretty-session-type"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["pretty-session-type"] = v_23_auto
  pretty_session_type = v_23_auto
end
local session_type
do
  local v_23_auto
  do
    local v_25_auto
    local function session_type0(id, cb)
      local timeout
      local function _26_()
        return cb("timeout")
      end
      timeout = timer.defer(_26_, 300)
      local function _27_(msgs)
        timer.destroy(timeout)
        local st
        local function _28_(_241)
          return a.get(_241, "value")
        end
        st = a.some(_28_, msgs)
        local function _29_()
          if st then
            return str.trim(st)
          end
        end
        return cb(_29_())
      end
      return send({code = ("#?(" .. str.join(" ", {":clj 'clj", ":cljs 'cljs", ":cljr 'cljr", ":default 'unknown"}) .. ")"), op = "eval", session = id}, nrepl["with-all-msgs-fn"](_27_))
    end
    v_25_auto = session_type0
    _1_["session-type"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["session-type"] = v_23_auto
  session_type = v_23_auto
end
local enrich_session_id
do
  local v_23_auto
  do
    local v_25_auto
    local function enrich_session_id0(id, cb)
      local function _30_(st)
        local t = {["pretty-type"] = pretty_session_type(st), id = id, name = uuid.pretty(id), type = st}
        local function _31_()
          return (t.name .. " (" .. t["pretty-type"] .. ")")
        end
        a.assoc(t, "str", _31_)
        return cb(t)
      end
      return session_type(id, _30_)
    end
    v_25_auto = enrich_session_id0
    _1_["enrich-session-id"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["enrich-session-id"] = v_23_auto
  enrich_session_id = v_23_auto
end
local with_sessions
do
  local v_23_auto
  do
    local v_25_auto
    local function with_sessions0(cb)
      local function _32_(sess_ids)
        local rich = {}
        local total = a.count(sess_ids)
        if (0 == total) then
          return cb({})
        else
          local function _33_(id)
            local function _34_(t)
              table.insert(rich, t)
              if (total == a.count(rich)) then
                local function _35_(_241, _242)
                  return (a.get(_241, "name") < a.get(_242, "name"))
                end
                table.sort(rich, _35_)
                return cb(rich)
              end
            end
            return enrich_session_id(id, _34_)
          end
          return a["run!"](_33_, sess_ids)
        end
      end
      return with_session_ids(_32_)
    end
    v_25_auto = with_sessions0
    _1_["with-sessions"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-sessions"] = v_23_auto
  with_sessions = v_23_auto
end
local clone_session
do
  local v_23_auto
  do
    local v_25_auto
    local function clone_session0(session)
      local function _38_(msgs)
        local function _39_(_241)
          return a.get(_241, "new-session")
        end
        return enrich_session_id(a.some(_39_, msgs), assume_session)
      end
      return send({op = "clone", session = a.get(session, "id")}, nrepl["with-all-msgs-fn"](_38_))
    end
    v_25_auto = clone_session0
    _1_["clone-session"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["clone-session"] = v_23_auto
  clone_session = v_23_auto
end
local assume_or_create_session
do
  local v_23_auto
  do
    local v_25_auto
    local function assume_or_create_session0()
      local function _40_(sessions)
        if a["empty?"](sessions) then
          return clone_session()
        else
          return assume_session(a.first(sessions))
        end
      end
      return with_sessions(_40_)
    end
    v_25_auto = assume_or_create_session0
    _1_["assume-or-create-session"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["assume-or-create-session"] = v_23_auto
  assume_or_create_session = v_23_auto
end
local eval_preamble
do
  local v_23_auto
  local function eval_preamble0(cb)
    local function _42_()
      if cb then
        return nrepl["with-all-msgs-fn"](cb)
      end
    end
    return send({code = ("(ns conjure.internal" .. "  (:require [clojure.pprint :as pp]))" .. "(defn pprint [val w opts]" .. "  (apply pp/write val" .. "    (mapcat identity (assoc opts :stream w))))"), op = "eval"}, _42_())
  end
  v_23_auto = eval_preamble0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-preamble"] = v_23_auto
  eval_preamble = v_23_auto
end
local capture_describe
do
  local v_23_auto
  local function capture_describe0()
    local function _43_(msg)
      return a.assoc(state.get("conn"), "describe", msg)
    end
    return send({op = "describe"}, _43_)
  end
  v_23_auto = capture_describe0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["capture-describe"] = v_23_auto
  capture_describe = v_23_auto
end
local with_conn_and_op_or_warn
do
  local v_23_auto
  do
    local v_25_auto
    local function with_conn_and_op_or_warn0(op, f, opts)
      local function _44_(conn)
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
      return with_conn_or_warn(_44_, opts)
    end
    v_25_auto = with_conn_and_op_or_warn0
    _1_["with-conn-and-op-or-warn"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-conn-and-op-or-warn"] = v_23_auto
  with_conn_and_op_or_warn = v_23_auto
end
local connect
do
  local v_23_auto
  do
    local v_25_auto
    local function connect0(_48_)
      local _arg_49_ = _48_
      local cb = _arg_49_["cb"]
      local host = _arg_49_["host"]
      local port = _arg_49_["port"]
      local port_file_path = _arg_49_["port_file_path"]
      if state.get("conn") then
        disconnect()
      end
      local function _51_(result)
        return ui["display-result"](result)
      end
      local function _52_(err)
        if err then
          return display_conn_status(err)
        else
          return disconnect()
        end
      end
      local function _54_(err)
        display_conn_status(err)
        return disconnect()
      end
      local function _55_(msg)
        if msg.status["unknown-session"] then
          log.append({"; Unknown session, correcting"})
          assume_or_create_session()
        end
        if msg.status["namespace-not-found"] then
          return log.append({("; Namespace not found: " .. msg.ns)})
        end
      end
      local function _58_()
        display_conn_status("connected")
        capture_describe()
        assume_or_create_session()
        return eval_preamble(cb)
      end
      return a.assoc(state.get(), "conn", a["merge!"](nrepl.connect({["default-callback"] = _51_, ["on-error"] = _52_, ["on-failure"] = _54_, ["on-message"] = _55_, ["on-success"] = _58_, host = host, port = port}), {["seen-ns"] = {}, port_file_path = port_file_path}))
    end
    v_25_auto = connect0
    _1_["connect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect"] = v_23_auto
  connect = v_23_auto
end
return nil