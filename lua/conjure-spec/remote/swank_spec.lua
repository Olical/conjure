-- [nfnl] fnl/conjure-spec/remote/swank_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local assert = require("luassert.assert")
local swank = require("conjure.remote.swank")
local function _2_()
  local function _3_()
    local function _4_()
      assert.same({":return", "12"}, {swank["message-id"]("(:return (:ok (\"\" \"(1 2)\")) 12)")})
      return assert.same({":emacs-rex", "3"}, {swank["message-id"]("(:emacs-rex (swank:eval-and-grab-output \"1\") \"*package*\" t 3)")})
    end
    it("reads the kind and id of requests and returns", _4_)
    local function _5_()
      return assert.is_nil(swank["message-id"]("(:debug-activate 42 1 nil)"))
    end
    return it("returns nil for events without an id", _5_)
  end
  describe("message-id", _3_)
  local function _6_()
    local function _7_()
      local msgs, rest = swank["split-messages"]("000003abc000002de00000")
      assert.same({"abc", "de"}, msgs)
      return assert.are.equal("00000", rest)
    end
    it("splits coalesced messages and keeps a partial one for later", _7_)
    local function _8_()
      local msgs, rest = swank["split-messages"]("000005ab")
      assert.same({}, msgs)
      return assert.are.equal("000005ab", rest)
    end
    return it("waits for the rest of a message split across reads", _8_)
  end
  return describe("split-messages", _6_)
end
return describe("conjure.remote.swank", _2_)
