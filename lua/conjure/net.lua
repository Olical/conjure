-- [nfnl] fnl/conjure/net.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local M = define("conjure.net", {})
M.resolve = function(host)
  if (host == "::") then
    return host
  else
    local function _2_(_241)
      return ("inet" == core.get(_241, "family"))
    end
    return core.get(core.first(core.filter(_2_, vim.uv.getaddrinfo(host))), "addr")
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
  state["sock-drawer"] = core.filter(_5_, state["sock-drawer"])
  return nil
end
M.connect = function(_6_)
  local host = _6_["host"]
  local port = _6_["port"]
  local cb = _6_["cb"]
  local sock = vim.uv.new_tcp()
  local resolved_host = M.resolve(host)
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
  return core["run!"](destroy_sock, state["sock-drawer"])
end
local group = vim.api.nvim_create_augroup("conjure-net-sock-cleanup", {})
vim.api.nvim_create_autocmd("VimLeavePre", {group = group, pattern = "*", callback = destroy_all_socks})
return M
