local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.bridge"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {}
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.bridge"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local viml__3elua
do
  local v_0_
  local function viml__3elua0(m, f, opts)
    return ("lua require('" .. m .. "')['" .. f .. "'](" .. ((opts and opts.args) or "") .. ")")
  end
  v_0_ = viml__3elua0
  _0_0["viml->lua"] = v_0_
  viml__3elua = v_0_
end
return nil