local _2afile_2a = "fnl/aniseed/nvim/util.fnl"
local _2amodule_name_2a = "conjure.aniseed.nvim.util"
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
  local function _2_()
    if range then
      return " range"
    else
      return ""
    end
  end
  local function _3_()
    if (_return ~= false) then
      return "return"
    else
      return "call"
    end
  end
  local function _4_()
    if range then
      return "\" . a:firstline . \", \" . a:lastline . \", "
    else
      return ""
    end
  end
  return nvim.ex.function_((viml_name .. "(...)" .. _2_() .. "\n          " .. _3_() .. " luaeval(\"require('" .. mod .. "')['" .. lua_name .. "'](" .. _4_() .. "unpack(_A))\", a:000)\n          endfunction"))
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
    else
    end
  end
  return string.gsub(nvim.g.aniseed_nvim_util_out_str, "^(\n?)(.*)$", "%2%1")
end
_2amodule_2a["with-out-str"] = with_out_str
return _2amodule_2a
