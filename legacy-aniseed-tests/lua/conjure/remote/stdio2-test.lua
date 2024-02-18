local _2afile_2a = "test/fnl/conjure/remote/stdio2-test.fnl"
local _2amodule_name_2a = "conjure.remote.stdio2-test"
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
local stdio = require("conjure.remote.stdio2")
do end (_2amodule_locals_2a)["stdio"] = stdio
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    t["pr="]({cmd = "foo", args = {}}, stdio["parse-cmd"]("foo"))
    t["pr="]({cmd = "foo", args = {}}, stdio["parse-cmd"]({"foo"}))
    t["pr="]({cmd = "foo", args = {"bar", "baz"}}, stdio["parse-cmd"]("foo bar baz"))
    return t["pr="]({cmd = "foo", args = {"bar", "baz"}}, stdio["parse-cmd"]({"foo", "bar", "baz"}))
  end
  tests_24_auto["parse-cmd"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a