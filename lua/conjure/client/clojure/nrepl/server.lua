-- [nfnl] fnl/conjure/client/clojure/nrepl/server.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local auto_repl = autoload("conjure.client.clojure.nrepl.auto-repl")
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
M["with-conn-ready-or-queue"] = function(f, opts)
  local function _6_(conn)
    if conn["ready?"] then
      return f(conn)
    else
      log.dbg("connection not ready, queueing eval")
      return table.insert(conn["pending-evals"], f)
    end
  end
  return M["with-conn-or-warn"](_6_, opts)
end
local function drain_pending_evals()
  local conn = state.get("conn")
  if (conn and not core["empty?"](conn["pending-evals"])) then
    log.dbg("setup: draining pending evals", core.count(conn["pending-evals"]))
    local pending = conn["pending-evals"]
    conn["pending-evals"] = {}
    local function _8_(f)
      return f(conn)
    end
    return core["run!"](_8_, pending)
  else
    return nil
  end
end
M["mark-ready!"] = function(source)
  local conn = state.get("conn")
  if (conn and not conn["ready?"]) then
    conn["ready?"] = true
    timer.destroy(conn["setup-timeout"])
    conn["setup-timeout"] = nil
    log.dbg("setup: connection ready", (source or ""))
    return drain_pending_evals()
  else
    return nil
  end
end
M.send = function(msg, cb)
  local function _11_(conn)
    return conn.send(msg, cb)
  end
  return M["with-conn-or-warn"](_11_)
end
local function display_conn_status(status)
  local function _12_(conn)
    local function _13_()
      if conn.port_file_path then
        return str.join({": ", conn.port_file_path})
      else
        return nil
      end
    end
    return log.append({str.join({"; ", conn.host, ":", conn.port, " (", status, ")", _13_()})}, {["break?"] = true})
  end
  return M["with-conn-or-warn"](_12_)
end
M.disconnect = function()
  local function _14_(conn)
    timer.destroy(conn["setup-timeout"])
    conn.destroy()
    display_conn_status("disconnected")
    return core.assoc(state.get(), "conn", nil)
  end
  return M["with-conn-or-warn"](_14_)
end
M["close-session"] = function(session, cb)
  return M.send({op = "close", session = core.get(session, "id")}, cb)
end
M["assume-session"] = function(session, cb)
  core.assoc(state.get("conn"), "session", core.get(session, "id"))
  log.append({str.join({"; Assumed session: ", session.str()})}, {["break?"] = true})
  if cb then
    return cb()
  else
    return nil
  end
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
  local function _18_(_)
    local _19_
    do
      local tmp_3_ = core["get-in"](opts, {"range", "start", 2})
      if (nil ~= tmp_3_) then
        _19_ = core.inc(tmp_3_)
      else
        _19_ = nil
      end
    end
    return M.send(core.merge({op = "eval", ns = opts.context, code = M["un-comment"](opts.code), file = opts["file-path"], line = core["get-in"](opts, {"range", "start", 1}), column = _19_, session = opts.session}, print_opts()), cb)
  end
  return M["with-conn-or-warn"](_18_)
end
M["load-file"] = function(opts, cb)
  local function _21_(_)
    return M.send(core.merge({op = "load-file", file = opts.code, ["file-name"] = fs.filename(opts["file-path"]), ["file-path"] = opts["file-path"], session = opts.session}, print_opts()), cb)
  end
  return M["with-conn-or-warn"](_21_)
end
local function with_session_ids(cb)
  local function _22_(_)
    local function _23_(msg)
      local sessions = core.get(msg, "sessions")
      if ("table" == type(sessions)) then
        table.sort(sessions)
      else
      end
      return cb(sessions)
    end
    return M.send({op = "ls-sessions", session = "no-session"}, _23_)
  end
  return M["with-conn-or-warn"](_22_)
end
M["pretty-session-type"] = function(st)
  return core.get({clj = "Clojure", cljs = "ClojureScript", cljr = "ClojureCLR"}, st, "Unknown https://github.com/Olical/conjure/wiki/Frequently-asked-questions#what-does-unknown-mean-in-the-log-when-connecting-to-a-clojure-nrepl")
end
M["session-type"] = function(id, cb)
  local state0 = {["done?"] = false}
  local function _25_()
    if not state0["done?"] then
      state0["done?"] = true
      return cb("unknown")
    else
      return nil
    end
  end
  timer.defer(_25_, 200)
  local function _27_(msgs)
    local st
    local function _28_(_241)
      return core.get(_241, "value")
    end
    st = core.some(_28_, msgs)
    if not state0["done?"] then
      state0["done?"] = true
      local function _29_()
        if st then
          return str.trim(st)
        else
          return nil
        end
      end
      return cb(_29_())
    else
      return nil
    end
  end
  return M.send({op = "eval", code = ("#?(" .. str.join(" ", {":clj 'clj", ":cljs 'cljs", ":cljr 'cljr", ":default 'unknown"}) .. ")"), session = id}, nrepl["with-all-msgs-fn"](_27_))
end
M["enrich-session-id"] = function(id, cb)
  local function _31_(st)
    local t = {id = id, type = st, ["pretty-type"] = M["pretty-session-type"](st), name = uuid.pretty(id)}
    local function _32_()
      return str.join({t.name, " (", t["pretty-type"], ")"})
    end
    core.assoc(t, "str", _32_)
    return cb(t)
  end
  return M["session-type"](id, _31_)
