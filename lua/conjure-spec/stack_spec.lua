-- [nfnl] Compiled from fnl/conjure-spec/stack_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local stack = require("conjure.stack")
local function _2_()
  local function _3_()
    local function _4_()
      return assert.same({1, 2, 3}, stack.push(stack.push(stack.push({}, 1), 2), 3))
    end
    return it("item on a stack", _4_)
  end
  describe("push", _3_)
  local function _5_()
    local function _6_()
      return assert.same({1, 2}, stack.pop({1, 2, 3}))
    end
    it("top of stack", _6_)
    local function _7_()
      return assert.same({}, stack.pop({}))
    end
    return it("empty stack", _7_)
  end
  describe("pop", _5_)
  local function _8_()
    local function _9_()
      return assert.are.equals(3, stack.peek({1, 2, 3}))
    end
    it("top of stack", _9_)
    local function _10_()
      return assert.are.equals(nil, stack.peek({}))
    end
    return it("empty stack", _10_)
  end
  return describe("peek", _8_)
end
return describe("conjure.stack", _2_)
