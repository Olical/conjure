local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.main"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.config"), require("conjure.mapping")}
local config = _local_0_[1]
local mapping = _local_0_[2]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.main"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local main
do
  local v_0_
  local function main0()
    return mapping.init(config.filetypes())
  end
  v_0_ = main0
  _0_0["main"] = v_0_
  main = v_0_
end
return nil