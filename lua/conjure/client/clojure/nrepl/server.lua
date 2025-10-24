-- [nfnl] fnl/conjure/client/clojure/nrepl/server.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local debugger = autoload("conjure.client.clojure.nrepl.debugger")
local extract = autoload("conjure.extract")
local log = autoload("conjure.log")
local nrepl = autoload("conjure.remote.nrepl")
local state = autoload("conjure.client.clojure.nrepl.state")
local str = autoload("conjure.nfnl.string")
local timer = autoload("conjure.timer")
local ui = autoload("conjure.client.clojure.nrepl.ui")
local uuid = autoload("conjure.uuid")
local fs = autoload("conjure.nfnl.fs")
local resources = autoload("conjure.resources")
local M = define("conjure.client.clojure.nrepl.server")
M["with-conn-or-warn"] = function(f, opts)
  local conn = state.get("conn")
  if conn then
    return f(conn)
  else
    if not core.get(opts, "silent?") then
      log.append({"; No connection"})
    else
    end
    if core.get(opts, "else") then
      return opts["else"]()
    else
      return nil
    end
  end
end
M["connected?"] = function()
  if state.get("conn") then
    return true
  else
    return false
  end
end
M.send = function(msg, cb)
  local function _6_(conn)
    return conn.send(msg, cb)
  end
  return M["with-conn-or-warn"](_6_)
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
  return M["with-conn-or-warn"](_7_)
end
M.disconnect = function()
  local function _9_(conn)
    conn.destroy()
    display_conn_status("disconnected")
    return core.assoc(state.get(), "conn", nil)
  end
  return M["with-conn-or-warn"](_9_)
end
M["close-session"] = function(session, cb)
  return M.send({op = "close", session = core.get(session, "id")}, cb)
end
M["assume-session"] = function(session)
  core.assoc(state.get("conn"), "session", core.get(session, "id"))
  return log.append({str.join({"; Assumed session: ", session.str()})}, {["break?"] = true})
end
M["un-comment"] = function(code)
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
M.eval = function(opts, cb)
  local function _12_(_)
    local _13_
    do
      local tmp_3_ = core["get-in"](opts, {"range", "start", 2})
      if (nil ~= tmp_3_) then
        _13_ = core.inc(tmp_3_)
      else
        _13_ = nil
      end
    end
    return M.send(core.merge({op = "eval", ns = opts.context, code = M["un-comment"](opts.code), file = opts["file-path"], line = core["get-in"](opts, {"range", "start", 1}), column = _13_, session = opts.session}, print_opts()), cb)
  end
  return M["with-conn-or-warn"](_12_)
end
M["load-file"] = function(opts, cb)
  local function _15_(_)
    return M.send(core.merge({op = "load-file", file = opts.code, ["file-name"] = fs.filename(opts["file-path"]), ["file-path"] = opts["file-path"], session = opts.session}, print_opts()), cb)
  end
  return M["with-conn-or-warn"](_15_)
end
local function with_session_ids(cb)
  local function _16_(_)
    local function _17_(msg)
      local sessions = core.get(msg, "sessions")
      if ("table" == type(sessions)) then
        table.sort(sessions)
      else
      end
      return cb(sessions)
    end
    return M.send({op = "ls-sessions", session = "no-session"}, _17_)
  end
  return M["with-conn-or-warn"](_16_)
end
M["pretty-session-type"] = function(st)
  return core.get({clj = "Clojure", cljs = "ClojureScript", cljr = "ClojureCLR"}, st, "Unknown https://github.com/Olical/conjure/wiki/Frequently-asked-questions#what-does-unknown-mean-in-the-log-when-connecting-to-a-clojure-nrepl")
end
M["session-type"] = function(id, cb)
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
      return core.get(_241, "value")
    end
    st = core.some(_22_, msgs)
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
  return M.send({op = "eval", code = ("#?(" .. str.join(" ", {":clj 'clj", ":cljs 'cljs", ":cljr 'cljr", ":default 'unknown"}) .. ")"), session = id}, nrepl["with-all-msgs-fn"](_21_))
end
M["enrich-session-id"] = function(id, cb)
  local function _25_(st)
    local t = {id = id, type = st, ["pretty-type"] = M["pretty-session-type"](st), name = uuid.pretty(id)}
    local function _26_()
      return str.join({t.name, " (", t["pretty-type"], ")"})
    end
    core.assoc(t, "str", _26_)
    return cb(t)
  end
  return M["session-type"](id, _25_)
end
M["with-sessions"] = function(cb)
  local function _27_(sess_ids)
    local rich = {}
    local total = core.count(sess_ids)
    if (0 == total) then
      return cb({})
    else
      local function _28_(id)
        log.dbg("with-sessions id for enrichment", id)
        if id then
          local function _29_(t)
            table.insert(rich, t)
            if (total == core.count(rich)) then
              local function _30_(_241, _242)
                return (core.get(_241, "name") < core.get(_242, "name"))
              end
              table.sort(rich, _30_)
              return cb(rich)
            else
              return nil
            end
          end
          return M["enrich-session-id"](id, _29_)
        else
          return nil
        end
      end
      return core["run!"](_28_, sess_ids)
    end
  end
  return with_session_ids(_27_)
