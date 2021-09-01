local _2afile_2a = "fnl/aniseed/fennel.fnl"
local _2amodule_name_2a = "conjure.aniseed.fennel"
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
local fs, nvim = autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
local function sync_rtp(compiler)
  local sep = fs["path-sep"]
  local fnl_suffix = (sep .. "fnl" .. sep .. "?.fnl")
  local rtp = nvim.o.runtimepath
  local fnl_path = (rtp:gsub(",", (fnl_suffix .. ";")) .. fnl_suffix)
  local lua_path = fnl_path:gsub((sep .. "fnl" .. sep), (sep .. "lua" .. sep))
  local full_path = (fnl_path .. ";" .. lua_path)
  do end (compiler)["path"] = full_path
  compiler["macro-path"] = full_path
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
  end
  return compiler
end
_2amodule_2a["impl"] = impl
local function add_path(path)
  local fnl = impl()
  do end (fnl)["path"] = (fnl.path .. ";" .. path)
  return nil
end
_2amodule_2a["add-path"] = add_path
