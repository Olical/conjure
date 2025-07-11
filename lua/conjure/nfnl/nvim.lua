-- [nfnl] fnl/nfnl/nvim.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local str = autoload("conjure.nfnl.string")
local function get_buf_content_as_string(buf)
  return (str.join("\n", vim.api.nvim_buf_get_lines((buf or 0), 0, -1, false)) or "")
end
return {["get-buf-content-as-string"] = get_buf_content_as_string}
