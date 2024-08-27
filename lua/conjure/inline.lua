-- [nfnl] Compiled from fnl/conjure/inline.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local config = autoload("conjure.config")
local ns_id = vim.api.nvim_create_namespace("conjure.inline")
local function sanitise_text(s)
  if a["string?"](s) then
    return s:gsub("%s+", " ")
  else
    return ""
  end
end
local function clear(opts)
  local function _3_()
    return vim.api.nvim_buf_clear_namespace(a.get(opts, "buf", 0), ns_id, 0, -1)
  end
  return pcall(_3_)
end
local function display(opts)
  local hl_group = config["get-in"]({"eval", "inline", "highlight"})
  local function _4_()
    clear()
    return vim.api.nvim_buf_set_virtual_text(a.get(opts, "buf", 0), ns_id, opts.line, {{sanitise_text(opts.text), hl_group}}, {})
  end
  return pcall(_4_)
end
return {["sanitise-text"] = sanitise_text, clear = clear, display = display}
