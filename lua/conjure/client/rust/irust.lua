local _2afile_2a = "fnl/conjure/client/rust/irust.fnl"
local _2amodule_name_2a = "conjure.client.rust.irust"
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
local a, client, config, log, nvim, promise = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.promise")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["promise"] = promise
local buf_suffix = ".rs"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "// "
_2amodule_2a["comment-prefix"] = comment_prefix
config.merge({client = {rust = {irust = {connection = {default_host = "127.0.0.1", default_port = "9000"}}}}})
local function handle_message(err, chunk)
  a.println("handle-message", chunk, err)
  if (err or not chunk) then
    return log.dbg("receive error", err)
  else
    local function _1_(msg)
      return log.append({msg})
    end
    return a["run!"](_1_, chunk)
  end
end
_2amodule_2a["handle-message"] = handle_message
local function destroy_sock(sock)
  if not sock:is_closing() then
    sock:shutdown()
    return sock:close()
  else
    return nil
  end
end
_2amodule_2a["destroy-sock"] = destroy_sock
local function tcp_send(sock, msg, cb, prompt_3f)
  sock:read_start(client["schedule-wrap"](handle_message))
  sock:write(msg)
  sock:read_stop()
  return nil
end
_2amodule_2a["tcp-send"] = tcp_send
local function connect(opts, callback)
  local opts0 = (opts or {})
  local host = (opts0.host or config["get-in"]({"client", "rust", "irust", "connection", "default_host"}))
  local port = (opts0.port or config["get-in"]({"client", "rust", "irust", "connection", "default_port"}))
  local sock = vim.loop.new_tcp()
  sock:connect(host, port, callback)
  return sock
end
_2amodule_2a["connect"] = connect
local function send(msg)
  local p = promise.new()
  local conn
  local function _4_(err)
    if err then
      log.append({"error:", err})
      return promise.deliver(p, "error")
    else
      log.dbg("success:")
      return promise.deliver(p, "success")
    end
  end
  conn = connect({}, _4_)
  do end (_2amodule_2a)["conn"] = conn
  promise.await(p)
  if (promise.close(p) == "success") then
    local function _6_(a0)
      return a0.println("send:", a0)
    end
    tcp_send(conn, msg, _6_)
  else
  end
  return destroy_sock(conn)
end
_2amodule_locals_2a["send"] = send
local function encode(msg)
  local n = a.count(msg)
  return (msg .. string.char("10"))
end
_2amodule_2a["encode"] = encode
local conn
local function _8_(err)
  if err then
    return a.println("error:", err)
  else
    return a.println("success:")
  end
end
conn = connect({}, _8_)
do end (_2amodule_2a)["conn"] = conn
local function _10_(a0)
  return a0.println("send:", a0)
end
tcp_send(conn, ":reset\n", _10_)
local function _11_(a0)
  return a0.println("send:", a0)
end
tcp_send(conn, ":reset", _11_)
destroy_sock(conn)
return _2amodule_2a