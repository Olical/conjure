local _2afile_2a = "test/fnl/conjure/test/buffer.fnl"
local _2amodule_name_2a = "conjure.test.buffer"
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
local nvim = require("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["nvim"] = nvim
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
_2amodule_2a["with-buf"] = with_buf
return _2amodule_2a