local _2afile_2a = "test/fnl/conjure/client/clojure/nrepl/action-test.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.action-test"
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
local action = require("conjure.client.clojure.nrepl.action")
do end (_2amodule_locals_2a)["action"] = action
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    t["="](nil, action["extract-test-name-from-form"](""))
    t["="]("foo", action["extract-test-name-from-form"]("(deftest foo (+ 10 20))"))
    t["="]("foo", action["extract-test-name-from-form"]("(   deftest  foo  (+ 10 20))"))
    return t["="]("foo", action["extract-test-name-from-form"]("(deftest ^:kaocha/skip foo :xyz)"))
  end
  tests_24_auto["extract-test-name-from-form"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a