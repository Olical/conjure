-- [nfnl] fnl/conjure-spec/uuid_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local a = require("conjure.nfnl.core")
local uuid = require("conjure.uuid")
local function _2_()
  local function is_in(word, xs)
    local function _3_(x)
      return (word == x)
    end
    return a.some(_3_, xs)
  end
  local function _4_()
    local function _5_()
      return assert.are.equals("Wirehaired Pointing Griffon", uuid.pretty("c7ef277c-160c-45f4-a5c3-03ac16a93788"))
    end
    it("into something human-readable", _5_)
    local function _6_()
      return assert.are["not"].equals("Wirehaired Pointing Griffon", uuid.pretty("d7ef277c-160c-45f4-a5c3-03ac16a93788"))
    end
    return it("into something human-readable but wrong string", _6_)
  end
  describe("turns a UUID", _4_)
  local function _7_()
    local function _8_()
      return assert.are.equals(true, is_in(uuid.pretty(uuid.v4()), uuid["cats-and-dogs"]))
    end
    it("is turned into something human-readable", _8_)
    local function _9_()
      return assert.are["not"].equals(nil, string.match(uuid.v4(), "^%x+-%x+-%x+-%x+-%x+$"))
    end
    return it("has the correct format", _9_)
  end
  return describe("generated UUID", _7_)
end
return describe("uuid", _2_)
