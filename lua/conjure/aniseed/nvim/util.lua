local _0_0 = nil
do
  local name_23_0_ = "conjure.aniseed.nvim.util"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {nvim = "conjure.aniseed.nvim"}}
  return {require("conjure.aniseed.nvim")}
end
local _2_ = _1_(...)
local nvim = _2_[1]
do local _ = ({nil, _0_0, nil})[2] end
local normal = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function normal0(keys)
      return nvim.ex.silent(("exe \"normal! " .. keys .. "\""))
    end
    v_23_0_0 = normal0
    _0_0["normal"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["normal"] = v_23_0_
  normal = v_23_0_
end
local fn_bridge = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function fn_bridge0(viml_name, mod, lua_name, opts)
      local _3_ = (opts or {})
      local range = _3_["range"]
      local _return = _3_["return"]
      local function _4_()
        if range then
          return " range"
        else
          return ""
        end
      end
      local function _5_()
        if _return then
          return "return"
        else
          return "call"
        end
      end
      local function _6_()
        if range then
          return "\" . a:firstline . \", \" . a:lastline . \", "
        else
          return ""
        end
      end
      return nvim.ex.function_((viml_name .. "(...)" .. _4_() .. "\n          " .. _5_() .. " luaeval(\"require('" .. mod .. "')['" .. lua_name .. "'](" .. _6_() .. "unpack(_A))\", a:000)\n          endfunction"))
    end
    v_23_0_0 = fn_bridge0
    _0_0["fn-bridge"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["fn-bridge"] = v_23_0_
  fn_bridge = v_23_0_
end
local ft_map = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function ft_map0(ft, mode, from, to)
      return nvim.ex.autocmd("FileType", ft, (mode .. "map"), "<buffer>", ("<localleader>" .. from), to)
    end
    v_23_0_0 = ft_map0
    _0_0["ft-map"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["ft-map"] = v_23_0_
  ft_map = v_23_0_
end
local plug = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function plug0(cmd)
      return ("<Plug>(" .. cmd .. ")")
    end
    v_23_0_0 = plug0
    _0_0["plug"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["plug"] = v_23_0_
  plug = v_23_0_
end
return nil
