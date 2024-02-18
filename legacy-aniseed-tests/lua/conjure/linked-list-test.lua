local _2afile_2a = "test/fnl/conjure/linked-list-test.fnl"
local _2amodule_name_2a = "conjure.linked-list-test"
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
local ll = require("conjure.linked-list")
do end (_2amodule_locals_2a)["ll"] = ll
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    local l = ll.create({1, 2, 3})
    t["="](1, ll.val(l), "get first value")
    t["="](2, ll.val(ll.next(l)), "get second value")
    t["="](1, ll.val(ll.prev(ll.next(l))), "forward and back")
    t["="](3, ll.val(ll.next(ll.next(l))), "last by steps")
    t["="](nil, ll.next(ll.next(ll.next(l))), "off the end")
    t["="](nil, ll.prev(l), "off the front")
    t["="](nil, ll.val(nil), "val handles nils")
    t["="](3, ll.val(ll.last(l)), "last")
    t["="](1, ll.val(ll.first(l)), "first")
    return t["="](1, ll.val(ll.first(ll.last(l))), "last then first")
  end
  tests_24_auto["basics"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _2_(t)
    local l = ll.create({1, 2, 3, 4, 5})
    local function _3_(_241)
      return (8 == ll.val(_241))
    end
    t["="](nil, ll.val(ll["until"](_3_, l)), "nil if not found")
    local function _4_(_241)
      return (3 == ll.val(_241))
    end
    t["="](3, ll.val(ll["until"](_4_, l)), "target node if found")
    local function _5_(_241)
      return (3 == ll.val(ll.next(_241)))
    end
    return t["="](2, ll.val(ll["until"](_5_, l)), "can find the one before")
  end
  tests_24_auto["until"] = _2_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _6_(t)
    local l = ll.cycle(ll.create({1, 2, 3}))
    t["="](1, ll.val(l), "first is still first")
    t["="](2, ll.val(ll.next(l)), "can still next")
    t["="](3, ll.val(ll.next(ll.next(l))), "can still next next (last)")
    t["="](1, ll.val(ll.next(ll.next(ll.next(l)))), "off the end loops")
    return t["="](3, ll.val(ll.prev(l)), "off the front loops")
  end
  tests_24_auto["cycle"] = _6_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a