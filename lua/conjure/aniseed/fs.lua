local _2afile_2a = "fnl/aniseed/fs.fnl"
local _1_
do
  local name_4_auto = "conjure.aniseed.fs"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local nvim = _local_4_[2]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.aniseed.fs"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local path_sep
do
  local v_23_auto
  do
    local v_25_auto
    do
      local os = string.lower(jit.os)
      if (("linux" == os) or ("osx" == os) or ("bsd" == os)) then
        v_25_auto = "/"
      else
        v_25_auto = "\\"
      end
    end
    _1_["path-sep"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["path-sep"] = v_23_auto
  path_sep = v_23_auto
end
local basename
do
  local v_23_auto
  do
    local v_25_auto
    local function basename0(path)
      return nvim.fn.fnamemodify(path, ":h")
    end
    v_25_auto = basename0
    _1_["basename"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["basename"] = v_23_auto
  basename = v_23_auto
end
local mkdirp
do
  local v_23_auto
  do
    local v_25_auto
    local function mkdirp0(dir)
      return nvim.fn.mkdir(dir, "p")
    end
    v_25_auto = mkdirp0
    _1_["mkdirp"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["mkdirp"] = v_23_auto
  mkdirp = v_23_auto
end
local relglob
do
  local v_23_auto
  do
    local v_25_auto
    local function relglob0(dir, expr)
      local dir_len = a.inc(string.len(dir))
      local function _9_(_241)
        return string.sub(_241, dir_len)
      end
      return a.map(_9_, nvim.fn.globpath(dir, expr, true, true))
    end
    v_25_auto = relglob0
    _1_["relglob"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["relglob"] = v_23_auto
  relglob = v_23_auto
end
local glob_dir_newer_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function glob_dir_newer_3f0(a_dir, b_dir, expr, b_dir_path_fn)
      local newer_3f = false
      for _, path in ipairs(relglob(a_dir, expr)) do
        if (nvim.fn.getftime((a_dir .. path)) > nvim.fn.getftime((b_dir .. b_dir_path_fn(path)))) then
          newer_3f = true
        end
      end
      return newer_3f
    end
    v_25_auto = glob_dir_newer_3f0
    _1_["glob-dir-newer?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["glob-dir-newer?"] = v_23_auto
  glob_dir_newer_3f = v_23_auto
end
local macro_file_path_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function macro_file_path_3f0(path)
      return string.match(path, "macros.fnl$")
    end
    v_25_auto = macro_file_path_3f0
    _1_["macro-file-path?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["macro-file-path?"] = v_23_auto
  macro_file_path_3f = v_23_auto
end
return nil