end
M["with-sessions"] = function(cb)
  local function _33_(sess_ids)
    local rich = {}
    local total = core.count(sess_ids)
    if (0 == total) then
      return cb({})
    else
      local function _34_(id)
        log.dbg("with-sessions id for enrichment", id)
        if id then
          local function _35_(t)
            table.insert(rich, t)
            if (total == core.count(rich)) then
              local function _36_(_241, _242)
                return (core.get(_241, "name") < core.get(_242, "name"))
              end
              table.sort(rich, _36_)
              return cb(rich)
            else
              return nil
            end
          end
          return M["enrich-session-id"](id, _35_)
        else
          return nil
        end
      end
      return core["run!"](_34_, sess_ids)
    end
  end
  return with_session_ids(_33_)
end
M["clone-session"] = function(session, cb)
  local function _40_(msgs)
    local session_id
    local function _41_(_241)
      return core.get(_241, "new-session")
    end
    session_id = core.some(_41_, msgs)
    log.dbg("clone-session id for enrichment", session_id)
    if session_id then
      local function _42_(enriched_session)
        return M["assume-session"](enriched_session, cb)
      end
      return M["enrich-session-id"](session_id, _42_)
    else
      return nil
    end
  end
  return M.send({op = "clone", session = core.get(session, "id"), ["client-name"] = "Conjure"}, nrepl["with-all-msgs-fn"](_40_))
end
M["assume-or-create-session"] = function(cb)
  log.dbg("assuming or creating session")
  core.assoc(state.get("conn"), "session", nil)
  local function _44_(sessions)
    if core["empty?"](sessions) then
      log.dbg("no sessions found, cloning")
      return M["clone-session"](nil, cb)
    else
      log.dbg("assuming first session")
      return M["assume-session"](core.first(sessions), cb)
    end
  end
  return M["with-sessions"](_44_)
end
local function eval_preamble(cb)
  log.dbg("setup: evaluating preamble")
  local queue_size = config["get-in"]({"client", "clojure", "nrepl", "tap", "queue_size"})
  local pretty_print_test_failures_3f = config["get-in"]({"client", "clojure", "nrepl", "test", "pretty_print_test_failures"})
  local function _46_()
    if pretty_print_test_failures_3f then
      return "true"
    else
      return "false"
    end
  end
  local function _47_(msgs)
    log.dbg("setup: preamble evaluated")
    if cb then
      return cb(msgs)
    else
      return nil
    end
  end
  return M.send({op = "eval", code = string.gsub(string.gsub(resources["get-resource-contents"]("client/clojure/preamble.cljc"), ":conjure%.template/queue%-size", queue_size), ":conjure%.template/pretty%-print%-test%-failures%?", _46_())}, nrepl["with-all-msgs-fn"](_47_))
end
local function capture_describe(cb)
  log.dbg("setup: capturing describe")
  local function _49_(msgs)
    core.assoc(state.get("conn"), "describe", core.first(msgs))
    log.dbg("setup: describe captured")
    if cb then
      return cb()
    else
      return nil
    end
  end
  return M.send({op = "describe"}, nrepl["with-all-msgs-fn"](_49_))
end
M["with-conn-and-ops-or-warn"] = function(op_names, f, opts)
  local function _51_(conn)
    local found_ops
    local function _52_(acc, op)
      if core["get-in"](conn, {"describe", "ops", op}) then
        return core.assoc(acc, op, true)
      else
        return acc
      end
    end
    found_ops = core.reduce(_52_, {}, op_names)
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
  return M["with-conn-or-warn"](_51_, opts)
end
M["handle-input-request"] = function(msg)
  return M.send({op = "stdin", stdin = ((extract.prompt("Input required: ") or "") .. "\n"), session = msg.session})
end
M.connect = function(_57_)
  local host = _57_.host
  local port = _57_.port
  local cb = _57_.cb
  local port_file_path = _57_.port_file_path
  local connect_opts = _57_["connect-opts"]
  if state.get("conn") then
    M.disconnect()
  else
  end
  do
    local auto_repl_port = tonumber(state.get("auto-repl-port"))
    if (auto_repl_port and (port ~= auto_repl_port) and config["get-in"]({"client", "clojure", "nrepl", "connection", "auto_repl", "stop_on_new_conn"})) then
      auto_repl["stop-auto-repl-proc"]()
    else
    end
  end
  local function _60_(err)
    display_conn_status(err)
    return M.disconnect()
  end
  local function _61_()
    log.dbg("setup: connection established, beginning setup chain")
    display_conn_status("connected")
    do
      local setup_conn = state.get("conn")
      local function _62_()
        if ((setup_conn == state.get("conn")) and not setup_conn["ready?"]) then
          log.append({"; Warning: connection setup timed out, forcing ready state"}, {["break?"] = true})
          return M["mark-ready!"]("timeout")
        else
          return nil
        end
      end
      setup_conn["setup-timeout"] = timer.defer(_62_, 10000)
    end
    local function _64_()
      local function _65_()
        local function _66_()
          M["mark-ready!"]()
          if cb then
            return cb()
          else
            return nil
          end
        end
        return eval_preamble(_66_)
      end
      return M["assume-or-create-session"](_65_)
    end
    return capture_describe(_64_)
  end
  local function _68_(err)
    if err then
      return display_conn_status(err)
    else
      return M.disconnect()
    end
  end
  local function _70_(msg)
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
  local function _73_(msg)
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
  local function _76_(msg)
    return ui["display-result"](msg)
  end
  return core.assoc(state.get(), "conn", core["merge!"](nrepl.connect(core.merge({host = host, port = port, ["on-failure"] = _60_, ["on-success"] = _61_, ["on-error"] = _68_, ["on-message"] = _70_, ["side-effect-callback"] = _73_, ["default-callback"] = _76_}, connect_opts)), {["seen-ns"] = {}, port_file_path = port_file_path, ["pending-evals"] = {}, ["setup-timeout"] = nil, ["ready?"] = false}))
end
return M
