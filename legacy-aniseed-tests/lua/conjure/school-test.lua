local _2afile_2a = "test/fnl/conjure/school-test.fnl"
local _2amodule_name_2a = "conjure.school-test"
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
local nvim, school = require("conjure.aniseed.nvim"), require("conjure.school")
do end (_2amodule_locals_2a)["nvim"] = nvim
_2amodule_locals_2a["school"] = school
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    school.start()
    t["="]("conjure-school.fnl", nvim.fn.bufname())
    t["pr="]({"(module user.conjure-school"}, nvim.buf_get_lines(0, 0, 1, false))
    return nvim.ex.bdelete("conjure-school.fnl")
  end
  tests_24_auto["start"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a