local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.aniseed.fs"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.nvim")}
local nvim = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.fs"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local basename
do
  local v_0_
  local function basename0(path)
    return nvim.fn.fnamemodify(path, ":h")
  end
  v_0_ = basename0
  _0_0["basename"] = v_0_
  basename = v_0_
end
local mkdirp
do
  local v_0_
  local function mkdirp0(dir)
    return nvim.fn.mkdir(dir, "p")
  end
  v_0_ = mkdirp0
  _0_0["mkdirp"] = v_0_
  mkdirp = v_0_
end
return nil
