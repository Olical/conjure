local _2afile_2a = "fnl/aniseed/nvim/util.fnl"
local _1_
do
  local name_4_auto = "conjure.aniseed.nvim.util"
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
    return {autoload("conjure.aniseed.nvim")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {nvim = "conjure.aniseed.nvim"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local nvim = _local_4_[1]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.aniseed.nvim.util"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local normal
do
  local v_23_auto
  do
    local v_25_auto
    local function normal0(keys)
      return nvim.ex.silent(("exe \"normal! " .. keys .. "\""))
    end
    v_25_auto = normal0
    _1_["normal"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["normal"] = v_23_auto
  normal = v_23_auto
end
local fn_bridge
do
  local v_23_auto
  do
    local v_25_auto
    local function fn_bridge0(viml_name, mod, lua_name, opts)
      local _let_8_ = (opts or {})
      local range = _let_8_["range"]
      local _return = _let_8_["return"]
      local _9_
      if range then
        _9_ = " range"
      else
        _9_ = ""
      end
      local _11_
      if (_return ~= false) then
        _11_ = "return"
      else
        _11_ = "call"
      end
      local _13_
      if range then
        _13_ = "\" . a:firstline . \", \" . a:lastline . \", "
      else
        _13_ = ""
      end
      return nvim.ex.function_((viml_name .. "(...)" .. _9_ .. "\n          " .. _11_ .. " luaeval(\"require('" .. mod .. "')['" .. lua_name .. "'](" .. _13_ .. "unpack(_A))\", a:000)\n          endfunction"))
    end
    v_25_auto = fn_bridge0
    _1_["fn-bridge"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["fn-bridge"] = v_23_auto
  fn_bridge = v_23_auto
end
local with_out_str
do
  local v_23_auto
  do
    local v_25_auto
    local function with_out_str0(f)
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
    v_25_auto = with_out_str0
    _1_["with-out-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-out-str"] = v_23_auto
  with_out_str = v_23_auto
end
return nil
