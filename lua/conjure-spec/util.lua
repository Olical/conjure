-- [nfnl] fnl/conjure-spec/util.fnl
local function with_buf(lines, f)
  local at
  local function _1_(cursor)
    return vim.api.nvim_win_set_cursor(0, cursor)
  end
  at = _1_
  vim.cmd("silent! syntax on")
  vim.cmd("silent! filetype on")
  vim.cmd("silent! set filetype=clojure")
  vim.cmd(("silent! edit " .. vim.fn.tempname() .. "_test.clj"))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  f(at)
  return vim.cmd("silent! bdelete!")
end
return {["with-buf"] = with_buf}
