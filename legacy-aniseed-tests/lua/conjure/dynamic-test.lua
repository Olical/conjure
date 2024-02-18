local _2afile_2a = "test/fnl/conjure/dynamic-test.fnl"
local _2amodule_name_2a = "conjure.dynamic-test"
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
local dyn = require("conjure.dynamic")
do end (_2amodule_locals_2a)["dyn"] = dyn
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _1_(t)
    local foo
    local function _2_()
      return "bar"
    end
    foo = dyn.new(_2_)
    t["="]("function", type(foo))
    return t["="]("bar", foo())
  end
  tests_24_auto["new-and-unbox"] = _1_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _3_(t)
    local foo
    local function _4_()
      return 1
    end
    foo = dyn.new(_4_)
    t["="](1, foo())
    local function _5_()
      return 2
    end
    local function _6_(expected)
      return t["="](expected, foo())
    end
    dyn.bind({[foo] = _5_}, _6_, 2)
    local function _7_()
      return 2
    end
    local function _8_()
      t["="](2, foo())
      local function _9_()
        return 3
      end
      local function _10_()
        return t["="](3, foo())
      end
      dyn.bind({[foo] = _9_}, _10_)
      local function _11_()
        return error("OHNO")
      end
      local function _12_()
        local ok_3f, result = pcall(foo)
        t["="](false, ok_3f)
        return t["="](result, "OHNO")
      end
      dyn.bind({[foo] = _11_}, _12_)
      return t["="](2, foo())
    end
    dyn.bind({[foo] = _7_}, _8_)
    return t["="](1, foo())
  end
  tests_24_auto["bind"] = _3_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _13_(t)
    local foo
    local function _14_()
      return 1
    end
    foo = dyn.new(_14_)
    t["="](foo(), 1)
    local function _15_()
      return 2
    end
    local function _16_()
      t["="](foo(), 2)
      local function _17_()
        return 3
      end
      t["="](nil, dyn["set!"](foo, _17_))
      return t["="](foo(), 3)
    end
    dyn.bind({[foo] = _15_}, _16_)
    return t["="](foo(), 1)
  end
  tests_24_auto["set!"] = _13_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _18_(t)
    local foo
    local function _19_()
      return 1
    end
    foo = dyn.new(_19_)
    t["="](foo(), 1)
    local function _20_()
      return 2
    end
    local function _21_()
      t["="](foo(), 2)
      local function _22_()
        return 3
      end
      t["="](nil, dyn["set-root!"](foo, _22_))
      return t["="](foo(), 2)
    end
    dyn.bind({[foo] = _20_}, _21_)
    t["="](foo(), 3)
    local function _23_()
      return 4
    end
    dyn["set-root!"](foo, _23_)
    return t["="](foo(), 4)
  end
  tests_24_auto["set-root!"] = _18_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
do
  local tests_24_auto = ((_2amodule_2a)["aniseed/tests"] or {})
  local function _24_(t)
    local ok_3f, result = pcall(dyn.new, "foo")
    t["="](false, ok_3f)
    return t["ok?"](string.match(result, "conjure.dynamic values must always be wrapped in a function"))
  end
  tests_24_auto["type-guard"] = _24_
  _2amodule_2a["aniseed/tests"] = tests_24_auto
end
return _2amodule_2a