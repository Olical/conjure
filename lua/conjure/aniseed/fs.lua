local _2afile_2a = "fnl/aniseed/fs.fnl"
local _0_
do
  local name_0_ = "conjure.aniseed.fs"
  local module_0_
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
  _0_ = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local nvim = _local_0_[2]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.aniseed.fs"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local basename
do
  local v_0_
  do
    local v_0_0
    local function basename0(path)
      return nvim.fn.fnamemodify(path, ":h")
    end
    v_0_0 = basename0
    _0_["basename"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["basename"] = v_0_
  basename = v_0_
end
local mkdirp
do
  local v_0_
  do
    local v_0_0
    local function mkdirp0(dir)
      return nvim.fn.mkdir(dir, "p")
    end
    v_0_0 = mkdirp0
    _0_["mkdirp"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["mkdirp"] = v_0_
  mkdirp = v_0_
end
local relglob
do
  local v_0_
  do
    local v_0_0
    local function relglob0(dir, expr)
      local dir_len = a.inc(string.len(dir))
      local function _2_(_241)
        return string.sub(_241, dir_len)
      end
      return a.map(_2_, nvim.fn.globpath(dir, expr, true, true))
    end
    v_0_0 = relglob0
    _0_["relglob"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["relglob"] = v_0_
  relglob = v_0_
end
local glob_dir_newer_3f
do
  local v_0_
  do
    local v_0_0
    local function glob_dir_newer_3f0(a_dir, b_dir, expr, b_dir_path_fn)
      local newer_3f = false
      for _, path in ipairs(relglob(a_dir, expr)) do
        if (nvim.fn.getftime((a_dir .. path)) > nvim.fn.getftime((b_dir .. b_dir_path_fn(path)))) then
          newer_3f = true
        end
      end
      return newer_3f
    end
    v_0_0 = glob_dir_newer_3f0
    _0_["glob-dir-newer?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["glob-dir-newer?"] = v_0_
  glob_dir_newer_3f = v_0_
end
local macro_file_path_3f
do
  local v_0_
  do
    local v_0_0
    local function macro_file_path_3f0(path)
      return string.match(path, "macros.fnl$")
    end
    v_0_0 = macro_file_path_3f0
    _0_["macro-file-path?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["macro-file-path?"] = v_0_
  macro_file_path_3f = v_0_
end
return nil
