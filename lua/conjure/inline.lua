-- [nfnl] Compiled from fnl/conjure/inline.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.inline"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a, config, nvim = autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nvim"] = nvim
local clear = (_2amodule_2a).clear
local display = (_2amodule_2a).display
local ns_id = (_2amodule_2a)["ns-id"]
local sanitise_text = (_2amodule_2a)["sanitise-text"]
local a0 = (_2amodule_locals_2a).a
local config0 = (_2amodule_locals_2a).config
local nvim0 = (_2amodule_locals_2a).nvim
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local ns_id0 = ((_2amodule_2a)["ns-id"] or nvim0.create_namespace(_2amodule_name_2a))
do end (_2amodule_2a)["ns-id"] = ns_id0
do local _ = {nil, nil} end
local function sanitise_text0(s)
  if a0["string?"](s) then
    return s:gsub("%s+", " ")
  else
    return ""
  end
end
_2amodule_2a["sanitise-text"] = sanitise_text0
do local _ = {sanitise_text0, nil} end
local function clear0(opts)
  local function _2_()
    return nvim0.buf_clear_namespace(a0.get(opts, "buf", 0), ns_id0, 0, -1)
  end
  return pcall(_2_)
end
_2amodule_2a["clear"] = clear0
do local _ = {clear0, nil} end
local function display0(opts)
  local hl_group = config0["get-in"]({"eval", "inline", "highlight"})
  local function _3_()
    clear0()
    return nvim0.buf_set_virtual_text(a0.get(opts, "buf", 0), ns_id0, opts.line, {{sanitise_text0(opts.text), hl_group}}, {})
  end
  return pcall(_3_)
end
_2amodule_2a["display"] = display0
do local _ = {display0, nil} end
return _2amodule_2a
