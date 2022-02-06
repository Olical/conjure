local _2afile_2a = "fnl/aniseed/env.fnl"
local _2amodule_name_2a = "conjure.aniseed.env"
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
local compile, fennel, fs, nvim = autoload("conjure.aniseed.compile"), autoload("conjure.aniseed.fennel"), autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["compile"] = compile
_2amodule_locals_2a["fennel"] = fennel
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
local config_dir = nvim.fn.stdpath("config")
do end (_2amodule_locals_2a)["config-dir"] = config_dir
local function quiet_require(m)
  local ok_3f, err = nil, nil
  local function _1_()
    return require(m)
  end
  ok_3f, err = pcall(_1_)
  if (not ok_3f and not err:find(("module '" .. m .. "' not found"))) then
    return nvim.ex.echoerr(err)
  else
    return nil
  end
end
_2amodule_locals_2a["quiet-require"] = quiet_require
local function init(opts)
  local opts0
  if ("table" == type(opts)) then
    opts0 = opts
  else
    opts0 = {}
  end
  local glob_expr = "**/*.fnl"
  local fnl_dir = nvim.fn.expand((opts0.input or (config_dir .. fs["path-sep"] .. "fnl")))
  local lua_dir = nvim.fn.expand((opts0.output or (config_dir .. fs["path-sep"] .. "lua")))
  if opts0.output then
    package.path = (package.path .. ";" .. lua_dir .. fs["path-sep"] .. "?.lua")
  else
  end
  local function _5_(path)
    if fs["macro-file-path?"](path) then
      return path
    else
      return string.gsub(path, ".fnl$", ".lua")
    end
  end
  if (((false ~= opts0.compile) or os.getenv("ANISEED_ENV_COMPILE")) and fs["glob-dir-newer?"](fnl_dir, lua_dir, glob_expr, _5_)) then
    fennel["add-path"]((fnl_dir .. fs["path-sep"] .. "?.fnl"))
    compile.glob(glob_expr, fnl_dir, lua_dir, opts0)
  else
  end
  return quiet_require((opts0.module or "init"))
end
_2amodule_2a["init"] = init
return _2amodule_2a
