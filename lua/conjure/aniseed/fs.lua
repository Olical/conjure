local _0_0 = nil
do
  local name_23_0_ = "conjure.aniseed.fs"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {nvim = "conjure.aniseed.nvim"}}
  return {require("conjure.aniseed.nvim")}
end
local _2_ = _1_(...)
local nvim = _2_[1]
do local _ = ({nil, _0_0, nil})[2] end
local basename = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function basename0(path)
      return nvim.fn.fnamemodify(path, ":h")
    end
    v_23_0_0 = basename0
    _0_0["basename"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["basename"] = v_23_0_
  basename = v_23_0_
end
local mkdirp = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function mkdirp0(dir)
      return nvim.fn.mkdir(dir, "p")
    end
    v_23_0_0 = mkdirp0
    _0_0["mkdirp"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["mkdirp"] = v_23_0_
  mkdirp = v_23_0_
end
return nil
