-- [nfnl] Compiled from fnl/conjure/net.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local bridge = autoload("conjure.bridge")
local function resolve(host)
  if (host == "::") then
    return host
  else
    local function _2_(_241)
      return ("inet" == a.get(_241, "family"))
    end
    return a.get(a.first(a.filter(_2_, vim.loop.getaddrinfo(host))), "addr")
  end
end
local state = {["sock-drawer"] = {}}
local function destroy_sock(sock)
  if not sock:is_closing() then
    sock:read_stop()
    sock:shutdown()
    sock:close()
  else
  end
  local function _5_(_241)
    return (sock ~= _241)
  end
  state["sock-drawer"] = a.filter(_5_, state["sock-drawer"])
  return nil
end
local function connect(_6_)
  local host = _6_["host"]
  local port = _6_["port"]
  local cb = _6_["cb"]
  local sock = vim.loop.new_tcp()
  local resolved_host = resolve(host)
  if not resolved_host then
    error("Failed to resolve host for Conjure connection")
  else
  end
  sock:connect(resolved_host, port, cb)
  table.insert(state["sock-drawer"], sock)
  local function _8_()
    return destroy_sock(sock)
  end
  return {sock = sock, ["resolved-host"] = resolved_host, destroy = _8_, host = host, port = port}
end
local function destroy_all_socks()
  return a["run!"](destroy_sock, state["sock-drawer"])
end
local group = vim.api.nvim_create_augroup("conjure-net-sock-cleanup", {})
vim.api.nvim_create_autocmd("VimLeavePre", {group = group, pattern = "*", callback = destroy_all_socks})
return {resolve = resolve, connect = connect}
