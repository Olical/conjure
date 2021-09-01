local _2afile_2a = "fnl/conjure/fs.fnl"
local _2amodule_name_2a = "conjure.fs"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["_LOCALS"] = {}
  _2amodule_locals_2a = (_2amodule_2a)._LOCALS
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, afs, config, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fs"), autoload("conjure.config"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["afs"] = afs
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local function env(k)
  local v = nvim.fn.getenv(k)
  if (a["string?"](v) and not a["empty?"](v)) then
    return v
  end
end
_2amodule_locals_2a["env"] = env
local function config_dir()
  return ((env("XDG_CONFIG_HOME") or (env("HOME") .. afs["path-sep"] .. ".config")) .. afs["path-sep"] .. "conjure")
end
_2amodule_2a["config-dir"] = config_dir
local function findfile(name, path)
  local res = nvim.fn.findfile(name, path)
  if not a["empty?"](res) then
    return res
  end
end
_2amodule_2a["findfile"] = findfile
local function resolve_above(name)
  return (findfile(name, ".;") or findfile(name, (nvim.fn.getcwd() .. ";")) or findfile(name, (config_dir() .. ";")))
end
_2amodule_2a["resolve-above"] = resolve_above
local function file_readable_3f(path)
  return (1 == nvim.fn.filereadable(path))
end
_2amodule_2a["file-readable?"] = file_readable_3f
local function split_path(path)
  local function _3_(_241)
    return not a["empty?"](_241)
  end
  return a.filter(_3_, str.split(path, afs["path-sep"]))
end
_2amodule_2a["split-path"] = split_path
local function join_path(parts)
  return str.join(afs["path-sep"], a.concat(parts))
end
_2amodule_2a["join-path"] = join_path
local function resolve_relative_to(path, root)
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
_2amodule_2a["resolve-relative-to"] = resolve_relative_to
local function resolve_relative(path)
  local relative_file_root = config["get-in"]({"relative_file_root"})
  if relative_file_root then
    return resolve_relative_to(path, relative_file_root)
  else
    return path
  end
end
_2amodule_2a["resolve-relative"] = resolve_relative
local function apply_path_subs(path, path_subs)
  local function _9_(path0, _7_)
    local _arg_8_ = _7_
    local pat = _arg_8_[1]
    local rep = _arg_8_[2]
    return path0:gsub(pat, rep)
  end
  return a.reduce(_9_, path, a["kv-pairs"](path_subs))
end
_2amodule_2a["apply-path-subs"] = apply_path_subs
local function localise_path(path)
  return resolve_relative(apply_path_subs(path, config["get-in"]({"path_subs"})))
end
_2amodule_2a["localise-path"] = localise_path