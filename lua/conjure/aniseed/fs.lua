local _0_0 = nil
do
  local name_0_ = "conjure.aniseed.fs"
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
  _0_0["aniseed/local-fns"] = {require = {nvim = "conjure.aniseed.nvim"}}
  return {require("conjure.aniseed.nvim")}
end
local _1_ = _2_(...)
local nvim = _1_[1]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local basename = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function basename0(path)
      return nvim.fn.fnamemodify(path, ":h")
    end
    v_0_0 = basename0
    _0_0["basename"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["basename"] = v_0_
  basename = v_0_
end
local mkdirp = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function mkdirp0(dir)
      return nvim.fn.mkdir(dir, "p")
    end
    v_0_0 = mkdirp0
    _0_0["mkdirp"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["mkdirp"] = v_0_
  mkdirp = v_0_
end
return nil
