local _2afile_2a = "test/fnl/conjure/remote/transport/elisp-test.fnl"
local _2amodule_name_2a = "conjure.remote.transport.elisp-test"
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
local elisp = require("conjure.remote.transport.elisp")
do end (_2amodule_locals_2a)["elisp"] = elisp
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    t["="](nil, elisp.read(""))
    t["="]("foo", elisp.read("\"foo\""))
    t["="]("foo", elisp.read("  \"foo\"  "))
    t["="]("foo", elisp.read(":foo"))
    t["="]("foo", elisp.read("   :foo    "))
    t["="]("bar", elisp.read("   :foo \"hi\" \n :bar  "))
    t["="](0, elisp.read("0"))
    t["="](1, elisp.read(" 1  "))
    t["="](0.5, elisp.read("  0.5"))
    t["="](30, elisp.read("   30 "))
    t["="](30.2, elisp.read("   30.2 "))
    t["="](0.2, elisp.read(".2 "))
    t["="](-0.3, elisp.read("   -.3 "))
    t["="](-20.25, elisp.read("   -20.25 "))
    t["pr="]({}, elisp.read("()"))
    t["pr="]({{}, {}}, elisp.read("(()())"))
    t["pr="]({1, {2, 3, 4}, 5, {6, "seven"}, "eight", 9}, elisp.read("(1 (2 3 4) 5 (6 \"seven\") :eight 9)"))
    t["pr="]({1, 2, 3}, elisp.read("(1 2 3)"))
    return t["pr="]({"Class", ": ", {"value", "clojure.lang.PersistentArrayMap", 0}, {"newline"}, "Contents: ", {"newline"}, "  ", {"value", "a", 1}, " = ", {"value", "1", 2}, {"newline"}, "  ", {"value", "b", 3}, " = ", {"value", "2", 4}, {"newline"}}, elisp.read("(\"Class\" \": \" (:value \"clojure.lang.PersistentArrayMap\" 0) (:newline) \"Contents: \" (:newline) \"  \" (:value \"a\" 1) \" = \" (:value \"1\" 2) (:newline) \"  \" (:value \"b\" 3) \" = \" (:value \"2\" 4) (:newline))"))
  end
  tests_24_auto["read"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a