local _2afile_2a = "fnl/conjure/fs.fnl"
local _1_
do
  local name_4_auto = "conjure.fs"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fs"), autoload("conjure.config"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", afs = "conjure.aniseed.fs", config = "conjure.config", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local afs = _local_4_[2]
local config = _local_4_[3]
local nvim = _local_4_[4]
local str = _local_4_[5]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.fs"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local env
do
  local v_23_auto
  local function env0(k)
    local v = nvim.fn.getenv(k)
    if (a["string?"](v) and not a["empty?"](v)) then
      return v
    end
  end
  v_23_auto = env0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["env"] = v_23_auto
  env = v_23_auto
end
local config_dir
do
  local v_23_auto
  do
    local v_25_auto
    local function config_dir0()
      return ((env("XDG_CONFIG_HOME") or (env("HOME") .. afs["path-sep"] .. ".config")) .. afs["path-sep"] .. "conjure")
    end
    v_25_auto = config_dir0
    _1_["config-dir"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["config-dir"] = v_23_auto
  config_dir = v_23_auto
end
local findfile
do
  local v_23_auto
  do
    local v_25_auto
    local function findfile0(name, path)
      local res = nvim.fn.findfile(name, path)
      if not a["empty?"](res) then
        return res
      end
    end
    v_25_auto = findfile0
    _1_["findfile"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["findfile"] = v_23_auto
  findfile = v_23_auto
end
local resolve_above
do
  local v_23_auto
  do
    local v_25_auto
    local function resolve_above0(name)
      return (findfile(name, ".;") or findfile(name, (nvim.fn.getcwd() .. ";")) or findfile(name, (config_dir() .. ";")))
    end
    v_25_auto = resolve_above0
    _1_["resolve-above"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["resolve-above"] = v_23_auto
  resolve_above = v_23_auto
end
local file_readable_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function file_readable_3f0(path)
      return (1 == nvim.fn.filereadable(path))
    end
    v_25_auto = file_readable_3f0
    _1_["file-readable?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["file-readable?"] = v_23_auto
  file_readable_3f = v_23_auto
end
local split_path
do
  local v_23_auto
  do
    local v_25_auto
    local function split_path0(path)
      local function _10_(_241)
        return not a["empty?"](_241)
      end
      return a.filter(_10_, str.split(path, afs["path-sep"]))
    end
    v_25_auto = split_path0
    _1_["split-path"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["split-path"] = v_23_auto
  split_path = v_23_auto
end
local join_path
do
  local v_23_auto
  do
    local v_25_auto
    local function join_path0(parts)
      return str.join(afs["path-sep"], a.concat(parts))
    end
    v_25_auto = join_path0
    _1_["join-path"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["join-path"] = v_23_auto
  join_path = v_23_auto
end
local resolve_relative_to
do
  local v_23_auto
  do
    local v_25_auto
    local function resolve_relative_to0(path, root)
      local function loop(parts)
        if a["empty?"](parts) then
          return path
        else
          if file_readable_3f(join_path(a.concat({root}, parts))) then
            return join_path(parts)
          else
            return loop(a.rest(parts))
          end
        end
      end
      return loop(split_path(path))
    end
    v_25_auto = resolve_relative_to0
    _1_["resolve-relative-to"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["resolve-relative-to"] = v_23_auto
  resolve_relative_to = v_23_auto
end
local resolve_relative
do
  local v_23_auto
  do
    local v_25_auto
    local function resolve_relative0(path)
      local relative_file_root = config["get-in"]({"relative_file_root"})
      if relative_file_root then
        return resolve_relative_to(path, relative_file_root)
      else
        return path
      end
    end
    v_25_auto = resolve_relative0
    _1_["resolve-relative"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["resolve-relative"] = v_23_auto
  resolve_relative = v_23_auto
end
local apply_path_subs
do
  local v_23_auto
  do
    local v_25_auto
    local function apply_path_subs0(path, path_subs)
      local function _16_(path0, _14_)
        local _arg_15_ = _14_
        local pat = _arg_15_[1]
        local rep = _arg_15_[2]
        return path0:gsub(pat, rep)
      end
      return a.reduce(_16_, path, a["kv-pairs"](path_subs))
    end
    v_25_auto = apply_path_subs0
    _1_["apply-path-subs"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["apply-path-subs"] = v_23_auto
  apply_path_subs = v_23_auto
end
local localise_path
do
  local v_23_auto
  do
    local v_25_auto
    local function localise_path0(path)
      return resolve_relative(apply_path_subs(path, config["get-in"]({"path_subs"})))
    end
    v_25_auto = localise_path0
    _1_["localise-path"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["localise-path"] = v_23_auto
  localise_path = v_23_auto
end
return nil