local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.aniseed.nvim.util"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.nvim")}
local nvim = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.nvim.util"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local normal
do
  local v_0_
  local function normal0(keys)
    return nvim.ex.silent(("exe \"normal! " .. keys .. "\""))
  end
  v_0_ = normal0
  _0_0["normal"] = v_0_
  normal = v_0_
end
local fn_bridge
do
  local v_0_
  local function fn_bridge0(viml_name, mod, lua_name, opts)
    local _let_0_ = (opts or {})
    local range = _let_0_["range"]
    local _return = _let_0_["return"]
    local _1_
    if range then
      _1_ = " range"
    else
      _1_ = ""
    end
    local _3_
    if (_return ~= false) then
      _3_ = "return"
    else
      _3_ = "call"
    end
    local _5_
    if range then
      _5_ = "\" . a:firstline . \", \" . a:lastline . \", "
    else
      _5_ = ""
    end
    return nvim.ex.function_((viml_name .. "(...)" .. _1_ .. "\n          " .. _3_ .. " luaeval(\"require('" .. mod .. "')['" .. lua_name .. "'](" .. _5_ .. "unpack(_A))\", a:000)\n          endfunction"))
  end
  v_0_ = fn_bridge0
  _0_0["fn-bridge"] = v_0_
  fn_bridge = v_0_
end
local with_out_str
do
  local v_0_
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
  v_0_ = with_out_str0
  _0_0["with-out-str"] = v_0_
  with_out_str = v_0_
end
return nil
