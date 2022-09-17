local _2afile_2a = "fnl/conjure/util.fnl"
local _2amodule_name_2a = "conjure.util"
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
local function wrap_require_fn_call(mod, f)
  local function _1_()
    return require(mod)[f]()
  end
  return _1_
end
_2amodule_2a["wrap-require-fn-call"] = wrap_require_fn_call
local function replace_termcodes(s)
  return nvim.replace_termcodes(s, true, false, true)
end
_2amodule_2a["replace-termcodes"] = replace_termcodes
return _2amodule_2a