local _2afile_2a = "test/fnl/conjure/promise-test.fnl"
local _2amodule_name_2a = "conjure.promise-test"
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
local a, promise = require("conjure.aniseed.core"), require("conjure.promise")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["promise"] = promise
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    local p = promise.new()
    t["="](false, promise["done?"](p), "starts incomplete")
    promise.deliver(p, "foo")
    t["="](true, promise["done?"](p), "done after deliver")
    t["="]("foo", promise.close(p), "returns the value on close")
    promise.deliver(p, "bar")
    return t["="](nil, promise["done?"](p), "nil if already closed")
  end
  tests_24_auto["basics"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _2_(t)
    local p = promise.new()
    promise.deliver(p, "foo")
    promise.deliver(p, "bar")
    return t["="]("foo", promise.close(p), "only the first delivery works")
  end
  tests_24_auto["multiple-deliveries"] = _2_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _3_(t)
    local p = promise.new()
    local del = promise["deliver-fn"](p)
    local function _4_()
      return del("later")
    end
    vim.schedule(_4_)
    t["="](false, promise["done?"](p), "async delivery hasn't happened yet")
    t["="](0, promise.await(p), "await returns 0 from wait()")
    t["="](true, promise["done?"](p), "complete after await")
    return t["="]("later", promise.close(p), "value is correct")
  end
  tests_24_auto["async"] = _3_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a