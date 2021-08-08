local _2afile_2a = "fnl/conjure/net.fnl"
local _1_
do
  local name_4_auto = "conjure.net"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {["require-macros"] = {["conjure.macros"] = true}, autoload = {a = "conjure.aniseed.core", bridge = "conjure.bridge", nvim = "conjure.aniseed.nvim"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local bridge = _local_4_[2]
local nvim = _local_4_[3]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.net"
do local _ = ({nil, _1_, nil, {{nil}, nil, nil, nil}})[2] end
local resolve
do
  local v_23_auto
  do
    local v_25_auto
    local function resolve0(host)
      if (host == "::") then
        return host
      else
        local function _8_(_241)
          return ("inet" == a.get(_241, "family"))
        end
        return a.get(a.first(a.filter(_8_, vim.loop.getaddrinfo(host))), "addr")
      end
    end
    v_25_auto = resolve0
    _1_["resolve"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["resolve"] = v_23_auto
  resolve = v_23_auto
end
local state
do
  local v_23_auto = ((_1_)["aniseed/locals"].state or {["sock-drawer"] = {}})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state"] = v_23_auto
  state = v_23_auto
end
local destroy_sock
do
  local v_23_auto
  local function destroy_sock0(sock)
    if not sock:is_closing() then
      sock:read_stop()
      sock:shutdown()
      sock:close()
    end
    local function _11_(_241)
      return (sock ~= _241)
    end
    state["sock-drawer"] = a.filter(_11_, state["sock-drawer"])
    return nil
  end
  v_23_auto = destroy_sock0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["destroy-sock"] = v_23_auto
  destroy_sock = v_23_auto
end
local connect
do
  local v_23_auto
  do
    local v_25_auto
    local function connect0(_12_)
      local _arg_13_ = _12_
      local cb = _arg_13_["cb"]
      local host = _arg_13_["host"]
      local port = _arg_13_["port"]
      local sock = vim.loop.new_tcp()
      local resolved_host = resolve(host)
      sock:connect(resolved_host, port, cb)
      table.insert(state["sock-drawer"], sock)
      local function _14_()
        return destroy_sock(sock)
      end
      return {["resolved-host"] = resolved_host, destroy = _14_, host = host, port = port, sock = sock}
    end
    v_25_auto = connect0
    _1_["connect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect"] = v_23_auto
  connect = v_23_auto
end
local destroy_all_socks
do
  local v_23_auto
  do
    local v_25_auto
    local function destroy_all_socks0()
      return a["run!"](destroy_sock, state["sock-drawer"])
    end
    v_25_auto = destroy_all_socks0
    _1_["destroy-all-socks"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["destroy-all-socks"] = v_23_auto
  destroy_all_socks = v_23_auto
end
nvim.ex.augroup("conjure-net-sock-cleanup")
nvim.ex.autocmd_()
nvim.ex.autocmd("VimLeavePre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "destroy-all-socks" .. "']()"))
return nvim.ex.augroup("END")