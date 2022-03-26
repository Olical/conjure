local _2afile_2a = "fnl/conjure/fs.fnl"
local _2amodule_name_2a = "conjure.fs"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, afs, config, nvim, str, text = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fs"), autoload("conjure.config"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["afs"] = afs
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
local function env(k)
  local v = nvim.fn.getenv(k)
  if (a["string?"](v) and not a["empty?"](v)) then
    return v
  else
    return nil
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
  else
    return nil
  end
end
_2amodule_2a["findfile"] = findfile
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
local function parent_dir(path)
  local res = join_path(a.butlast(split_path(path)))
  if ("" == res) then
    return nil
  else
    return ("/" .. res)
  end
end
_2amodule_2a["parent-dir"] = parent_dir
local function upwards_file_search(orig_names, orig_dir)
  local names = orig_names
  local dir = orig_dir
  local file = nil
  while (dir and not file) do
    local name = a.first(names)
    if name then
      local res = findfile(name, dir)
      if res then
        file = res
      else
        names = a.rest(names)
      end
    else
      names = orig_names
      dir = parent_dir(dir)
    end
  end
  return file
end
_2amodule_2a["upwards-file-search"] = upwards_file_search
local function resolve_above(names)
  return (upwards_file_search(names, nvim.fn.expand("%:p:h")) or upwards_file_search(names, nvim.fn.getcwd()) or upwards_file_search(names, config_dir()))
end
_2amodule_2a["resolve-above"] = resolve_above
local function file_readable_3f(path)
  return (1 == nvim.fn.filereadable(path))
end
_2amodule_2a["file-readable?"] = file_readable_3f
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
  local function _12_(path0, _10_)
    local _arg_11_ = _10_
    local pat = _arg_11_[1]
    local rep = _arg_11_[2]
    return path0:gsub(pat, rep)
  end
  return a.reduce(_12_, path, a["kv-pairs"](path_subs))
end
_2amodule_2a["apply-path-subs"] = apply_path_subs
local function localise_path(path)
  return resolve_relative(apply_path_subs(path, config["get-in"]({"path_subs"})))
end
_2amodule_2a["localise-path"] = localise_path
local function file_path__3emodule_name(file_path)
  if file_path then
    local function _13_(mod_name)
      local mod_path = string.gsub(mod_name, "%.", afs["path-sep"])
      if (text["ends-with"](file_path, (mod_path .. ".fnl")) or text["ends-with"](file_path, (mod_path .. "/init.fnl"))) then
        return mod_name
      else
        return nil
      end
    end
    return a.some(_13_, a.keys(package.loaded))
  else
    return nil
  end
end
_2amodule_2a["file-path->module-name"] = file_path__3emodule_name
return _2amodule_2a