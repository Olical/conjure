local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.net"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.bridge"), require("conjure.aniseed.nvim")}
local a = _local_0_[1]
local bridge = _local_0_[2]
local nvim = _local_0_[3]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.net"
do local _ = ({nil, _0_0, {{nil}, nil, nil, nil}})[2] end
local resolve
do
  local v_0_
  local function resolve0(host)
    if (host == "::") then
      return host
    else
      local function _1_(_241)
        return ("inet" == a.get(_241, "family"))
      end
      return a.get(a.first(a.filter(_1_, vim.loop.getaddrinfo(host))), "addr")
    end
  end
  v_0_ = resolve0
  _0_0["resolve"] = v_0_
  resolve = v_0_
end
local state = {["sock-drawer"] = {}}
local function destroy_sock(sock)
  if not sock:is_closing() then
    sock:read_stop()
    sock:shutdown()
    sock:close()
  end
  local function _2_(_241)
    return (sock ~= _241)
  end
  state["sock-drawer"] = a.filter(_2_, state["sock-drawer"])
  return nil
end
local connect
do
  local v_0_
  local function connect0(_1_0)
    local _arg_0_ = _1_0
    local cb = _arg_0_["cb"]
    local host = _arg_0_["host"]
    local port = _arg_0_["port"]
    local sock = vim.loop.new_tcp()
    local resolved_host = resolve(host)
    sock:connect(resolved_host, port, cb)
    table.insert(state["sock-drawer"], sock)
    local function _2_()
      return destroy_sock(sock)
    end
    return {["resolved-host"] = resolved_host, destroy = _2_, host = host, port = port, sock = sock}
  end
  v_0_ = connect0
  _0_0["connect"] = v_0_
  connect = v_0_
end
local destroy_all_socks
do
  local v_0_
  local function destroy_all_socks0()
    return a["run!"](destroy_sock, state["sock-drawer"])
  end
  v_0_ = destroy_all_socks0
  _0_0["destroy-all-socks"] = v_0_
  destroy_all_socks = v_0_
end
nvim.ex.augroup("conjure-net-sock-cleanup")
nvim.ex.autocmd_()
nvim.ex.autocmd("VimLeavePre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "destroy-all-socks" .. "']()"))
return nvim.ex.augroup("END")