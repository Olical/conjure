local _2afile_2a = "test/fnl/conjure/stack-test.fnl"
local _2amodule_name_2a = "conjure.stack-test"
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
local stack = require("conjure.stack")
do end (_2amodule_locals_2a)["stack"] = stack
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    return t["pr="]({1, 2, 3}, stack.push(stack.push(stack.push({}, 1), 2), 3))
  end
  tests_24_auto["push"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _2_(t)
    t["pr="]({1, 2}, stack.pop({1, 2, 3}))
    return t["pr="]({}, stack.pop({}))
  end
  tests_24_auto["pop"] = _2_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _3_(t)
    t["="](3, stack.peek({1, 2, 3}))
    return t["="](nil, stack.peek({}))
  end
  tests_24_auto["peek"] = _3_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a