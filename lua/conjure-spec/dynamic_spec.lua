-- [nfnl] Compiled from fnl/conjure-spec/dynamic_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local dyn = require("conjure.dynamic")
local function _2_()
  local function _3_()
    local foo
    local function _4_()
      return "bar"
    end
    foo = dyn.new(_4_)
    local function _5_()
      return assert.are.equals("function", type(foo))
    end
    it("new returns a function", _5_)
    local function _6_()
      return assert.are.equals("bar", foo())
    end
    return it("function is wrapped", _6_)
  end
  describe("new-and-unbox", _3_)
  local function _7_()
    local foo
    local function _8_()
      return 1
    end
    foo = dyn.new(_8_)
    local function _9_()
      return assert.are.equals(1, foo())
    end
    it("one level deep", _9_)
    local function _10_()
      local function _11_()
        return 2
      end
      local function _12_(expected)
        return assert.are.equals(expected, foo())
      end
      return dyn.bind({[foo] = _11_}, _12_, 2)
    end
    it("two levels deep", _10_)
    local function _13_()
      local function _14_()
        return 2
      end
      local function _15_()
        assert.are.equals(2, foo())
        local function _16_()
          return 3
        end
        local function _17_()
          return assert.are.equals(3, foo())
        end
        dyn.bind({[foo] = _16_}, _17_)
        local function _18_()
          return error("OHNO")
        end
        local function _19_()
          local ok_3f, result = pcall(foo)
          assert.are.equals(false, ok_3f)
          return assert.are.equals(result, "OHNO")
        end
        dyn.bind({[foo] = _18_}, _19_)
        return assert.are.equals(2, foo())
      end
      return dyn.bind({[foo] = _14_}, _15_)
    end
    return it("no more than two levels deep", _13_)
  end
  describe("bind", _7_)
  local function _20_()
    local foo
    local function _21_()
      return 1
    end
    foo = dyn.new(_21_)
    local function _22_()
      return assert.are.equals(foo(), 1)
    end
    it("one level deep", _22_)
    local function _23_()
      local function _24_()
        return 2
      end
      local function _25_()
        assert.are.equals(foo(), 2)
        local function _26_()
          return 3
        end
        assert.are.equals(nil, dyn["set!"](foo, _26_))
        return assert.are.equals(foo(), 3)
      end
      return dyn.bind({[foo] = _24_}, _25_)
    end
    return it("more than two levels deep", _23_)
  end
  describe("set!", _20_)
  local function _27_()
    local foo
    local function _28_()
      return 1
    end
    foo = dyn.new(_28_)
    local function _29_()
      return assert.are.equals(foo(), 1)
    end
    it("one level deep", _29_)
    local function _30_()
      local function _31_()
        return 2
      end
      local function _32_()
        assert.are.equals(foo(), 2)
        local function _33_()
          return 3
        end
        assert.are.equals(nil, dyn["set-root!"](foo, _33_))
        return assert.are.equals(foo(), 2)
      end
      return dyn.bind({[foo] = _31_}, _32_)
    end
    it("three levels deep", _30_)
    local function _34_()
      return assert.are.equals(foo(), 3)
    end
    it("remembers binding from three levels deep", _34_)
    local function _35_()
      local function _36_()
        return 4
      end
      return dyn["set-root!"](foo, _36_)
    end
    it("four levels deep", _35_)
    local function _37_()
      return assert.are.equals(foo(), 4)
    end
    return it("remembers binding from four levels deep", _37_)
  end
  describe("set-root!", _27_)
  local function _38_()
    local ok_3f, result = pcall(dyn.new, "foo")
    local function _39_()
      return assert.are.equals(false, ok_3f)
    end
    it("direct call of conjure.dynamic value fails", _39_)
    local function _40_()
      assert.is_not_nil(string.match(result, "conjure.dynamic values must always be wrapped in a function"))
      return nil
    end
    return it("returns why failed", _40_)
  end
  return describe("type-guard", _38_)
end
return describe("conjure.dynamic", _2_)
