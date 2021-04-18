local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.fs"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.config"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local config = _local_0_[2]
local nvim = _local_0_[3]
local str = _local_0_[4]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.fs"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local function env(k)
  local v = nvim.fn.getenv(k)
  if (a["string?"](v) and not a["empty?"](v)) then
    return v
  end
end
local config_dir
do
  local v_0_
  local function config_dir0()
    return ((env("XDG_CONFIG_HOME") or (env("HOME") .. "/.config")) .. "/conjure")
  end
  v_0_ = config_dir0
  _0_0["config-dir"] = v_0_
  config_dir = v_0_
end
local findfile
do
  local v_0_
  local function findfile0(name, path)
    local res = nvim.fn.findfile(name, path)
    if not a["empty?"](res) then
      return res
    end
  end
  v_0_ = findfile0
  _0_0["findfile"] = v_0_
  findfile = v_0_
end
local resolve_above
do
  local v_0_
  local function resolve_above0(name)
    return (findfile(name, ".;") or findfile(name, (nvim.fn.getcwd() .. ";")) or findfile(name, (config_dir() .. ";")))
  end
  v_0_ = resolve_above0
  _0_0["resolve-above"] = v_0_
  resolve_above = v_0_
end
local file_readable_3f
do
  local v_0_
  local function file_readable_3f0(path)
    return (1 == nvim.fn.filereadable(path))
  end
  v_0_ = file_readable_3f0
  _0_0["file-readable?"] = v_0_
  file_readable_3f = v_0_
end
local split_path
do
  local v_0_
  local function split_path0(path)
    local function _1_(_241)
      return not a["empty?"](_241)
    end
    return a.filter(_1_, str.split(path, "/"))
  end
  v_0_ = split_path0
  _0_0["split-path"] = v_0_
  split_path = v_0_
end
local join_path
do
  local v_0_
  local function join_path0(parts)
    return str.join("/", a.concat(parts))
  end
  v_0_ = join_path0
  _0_0["join-path"] = v_0_
  join_path = v_0_
end
local resolve_relative_to
do
  local v_0_
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
  v_0_ = resolve_relative_to0
  _0_0["resolve-relative-to"] = v_0_
  resolve_relative_to = v_0_
end
local resolve_relative
do
  local v_0_
  local function resolve_relative0(path)
    local relative_file_root = config["get-in"]({"relative_file_root"})
    if relative_file_root then
      return resolve_relative_to(path, relative_file_root)
    else
      return path
    end
  end
  v_0_ = resolve_relative0
  _0_0["resolve-relative"] = v_0_
  resolve_relative = v_0_
end
local apply_path_subs
do
  local v_0_
  local function apply_path_subs0(path, path_subs)
    local function _2_(path0, _1_0)
      local _arg_0_ = _1_0
      local pat = _arg_0_[1]
      local rep = _arg_0_[2]
      return path0:gsub(pat, rep)
    end
    return a.reduce(_2_, path, a["kv-pairs"](path_subs))
  end
  v_0_ = apply_path_subs0
  _0_0["apply-path-subs"] = v_0_
  apply_path_subs = v_0_
end
local localise_path
do
  local v_0_
  local function localise_path0(path)
    return resolve_relative(apply_path_subs(path, config["get-in"]({"path_subs"})))
  end
  v_0_ = localise_path0
  _0_0["localise-path"] = v_0_
  localise_path = v_0_
end
return nil