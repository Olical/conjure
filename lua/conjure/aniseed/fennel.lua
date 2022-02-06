local _2afile_2a = "fnl/aniseed/fennel.fnl"
local _2amodule_name_2a = "conjure.aniseed.fennel"
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
local a, fs, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local function sync_rtp(compiler)
  local fnl_suffix = (fs["path-sep"] .. "fnl" .. fs["path-sep"] .. "?.fnl")
  local lua_suffix = (fs["path-sep"] .. "lua" .. fs["path-sep"] .. "?.fnl")
  local rtps = nvim.list_runtime_paths()
  local fnl_paths
  local function _1_(_241)
    return (_241 .. fnl_suffix)
  end
  fnl_paths = a.map(_1_, rtps)
  local lua_paths
  local function _2_(_241)
    return (_241 .. lua_suffix)
  end
  lua_paths = a.map(_2_, rtps)
  do end (compiler)["macro-path"] = str.join(";", a.concat(fnl_paths, lua_paths))
  return nil
end
_2amodule_2a["sync-rtp"] = sync_rtp
local state = {["compiler-loaded?"] = false}
_2amodule_locals_2a["state"] = state
local function impl()
  local compiler = require("conjure.aniseed.deps.fennel")
  if not state["compiler-loaded?"] then
    state["compiler-loaded?"] = true
    sync_rtp(compiler)
  else
  end
  return compiler
end
_2amodule_2a["impl"] = impl
local function add_path(path)
  local fnl = impl()
  do end (fnl)["macro-path"] = (fnl["macro-path"] .. ";" .. path)
  return nil
end
_2amodule_2a["add-path"] = add_path
return _2amodule_2a
