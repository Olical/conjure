-- [nfnl] Compiled from fnl/conjure-spec/linked-list_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local ll = require("conjure.linked-list")
local function _2_()
  local function _3_()
    local l = ll.create({1, 2, 3})
    local function _4_()
      return assert.are.equals(1, ll.val(l))
    end
    it("get first value", _4_)
    local function _5_()
      return assert.are.equals(2, ll.val(ll.next(l)))
    end
    it("get second value", _5_)
    local function _6_()
      return assert.are.equals(1, ll.val(ll.prev(ll.next(l))))
    end
    it("forward and back", _6_)
    local function _7_()
      return assert.are.equals(3, ll.val(ll.next(ll.next(l))))
    end
    it("last by steps", _7_)
    local function _8_()
      return assert.are.equals(nil, ll.next(ll.next(ll.next(l))))
    end
    it("off the end", _8_)
    local function _9_()
      return assert.are.equals(nil, ll.prev(l))
    end
    it("off the front", _9_)
    local function _10_()
      return assert.are.equals(nil, ll.val(nil))
    end
    it("val handles nils", _10_)
    local function _11_()
      return assert.are.equals(3, ll.val(ll.last(l)))
    end
    it("last", _11_)
    local function _12_()
      return assert.are.equals(1, ll.val(ll.first(l)))
    end
    it("first", _12_)
    local function _13_()
      return assert.are.equals(1, ll.val(ll.first(ll.last(l))))
    end
    return it("last then first", _13_)
  end
  describe("basics", _3_)
  local function _14_()
    local l = ll.create({1, 2, 3, 4, 5})
    local function _15_()
      local function _16_(_241)
        return (8 == ll.val(_241))
      end
      return assert.are.equals(nil, ll.val(ll["until"](_16_, l)))
    end
    it("nil if not found", _15_)
    local function _17_()
      local function _18_(_241)
        return (3 == ll.val(_241))
      end
      return assert.are.equals(3, ll.val(ll["until"](_18_, l)))
    end
    it("target node if found", _17_)
    local function _19_()
      local function _20_(_241)
        return (3 == ll.val(ll.next(_241)))
      end
      return assert.are.equals(2, ll.val(ll["until"](_20_, l)))
    end
    return it("can find the one before", _19_)
  end
  describe("until", _14_)
  local function _21_()
    local l = ll.cycle(ll.create({1, 2, 3}))
    local function _22_()
      return assert.are.equals(1, ll.val(l))
    end
    it("first is still first", _22_)
    local function _23_()
      return assert.are.equals(2, ll.val(ll.next(l)))
    end
    it("can still next", _23_)
    local function _24_()
      return assert.are.equals(3, ll.val(ll.next(ll.next(l))))
    end
    it("can still next next (last)", _24_)
    local function _25_()
      return assert.are.equals(1, ll.val(ll.next(ll.next(ll.next(l)))))
    end
    it("off the end loops", _25_)
    local function _26_()
      return assert.are.equals(3, ll.val(ll.prev(l)))
    end
    return it("off the front loops", _26_)
  end
  return describe("cycle", _21_)
end
return describe("conjure.linked-list", _2_)
