-- [nfnl] Compiled from fnl/conjure/fs.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.fs"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a, afs, config, nvim, str, text = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fs"), autoload("conjure.config"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["afs"] = afs
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
local apply_path_subs = (_2amodule_2a)["apply-path-subs"]
local config_dir = (_2amodule_2a)["config-dir"]
local file_path__3emodule_name = (_2amodule_2a)["file-path->module-name"]
local file_readable_3f = (_2amodule_2a)["file-readable?"]
local findfile = (_2amodule_2a).findfile
local join_path = (_2amodule_2a)["join-path"]
local localise_path = (_2amodule_2a)["localise-path"]
local parent_dir = (_2amodule_2a)["parent-dir"]
local resolve_above = (_2amodule_2a)["resolve-above"]
local resolve_relative = (_2amodule_2a)["resolve-relative"]
local resolve_relative_to = (_2amodule_2a)["resolve-relative-to"]
local split_path = (_2amodule_2a)["split-path"]
local upwards_file_search = (_2amodule_2a)["upwards-file-search"]
local a0 = (_2amodule_locals_2a).a
local afs0 = (_2amodule_locals_2a).afs
local config0 = (_2amodule_locals_2a).config
local env = (_2amodule_locals_2a).env
local nvim0 = (_2amodule_locals_2a).nvim
local str0 = (_2amodule_locals_2a).str
local text0 = (_2amodule_locals_2a).text
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local function env0(k)
  local v = nvim0.fn.getenv(k)
  if (a0["string?"](v) and not a0["empty?"](v)) then
    return v
  else
    return nil
  end
end
_2amodule_locals_2a["env"] = env0
do local _ = {env0, nil} end
local function config_dir0()
  return ((env0("XDG_CONFIG_HOME") or (env0("HOME") .. afs0["path-sep"] .. ".config")) .. afs0["path-sep"] .. "conjure")
end
_2amodule_2a["config-dir"] = config_dir
local function absolute_path(path)
  return vim.fn.fnamemodify(path, ":p")
end
_2amodule_2a["absolute-path"] = absolute_path
local function findfile(name, path)
  local res = nvim.fn.findfile(name, path)
  if not a["empty?"](res) then
    return absolute_path(res)
  else
    return nil
  end
end
_2amodule_2a["findfile"] = findfile0
do local _ = {findfile0, nil} end
local function split_path0(path)
  local function _3_(_241)
    return not a0["empty?"](_241)
  end
  return a0.filter(_3_, str0.split(path, afs0["path-sep"]))
end
_2amodule_2a["split-path"] = split_path0
do local _ = {split_path0, nil} end
local function join_path0(parts)
  return str0.join(afs0["path-sep"], a0.concat(parts))
end
_2amodule_2a["join-path"] = join_path0
do local _ = {join_path0, nil} end
local function parent_dir0(path)
  local res = join_path0(a0.butlast(split_path0(path)))
  if ("" == res) then
    return nil
  else
    return (afs0["path-sep"] .. res)
  end
end
_2amodule_2a["parent-dir"] = parent_dir0
do local _ = {parent_dir0, nil} end
local function upwards_file_search0(file_names, from_dir)
  if (from_dir and not a0["empty?"](file_names)) then
    local result
    local function _5_(file_name)
      return findfile0(file_name, from_dir)
    end
    result = a0.some(_5_, file_names)
    if result then
      return result
    else
      return upwards_file_search0(file_names, parent_dir0(from_dir))
    end
  else
    return nil
  end
end
_2amodule_2a["upwards-file-search"] = upwards_file_search0
do local _ = {upwards_file_search0, nil} end
local function resolve_above0(names)
  return (upwards_file_search0(names, nvim0.fn.expand("%:p:h")) or upwards_file_search0(names, nvim0.fn.getcwd()) or upwards_file_search0(names, config_dir0()))
end
_2amodule_2a["resolve-above"] = resolve_above0
do local _ = {resolve_above0, nil} end
local function file_readable_3f0(path)
  return (1 == nvim0.fn.filereadable(path))
end
_2amodule_2a["file-readable?"] = file_readable_3f0
do local _ = {file_readable_3f0, nil} end
local function resolve_relative_to0(path, root)
  local function loop(parts)
    if a0["empty?"](parts) then
      return path
    else
      if file_readable_3f0(join_path0(a0.concat({root}, parts))) then
        return join_path0(parts)
      else
        return loop(a0.rest(parts))
      end
    end
  end
  return loop(split_path0(path))
end
_2amodule_2a["resolve-relative-to"] = resolve_relative_to0
do local _ = {resolve_relative_to0, nil} end
local function resolve_relative0(path)
  local relative_file_root = config0["get-in"]({"relative_file_root"})
  if relative_file_root then
    return resolve_relative_to0(path, relative_file_root)
  else
    return path
  end
end
_2amodule_2a["resolve-relative"] = resolve_relative0
do local _ = {resolve_relative0, nil} end
local function apply_path_subs0(path, path_subs)
  local function _13_(path0, _11_)
    local _arg_12_ = _11_
    local pat = _arg_12_[1]
    local rep = _arg_12_[2]
    return path0:gsub(pat, rep)
  end
  return a0.reduce(_13_, path, a0["kv-pairs"](path_subs))
end
_2amodule_2a["apply-path-subs"] = apply_path_subs0
do local _ = {apply_path_subs0, nil} end
local function localise_path0(path)
  return resolve_relative0(apply_path_subs0(path, config0["get-in"]({"path_subs"})))
end
_2amodule_2a["localise-path"] = localise_path
local function current_source()
  local info = debug.getinfo(2, "S")
  if text["starts-with"](a.get(info, "source"), "@") then
    return string.sub(info.source, 2)
  else
    return nil
  end
end
_2amodule_2a["current-source"] = current_source
local conjure_source_directory
local function _15_(...)
  local src = current_source()
  if src then
    return vim.fs.normalize((src .. "/../../.."))
  else
    return nil
  end
end
conjure_source_directory = ((_2amodule_2a)["conjure-source-directory"] or _15_(...))
do end (_2amodule_2a)["conjure-source-directory"] = conjure_source_directory
local function file_path__3emodule_name(file_path)
  if file_path then
    local function _17_(mod_name)
      local mod_path = string.gsub(mod_name, "%.", afs["path-sep"])
      if (text["ends-with"](file_path, (mod_path .. ".fnl")) or text["ends-with"](file_path, (mod_path .. "/init.fnl"))) then
        return mod_name
      else
        return nil
      end
    end
    return a.some(_17_, a.keys(package.loaded))
  else
    return nil
  end
end
_2amodule_2a["file-path->module-name"] = file_path__3emodule_name0
do local _ = {file_path__3emodule_name0, nil} end
return _2amodule_2a
