-- [nfnl] Compiled from fnl/conjure-spec/remote/stdio_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local a = require("nfnl.core")
local stdio = require("conjure.remote.stdio")
local function _2_()
  local function _3_()
    local function _4_()
      return assert.same({cmd = "foo", args = {}}, stdio["parse-cmd"]("foo"))
    end
    it("parses a string", _4_)
    local function _5_()
      return assert.same({cmd = "foo", args = {}}, stdio["parse-cmd"]({"foo"}))
    end
    it("parses a list of one string", _5_)
    local function _6_()
      return assert.same({cmd = "foo", args = {"bar", "baz"}}, stdio["parse-cmd"]("foo bar baz"))
    end
    it("parses a string with words separated by spaces", _6_)
    local function _7_()
      return assert.same({cmd = "foo", args = {"bar", "baz"}}, stdio["parse-cmd"]({"foo", "bar", "baz"}))
    end
    return it("parses a list of more than one string", _7_)
  end
  return describe("parse-cmd", _3_)
end
return describe("conjure.remote.stdio", _2_)
