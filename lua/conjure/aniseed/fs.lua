local _0_0 = nil
do
  local name_0_ = "conjure.aniseed.fs"
  local module_0_ = nil
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {nvim = "conjure.aniseed.nvim"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local nvim = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.fs"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
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
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["basename"] = v_0_
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
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["mkdirp"] = v_0_
  mkdirp = v_0_
end
return nil
