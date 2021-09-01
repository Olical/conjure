local _2afile_2a = "fnl/aniseed/nvim/util.fnl"
local _2amodule_name_2a = "conjure.aniseed.nvim.util"
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
local nvim = autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["nvim"] = nvim
local function normal(keys)
  return nvim.ex.silent(("exe \"normal! " .. keys .. "\""))
end
_2amodule_2a["normal"] = normal
local function fn_bridge(viml_name, mod, lua_name, opts)
  local _let_1_ = (opts or {})
  local range = _let_1_["range"]
  local _return = _let_1_["return"]
  local _2_
  if range then
    _2_ = " range"
  else
    _2_ = ""
  end
  local _4_
  if (_return ~= false) then
    _4_ = "return"
  else
    _4_ = "call"
  end
  local _6_
  if range then
    _6_ = "\" . a:firstline . \", \" . a:lastline . \", "
  else
    _6_ = ""
  end
  return nvim.ex.function_((viml_name .. "(...)" .. _2_ .. "\n          " .. _4_ .. " luaeval(\"require('" .. mod .. "')['" .. lua_name .. "'](" .. _6_ .. "unpack(_A))\", a:000)\n          endfunction"))
end
_2amodule_2a["fn-bridge"] = fn_bridge
local function with_out_str(f)
  nvim.ex.redir("=> g:aniseed_nvim_util_out_str")
  do
    local ok_3f, err = pcall(f)
    nvim.ex.redir("END")
    nvim.ex.echon("")
    nvim.ex.redraw()
    if not ok_3f then
      error(err)
    end
  end
  return string.gsub(nvim.g.aniseed_nvim_util_out_str, "^(\n?)(.*)$", "%2%1")
end
_2amodule_2a["with-out-str"] = with_out_str
