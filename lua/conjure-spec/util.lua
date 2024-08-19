-- [nfnl] Compiled from fnl/conjure-spec/util.fnl by https://github.com/Olical/nfnl, do not edit.
local nvim = require("conjure.aniseed.nvim")
local function with_buf(lines, f)
  local at
  local function _1_(cursor)
    return nvim.win_set_cursor(0, cursor)
  end
  at = _1_
  nvim.ex.silent_("syntax", "on")
  nvim.ex.silent_("filetype", "on")
  nvim.ex.silent_("set", "filetype", "clojure")
  nvim.ex.silent_("edit", (nvim.fn.tempname() .. "_test.clj"))
  nvim.buf_set_lines(0, 0, -1, false, lines)
  f(at)
  return nvim.ex.silent_("bdelete!")
end
return {["with-buf"] = with_buf}
