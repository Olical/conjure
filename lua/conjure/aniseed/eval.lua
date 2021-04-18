local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.aniseed.eval"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.aniseed.compile"), require("conjure.aniseed.fennel"), require("conjure.aniseed.fs"), require("conjure.aniseed.nvim")}
local a = _local_0_[1]
local compile = _local_0_[2]
local fennel = _local_0_[3]
local fs = _local_0_[4]
local nvim = _local_0_[5]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.eval"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local str
do
  local v_0_
  local function str0(code, opts)
    local function _1_()
      return fennel.eval(compile["macros-prefix"](code), a.merge({["compiler-env"] = _G}, opts))
    end
    return xpcall(_1_, fennel.traceback)
  end
  v_0_ = str0
  _0_0["str"] = v_0_
  str = v_0_
end
return nil
