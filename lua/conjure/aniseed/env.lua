local _2afile_2a = "fnl/aniseed/env.fnl"
local _1_
do
  local name_4_auto = "conjure.aniseed.env"
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
    return {autoload("conjure.aniseed.compile"), autoload("conjure.aniseed.fennel"), autoload("conjure.aniseed.fs"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {compile = "conjure.aniseed.compile", fennel = "conjure.aniseed.fennel", fs = "conjure.aniseed.fs", nvim = "conjure.aniseed.nvim"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local compile = _local_4_[1]
local fennel = _local_4_[2]
local fs = _local_4_[3]
local nvim = _local_4_[4]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.aniseed.env"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local config_dir
do
  local v_23_auto = nvim.fn.stdpath("config")
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["config-dir"] = v_23_auto
  config_dir = v_23_auto
end
local quiet_require
do
  local v_23_auto
  local function quiet_require0(m)
    local ok_3f, err = nil, nil
    local function _8_()
      return require(m)
    end
    ok_3f, err = pcall(_8_)
    if (not ok_3f and not err:find(("module '" .. m .. "' not found"))) then
      return nvim.ex.echoerr(err)
    end
  end
  v_23_auto = quiet_require0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["quiet-require"] = v_23_auto
  quiet_require = v_23_auto
end
local init
do
  local v_23_auto
  do
    local v_25_auto
    local function init0(opts)
      local opts0
      if ("table" == type(opts)) then
        opts0 = opts
      else
        opts0 = {}
      end
      local glob_expr = "**/*.fnl"
      local fnl_dir = nvim.fn.expand((opts0.input or (config_dir .. fs["path-sep"] .. "fnl")))
      local lua_dir = nvim.fn.expand((opts0.output or (config_dir .. fs["path-sep"] .. "lua")))
      package.path = (package.path .. ";" .. lua_dir .. fs["path-sep"] .. "?.lua")
      local function _11_(path)
        if fs["macro-file-path?"](path) then
          return path
        else
          return string.gsub(path, ".fnl$", ".lua")
        end
      end
      if (((false ~= opts0.compile) or os.getenv("ANISEED_ENV_COMPILE")) and fs["glob-dir-newer?"](fnl_dir, lua_dir, glob_expr, _11_)) then
        fennel["add-path"]((fnl_dir .. fs["path-sep"] .. "?.fnl"))
        compile.glob(glob_expr, fnl_dir, lua_dir, opts0)
      end
      return quiet_require((opts0.module or "init"))
    end
    v_25_auto = init0
    _1_["init"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["init"] = v_23_auto
  init = v_23_auto
end
return nil
