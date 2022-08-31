local _2afile_2a = "fnl/conjure/inline.fnl"
local _2amodule_name_2a = "conjure.inline"
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
local a, config, nvim = autoload("conjure.aniseed.core"), autoload("conjure.config"), autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["nvim"] = nvim
local ns_id = ((_2amodule_2a)["ns-id"] or nvim.create_namespace(_2amodule_name_2a))
do end (_2amodule_2a)["ns-id"] = ns_id
local function sanitise_text(s)
  if a["string?"](s) then
    return s:gsub("%s+", " ")
  else
    return ""
  end
end
_2amodule_2a["sanitise-text"] = sanitise_text
local function clear(opts)
  local function _2_()
    return nvim.buf_clear_namespace(a.get(opts, "buf", 0), ns_id, 0, -1)
  end
  return pcall(_2_)
end
_2amodule_2a["clear"] = clear
local function display(opts)
  local hl_group = config["get-in"]({"eval", "inline", "highlight"})
  local function _3_()
    clear()
    return nvim.buf_set_virtual_text(a.get(opts, "buf", 0), ns_id, opts.line, {{sanitise_text(opts.text), hl_group}}, {})
  end
  return pcall(_3_)
end
_2amodule_2a["display"] = display
return _2amodule_2a