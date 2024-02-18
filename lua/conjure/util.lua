-- [nfnl] Compiled from fnl/conjure/util.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.util"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local nvim = autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["nvim"] = nvim
local replace_termcodes = (_2amodule_2a)["replace-termcodes"]
local wrap_require_fn_call = (_2amodule_2a)["wrap-require-fn-call"]
local nvim0 = (_2amodule_locals_2a).nvim
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local function wrap_require_fn_call0(mod, f)
  local function _1_()
    return require(mod)[f]()
  end
  return _1_
end
_2amodule_2a["wrap-require-fn-call"] = wrap_require_fn_call0
do local _ = {wrap_require_fn_call0, nil} end
local function replace_termcodes0(s)
  return nvim0.replace_termcodes(s, true, false, true)
end
_2amodule_2a["replace-termcodes"] = replace_termcodes0
do local _ = {replace_termcodes0, nil} end
return _2amodule_2a
