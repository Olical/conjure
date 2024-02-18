local _2afile_2a = "test/fnl/conjure/client/clojure/nrepl/auto-repl-test.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.auto-repl-test"
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
local auto_repl = require("conjure.client.clojure.nrepl.auto-repl")
do end (_2amodule_locals_2a)["auto-repl"] = auto_repl
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    t["pr="]({subject = "foo"}, auto_repl.enportify("foo"))
    local _let_2_ = auto_repl.enportify("foo:$port")
    local subject = _let_2_["subject"]
    local port = _let_2_["port"]
    t["="]("string", type(port))
    t["ok?"]((function(_3_,_4_,_5_) return (_3_ < _4_) and (_4_ < _5_) end)(1000,tonumber(port),100000))
    return t["="](("foo:" .. port), subject)
  end
  tests_24_auto["enportify"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a