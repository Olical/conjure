-- [nfnl] Compiled from fnl/conjure-spec/text_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local text = require("conjure.text")
local function _2_()
  local function _3_()
    local function _4_()
      return assert.are.equals("", text["left-sample"]("", 0))
    end
    it("handles empty strings", _4_)
    local function _5_()
      return assert.are.equals("f", text["left-sample"]("f", 1))
    end
    it("handles single characters", _5_)
    local function _6_()
      return assert.are.equals("foo bar", text["left-sample"]("foo bar", 10))
    end
    it("does nothing if correct", _6_)
    local function _7_()
      return assert.are.equals("foo bar", text["left-sample"]("foo    \n\n bar", 10))
    end
    it("replaces lots of whitespace with a space", _7_)
    local function _8_()
      return assert.are.equals("foo bar b...", text["left-sample"]("foo    \n\n bar \n\n baz", 10))
    end
    it("cuts the string if too long", _8_)
    local function _9_()
      return assert.are.equals("foo bar", text["left-sample"]("   foo \n \n bar  \n", 10))
    end
    return it("trims leading and trailing whitespace", _9_)
  end
  describe("left-sample", _3_)
  local function _10_()
    local function _11_()
      return assert.are.equals("...o bar baz", text["right-sample"]("foo    \n\n bar \n\n baz", 10))
    end
    return it("same as left-sample, but we want the right", _11_)
  end
  describe("right-sample", _10_)
  local function _12_()
    local function _13_()
      return assert.same({""}, text["split-lines"](""), "")
    end
    it("nothing to nothing", _13_)
    local function _14_()
      return assert.same({"foo", "bar"}, text["split-lines"]("foo\nbar"), "")
    end
    it("basic split", _14_)
    local function _15_()
      return assert.same({"foo", "", "bar"}, text["split-lines"]("foo\n\nbar"), "")
    end
    it("blank lines", _15_)
    local function _16_()
      return assert.same({"foo", "bar"}, text["split-lines"]("foo\13\nbar"), "")
    end
    return it("Windows CRLF", _16_)
  end
  describe("split-lines", _12_)
  local function _17_()
    local function _18_()
      return assert.same({"; "}, text["prefixed-lines"]("", "; "))
    end
    it("nothing to nothing", _18_)
    local function _19_()
      return assert.same({"; foo"}, text["prefixed-lines"]("foo", "; "))
    end
    it("single line", _19_)
    local function _20_()
      return assert.same({"; foo", "; bar"}, text["prefixed-lines"]("foo\nbar", "; "))
    end
    return it("multiple lines", _20_)
  end
  describe("prefixed-lines", _17_)
  local function _21_()
    local function _22_()
      return assert.are.equals(true, text["starts-with"]("foobar", "foo"))
    end
    it("foo", _22_)
    local function _23_()
      return assert.are.equals(true, text["starts-with"]("foobar", "foob"))
    end
    it("foob", _23_)
    local function _24_()
      return assert.are.equals(false, text["starts-with"]("foobar", "foox"))
    end
    it("foox", _24_)
    local function _25_()
      return assert.are.equals(nil, text["starts-with"](nil, "ohno"))
    end
    return it("ohno", _25_)
  end
  describe("starts-with", _21_)
  local function _26_()
    local function _27_()
      return assert.are.equals(true, text["ends-with"]("foobar", "bar"))
    end
    it("bar", _27_)
    local function _28_()
      return assert.are.equals(true, text["ends-with"]("foobar", "obar"))
    end
    it("obar", _28_)
    local function _29_()
      return assert.are.equals(false, text["ends-with"]("foobar", "xbar"))
    end
    it("xbar", _29_)
    local function _30_()
      return assert.are.equals(nil, text["ends-with"](nil, "ohno"))
    end
    return it("ohno", _30_)
  end
  describe("ends-with", _26_)
  local function _31_()
    local function _32_()
      return assert.are.equals("()", text["first-and-last-chars"]("(hello-world)"))
    end
    it("of parentheses around words", _32_)
    local function _33_()
      return assert.are.equals("", text["first-and-last-chars"](""))
    end
    it("of empty string", _33_)
    local function _34_()
      return assert.are.equals("(", text["first-and-last-chars"]("("))
    end
    it("of single opening parenthesis", _34_)
    local function _35_()
      return assert.are.equals(nil, text["first-and-last-chars"](nil))
    end
    return it("of nil", _35_)
  end
  describe("first-and-last-chars", _31_)
  local function _36_()
    local function _37_()
      return assert.same({}, text.chars())
    end
    it("of nothing", _37_)
    local function _38_()
      return assert.same({}, text.chars(""))
    end
    it("of empty string", _38_)
    local function _39_()
      return assert.same({"a", "b", "c"}, text.chars("abc"))
    end
    return it("of \"abc\"", _39_)
  end
  describe("chars", _36_)
  local function _40_()
    local function _41_()
      return assert.are.equals("", text["upper-first"](""))
    end
    it("of empty string", _41_)
    local function _42_()
      return assert.are.equals("A", text["upper-first"]("A"))
    end
    it("of \"A\"", _42_)
    local function _43_()
      return assert.are.equals("A", text["upper-first"]("a"))
    end
    it("of \"a\"", _43_)
    local function _44_()
      return assert.are.equals("Foo bar bAZ 5", text["upper-first"]("foo bar bAZ 5"))
    end
    it("of first word of many words", _44_)
    local function _45_()
      return assert.are.equals(nil, text["upper-first"](nil))
    end
    it("of nil", _45_)
    local function _46_()
      return assert.are.equals("123", text["upper-first"]("123"))
    end
    return it("of string of numbers", _46_)
  end
  return describe("upper-first", _40_)
end
return describe("text", _2_)
