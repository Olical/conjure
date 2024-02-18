-- [nfnl] Compiled from fnl/nfnl/nvim.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local str = autoload("nfnl.string")
local function get_buf_content_as_string(buf)
  local function _2_()
    return str.join("\n", vim.api.nvim_buf_get_lines((buf or 0), 0, -1, false))
  end
  return (_2_() or "")
end
return {["get-buf-content-as-string"] = get_buf_content_as_string}
