-- [nfnl] fnl/conjure/inline.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local config = autoload("conjure.config")
local M = define("conjure.inline")
local ns_id = vim.api.nvim_create_namespace("conjure.inline")
M["sanitise-text"] = function(s)
  if core["string?"](s) then
    return s:gsub("%s+", " ")
  else
    return ""
  end
end
M.clear = function(opts)
  local function _3_()
    return vim.api.nvim_buf_clear_namespace(core.get(opts, "buf", 0), ns_id, 0, -1)
  end
  return pcall(_3_)
end
M.display = function(opts)
  local hl_group = config["get-in"]({"eval", "inline", "highlight"})
  local function _4_()
    M.clear()
    return vim.api.nvim_buf_set_virtual_text(core.get(opts, "buf", 0), ns_id, opts.line, {{M["sanitise-text"](opts.text), hl_group}}, {})
  end
  return pcall(_4_)
end
return M
