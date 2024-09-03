-- [nfnl] Compiled from fnl/conjure-spec/promise_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local promise = require("conjure.promise")
local function _2_()
  local function _3_()
    local p = promise.new()
    local function _4_()
      local function _5_()
        return assert.are.equals(false, promise["done?"](p))
      end
      it("starts incomplete", _5_)
      local function _6_()
        promise.deliver(p, "foo")
        return assert.are.equals(true, promise["done?"](p))
      end
      it("done after deliver", _6_)
      local function _7_()
        return assert.are.equals("foo", promise.close(p))
      end
      return it("returns the value on close", _7_)
    end
    return _4_
  end
  describe("basics", _3_())
  local function _8_()
    local p = promise.new()
    local function _9_()
      promise.deliver(p, "foo")
      promise.deliver(p, "bar")
      return assert.are.equals("foo", promise.close(p))
    end
    return it("only the first delivery works", _9_)
  end
  describe("multiple-deliveries", _8_)
  local function _10_()
    local p = promise.new()
    local del = promise["deliver-fn"](p)
    local function _11_()
      return del("later")
    end
    vim.schedule(_11_)
    local function _12_()
      local function _13_()
        return assert.are.equals(false, promise["done?"](p))
      end
      it("async delivery hasn't happened yet", _13_)
      local function _14_()
        return assert.are.equals(0, promise.await(p))
      end
      it("await returns 0 from wait()", _14_)
      local function _15_()
        return assert.are.equals(true, promise["done?"](p))
      end
      it("complete after await", _15_)
      local function _16_()
        return assert.are.equals("later", promise.close(p))
      end
      return it("value is correct", _16_)
    end
    return _12_
  end
  return describe("async", _10_())
end
return describe("conjure.promise", _2_)