end
M["clone-session"] = function(session)
  local function _34_(msgs)
    local session_id
    local function _35_(_241)
      return core.get(_241, "new-session")
    end
    session_id = core.some(_35_, msgs)
    log.dbg("clone-session id for enrichment", id)
    if session_id then
      return M["enrich-session-id"](session_id, M["assume-session"])
    else
      return nil
    end
  end
  return M.send({op = "clone", session = core.get(session, "id"), ["client-name"] = "Conjure"}, nrepl["with-all-msgs-fn"](_34_))
end
M["assume-or-create-session"] = function()
  core.assoc(state.get("conn"), "session", nil)
  local function _37_(sessions)
    if core["empty?"](sessions) then
      return M["clone-session"]()
    else
      return M["assume-session"](core.first(sessions))
    end
  end
  return M["with-sessions"](_37_)
end
local function eval_preamble(cb)
  local queue_size = config["get-in"]({"client", "clojure", "nrepl", "tap", "queue_size"})
  local pretty_print_test_failures_3f = config["get-in"]({"client", "clojure", "nrepl", "test", "pretty_print_test_failures"})
  local function _39_()
    if pretty_print_test_failures_3f then
      return "true"
    else
      return "false"
    end
  end
  local function _40_()
    if cb then
      return nrepl["with-all-msgs-fn"](cb)
    else
      return nil
    end
  end
  return M.send({op = "eval", code = string.gsub(string.gsub(resources["get-resource-contents"]("client/clojure/preamble.cljc"), ":conjure%.template/queue%-size", queue_size), ":conjure%.template/pretty%-print%-test%-failures%?", _39_())}, _40_())
end
local function capture_describe()
  local function _41_(msg)
    return core.assoc(state.get("conn"), "describe", msg)
  end
  return M.send({op = "describe"}, _41_)
end
M["with-conn-and-ops-or-warn"] = function(op_names, f, opts)
  local function _42_(conn)
    local found_ops
    local function _43_(acc, op)
      if core["get-in"](conn, {"describe", "ops", op}) then
        return core.assoc(acc, op, true)
      else
        return acc
      end
    end
    found_ops = core.reduce(_43_, {}, op_names)
    if not core["empty?"](found_ops) then
      return f(conn, found_ops)
    else
      if not core.get(opts, "silent?") then
        log.append({"; None of the required operations are supported by this nREPL.", "; Ensure your nREPL is up to date.", "; Consider installing or updating the CIDER middleware.", "; https://docs.cider.mx/cider-nrepl/usage.html"})
      else
      end
      if core.get(opts, "else") then
        return opts["else"]()
      else
        return nil
      end
    end
  end
  return M["with-conn-or-warn"](_42_, opts)
end
M["handle-input-request"] = function(msg)
  return M.send({op = "stdin", stdin = ((extract.prompt("Input required: ") or "") .. "\n"), session = msg.session})
end
M.connect = function(_48_)
  local host = _48_.host
  local port = _48_.port
  local cb = _48_.cb
  local port_file_path = _48_.port_file_path
  local connect_opts = _48_["connect-opts"]
  if state.get("conn") then
    M.disconnect()
  else
  end
  local function _50_(err)
    display_conn_status(err)
    return M.disconnect()
  end
  local function _51_()
    display_conn_status("connected")
    capture_describe()
    M["assume-or-create-session"]()
    return eval_preamble(cb)
  end
  local function _52_(err)
    if err then
      return display_conn_status(err)
    else
      return M.disconnect()
    end
  end
  local function _54_(msg)
    if msg.status["unknown-session"] then
      log.append({"; Unknown session, correcting"})
      M["assume-or-create-session"]()
    else
    end
    if msg.status["namespace-not-found"] then
      return log.append({str.join({"; Namespace not found: ", msg.ns})})
    else
      return nil
    end
  end
  local function _57_(msg)
    if msg.status["need-input"] then
      client.schedule(M["handle-input-request"], msg)
    else
    end
    if msg.status["need-debug-input"] then
      return client.schedule(debugger["handle-input-request"], msg)
    else
      return nil
    end
  end
  local function _60_(msg)
    return ui["display-result"](msg)
  end
  return core.assoc(state.get(), "conn", core["merge!"](nrepl.connect(core.merge({host = host, port = port, ["on-failure"] = _50_, ["on-success"] = _51_, ["on-error"] = _52_, ["on-message"] = _54_, ["side-effect-callback"] = _57_, ["default-callback"] = _60_}, connect_opts)), {["seen-ns"] = {}, port_file_path = port_file_path}))
end
return M
