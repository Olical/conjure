local _0_0 = nil
do
  local name_0_ = "conjure.aniseed.eval"
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
  _0_0["aniseed/local-fns"] = {require = {compile = "conjure.aniseed.compile", fennel = "conjure.aniseed.fennel", fs = "conjure.aniseed.fs", nvim = "conjure.aniseed.nvim"}}
  return {require("conjure.aniseed.compile"), require("conjure.aniseed.fennel"), require("conjure.aniseed.fs"), require("conjure.aniseed.nvim")}
end
local _1_ = _2_(...)
local compile = _1_[1]
local fennel = _1_[2]
local fs = _1_[3]
local nvim = _1_[4]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function str0(code, opts)
      local function _3_()
        return fennel.eval(compile["macros-prefix"](code), opts)
      end
      return xpcall(_3_, fennel.traceback)
    end
    v_0_0 = str0
    _0_0["str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["str"] = v_0_
  str = v_0_
end
return nil
