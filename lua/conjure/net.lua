local _2afile_2a = "fnl/conjure/net.fnl"
local _2amodule_name_2a = "conjure.net"
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
local a, bridge, nvim, _ = autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.aniseed.nvim"), nil
_2amodule_locals_2a["a"] = a
_2amodule_locals_2a["bridge"] = bridge
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["_"] = _
local function resolve(host)
  if (host == "::") then
    return host
  else
    local function _1_(_241)
      return ("inet" == a.get(_241, "family"))
    end
    return a.get(a.first(a.filter(_1_, vim.loop.getaddrinfo(host))), "addr")
  end
end
_2amodule_2a["resolve"] = resolve
local state = ((_2amodule_2a).state or {["sock-drawer"] = {}})
do end (_2amodule_locals_2a)["state"] = state
local function destroy_sock(sock)
  if not sock:is_closing() then
    sock:read_stop()
    sock:shutdown()
    sock:close()
  else
  end
  local function _4_(_241)
    return (sock ~= _241)
  end
  state["sock-drawer"] = a.filter(_4_, state["sock-drawer"])
  return nil
end
_2amodule_locals_2a["destroy-sock"] = destroy_sock
local function connect(_5_)
  local _arg_6_ = _5_
  local host = _arg_6_["host"]
  local port = _arg_6_["port"]
  local cb = _arg_6_["cb"]
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
_2amodule_2a["connect"] = connect
local function destroy_all_socks()
  return a["run!"](destroy_sock, state["sock-drawer"])
end
_2amodule_2a["destroy-all-socks"] = destroy_all_socks
do
  nvim.ex.augroup("conjure-net-sock-cleanup")
  nvim.ex.autocmd_()
  nvim.ex.autocmd("VimLeavePre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "destroy-all-socks" .. "']()"))
  nvim.ex.augroup("END")
end
return _2amodule_2a