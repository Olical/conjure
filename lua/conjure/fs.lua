local _0_0 = nil
do
  local name_0_ = "conjure.fs"
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
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.config"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", config = "conjure.config", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local config = _1_[2]
local nvim = _1_[3]
local str = _1_[4]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.fs"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local env = nil
do
  local v_0_ = nil
  local function env0(k)
    local v = nvim.fn.getenv(k)
    if (a["string?"](v) and not a["empty?"](v)) then
      return v
    end
  end
  v_0_ = env0
  _0_0["aniseed/locals"]["env"] = v_0_
  env = v_0_
end
local config_dir = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function config_dir0()
      return ((env("XDG_CONFIG_HOME") or (env("HOME") .. "/.config")) .. "/conjure")
    end
    v_0_0 = config_dir0
    _0_0["config-dir"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["config-dir"] = v_0_
  config_dir = v_0_
end
local findfile = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function findfile0(name, path)
      local res = nvim.fn.findfile(name, path)
      if not a["empty?"](res) then
        return res
      end
    end
    v_0_0 = findfile0
    _0_0["findfile"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["findfile"] = v_0_
  findfile = v_0_
end
local resolve_above = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function resolve_above0(name)
      return (findfile(name, ".;") or findfile(name, (nvim.fn.getcwd() .. ";")) or findfile(name, (config_dir() .. ";")))
    end
    v_0_0 = resolve_above0
    _0_0["resolve-above"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["resolve-above"] = v_0_
  resolve_above = v_0_
end
local file_readable_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function file_readable_3f0(path)
      return (1 == nvim.fn.filereadable(path))
    end
    v_0_0 = file_readable_3f0
    _0_0["file-readable?"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["file-readable?"] = v_0_
  file_readable_3f = v_0_
end
local split_path = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function split_path0(path)
      local function _3_(_241)
        return not a["empty?"](_241)
      end
      return a.filter(_3_, str.split(path, "/"))
    end
    v_0_0 = split_path0
    _0_0["split-path"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["split-path"] = v_0_
  split_path = v_0_
end
local join_path = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function join_path0(parts)
      return str.join("/", a.concat(parts))
    end
    v_0_0 = join_path0
    _0_0["join-path"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["join-path"] = v_0_
  join_path = v_0_
end
local resolve_relative_to = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
    v_0_0 = resolve_relative_to0
    _0_0["resolve-relative-to"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["resolve-relative-to"] = v_0_
  resolve_relative_to = v_0_
end
local resolve_relative = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function resolve_relative0(path)
      local relative_file_root = config["get-in"]({"relative_file_root"})
      if relative_file_root then
        return resolve_relative_to(path, relative_file_root)
      else
        return path
      end
    end
    v_0_0 = resolve_relative0
    _0_0["resolve-relative"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["resolve-relative"] = v_0_
  resolve_relative = v_0_
end
return nil