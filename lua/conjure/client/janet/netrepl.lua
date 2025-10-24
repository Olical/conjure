-- [nfnl] fnl/conjure/client/janet/netrepl.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local mapping = autoload("conjure.mapping")
local remote = autoload("conjure.remote.netrepl")
local text = autoload("conjure.text")
local ts = autoload("conjure.tree-sitter")
local M = define("conjure.client.janet.netrepl")
M["buf-suffix"] = ".janet"
M["comment-prefix"] = "# "
M["form-node?"] = ts["node-surrounded-by-form-pair-chars?"]
M["comment-node?"] = ts["lisp-comment-node?"]
config.merge({client = {janet = {netrepl = {connection = {default_host = "127.0.0.1", default_port = "9365"}}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {janet = {netrepl = {mapping = {connect = "cc", disconnect = "cd"}}}}})
else
end
local state
local function _3_()
  return {conn = nil}
end
state = client["new-state"](_3_)
local function with_conn_or_warn(f, opts)
  local conn = state("conn")
  if conn then
    return f(conn)
  else
    return log.append({"# No connection"})
  end
end
local function connected_3f()
  if state("conn") then
    return true
  else
    return false
  end
end
local function display_conn_status(status)
  local function _6_(conn)
    return log.append({("# " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
  end
  return with_conn_or_warn(_6_)
end
M.disconnect = function()
  local function _7_(conn)
    conn.destroy()
    display_conn_status("disconnected")
    return core.assoc(state(), "conn", nil)
  end
  return with_conn_or_warn(_7_)
end
local function send(opts)
  local msg = opts.msg
  local cb = opts.cb
  local row = opts.row
  local col = opts.col
  local file_path = opts["file-path"]
  local function _8_(conn)
    remote.send(conn, ("\255(parser/where (dyn :parser) " .. row .. " " .. col .. ")"))
    remote.send(conn, ("\254source \"" .. string.gsub(file_path, "\\", "\\\\") .. "\""), nil, true)
    return remote.send(conn, msg, cb, true)
  end
  return with_conn_or_warn(_8_)
end
M.connect = function(opts)
  local opts0 = (opts or {})
  local host = (opts0.host or config["get-in"]({"client", "janet", "netrepl", "connection", "default_host"}))
  local port = (opts0.port or config["get-in"]({"client", "janet", "netrepl", "connection", "default_port"}))
  if state("conn") then
    M.disconnect()
  else
  end
  local conn
  local function _10_(err)
    display_conn_status(err)
    return M.disconnect()
  end
  local function _11_()
    core.assoc(state(), "conn", conn)
    return display_conn_status("connected")
  end
  local function _12_(err)
    if err then
      return display_conn_status(err)
    else
      return M.disconnect()
    end
  end
  conn = remote.connect({host = host, port = port, ["on-failure"] = _10_, ["on-success"] = _11_, ["on-error"] = _12_})
  return nil
end
local function try_ensure_conn()
  if not connected_3f() then
    return M.connect({["silent?"] = true})
  else
    return nil
  end
end
M["eval-str"] = function(opts)
  try_ensure_conn()
  local function _15_(msg)
    local clean = text["trim-last-newline"](msg)
    if opts["on-result"] then
      opts["on-result"](text["strip-ansi-escape-sequences"](clean))
    else
    end
    if not opts["passive?"] then
      return log.append(text["split-lines"](clean))
    else
      return nil
    end
  end
  return send({msg = (opts.code .. "\n"), cb = _15_, row = core["get-in"](opts.range, {"start", 1}, 1), col = core["get-in"](opts.range, {"start", 2}, 1), ["file-path"] = opts["file-path"]})
end
M["doc-str"] = function(opts)
  try_ensure_conn()
  local function _18_(_241)
    return ("(doc " .. _241 .. ")")
  end
  return M["eval-str"](core.update(opts, "code", _18_))
end
M["eval-file"] = function(opts)
  try_ensure_conn()
  return M["eval-str"](core.assoc(opts, "code", ("(do (dofile \"" .. opts["file-path"] .. "\" :env (fiber/getenv (fiber/current))) nil)")))
end
M["on-filetype"] = function()
  local function _19_()
    return M.disconnect()
  end
  mapping.buf("JanetDisconnect", config["get-in"]({"client", "janet", "netrepl", "mapping", "disconnect"}), _19_, {desc = "Disconnect from the REPL"})
  local function _20_()
    return M.connect()
  end
  return mapping.buf("JanetConnect", config["get-in"]({"client", "janet", "netrepl", "mapping", "connect"}), _20_, {desc = "Connect to a REPL"})
end
M["on-load"] = function()
  return M.connect({})
end
M["on-exit"] = function()
  return M.disconnect()
end
return M
