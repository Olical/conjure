local _0_0 = nil
do
  local name_0_ = "conjure.net"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.bridge"), require("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {["require-macros"] = {["conjure.macros"] = true}, require = {a = "conjure.aniseed.core", bridge = "conjure.bridge", nvim = "conjure.aniseed.nvim"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local bridge = _1_[2]
local nvim = _1_[3]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.net"
do local _ = ({nil, _0_0, {{nil}, nil, nil, nil}})[2] end
local resolve = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function resolve0(host)
      if (host == "::") then
        return host
      else
        local function _3_(_241)
          return ("inet" == a.get(_241, "family"))
        end
        return a.get(a.first(a.filter(_3_, vim.loop.getaddrinfo(host))), "addr")
      end
    end
    v_0_0 = resolve0
    _0_0["resolve"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["resolve"] = v_0_
  resolve = v_0_
end
local state = nil
do
  local v_0_ = (_0_0["aniseed/locals"].state or {["sock-drawer"] = {}})
  _0_0["aniseed/locals"]["state"] = v_0_
  state = v_0_
end
local destroy_sock = nil
do
  local v_0_ = nil
  local function destroy_sock0(sock)
    if not sock:is_closing() then
      sock:read_stop()
      sock:shutdown()
      sock:close()
    end
    local function _4_(_241)
      return (sock ~= _241)
    end
    state["sock-drawer"] = a.filter(_4_, state["sock-drawer"])
    return nil
  end
  v_0_ = destroy_sock0
  _0_0["aniseed/locals"]["destroy-sock"] = v_0_
  destroy_sock = v_0_
end
local connect = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connect0(_3_0)
      local _4_ = _3_0
      local cb = _4_["cb"]
      local host = _4_["host"]
      local port = _4_["port"]
      local sock = vim.loop.new_tcp()
      local resolved_host = resolve(host)
      sock:connect(resolved_host, port, cb)
      table.insert(state["sock-drawer"], sock)
      local function _5_()
        return destroy_sock(sock)
      end
      return {["resolved-host"] = resolved_host, destroy = _5_, host = host, port = port, sock = sock}
    end
    v_0_0 = connect0
    _0_0["connect"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connect"] = v_0_
  connect = v_0_
end
local destroy_all_socks = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function destroy_all_socks0()
      return a["run!"](destroy_sock, state["sock-drawer"])
    end
    v_0_0 = destroy_all_socks0
    _0_0["destroy-all-socks"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["destroy-all-socks"] = v_0_
  destroy_all_socks = v_0_
end
nvim.ex.augroup("conjure-net-sock-cleanup")
nvim.ex.autocmd_()
nvim.ex.autocmd("VimLeavePre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "destroy-all-socks" .. "']()"))
return nvim.ex.augroup("END")