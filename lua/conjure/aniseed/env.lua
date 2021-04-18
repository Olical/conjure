local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.aniseed.env"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.nvim")}
local nvim = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.env"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local config_dir = nvim.fn.stdpath("config")
local state = {["path-added?"] = false}
local function quiet_require(m)
  local ok_3f, err = nil, nil
  local function _1_()
    return require(m)
  end
  ok_3f, err = pcall(_1_)
  if (not ok_3f and not err:find(("module '" .. m .. "' not found"))) then
    return nvim.ex.echoerr(err)
  end
end
local init
do
  local v_0_
  local function init0(opts)
    local opts0
    if ("table" == type(opts)) then
      opts0 = opts
    else
      opts0 = {}
    end
    if ((false ~= opts0.compile) or os.getenv("ANISEED_ENV_COMPILE")) then
      local compile = require("conjure.aniseed.compile")
      local fennel = require("conjure.aniseed.fennel")
      if not state["path-added?"] then
        fennel["add-path"]((config_dir .. "/?.fnl"))
        state["path-added?"] = true
      end
      compile.glob("**/*.fnl", (config_dir .. (opts0.input or "/fnl")), (config_dir .. (opts0.output or "/lua")), opts0)
    end
    return quiet_require((opts0.module or "init"))
  end
  v_0_ = init0
  _0_0["init"] = v_0_
  init = v_0_
end
return nil
