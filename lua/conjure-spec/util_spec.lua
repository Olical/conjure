-- [nfnl] fnl/conjure-spec/util_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local util = require("conjure.util")
local function _2_()
  local function _3_()
    local function _4_()
      return "hello-world!"
    end
    package.loaded["example-module"] = {["wrapped-fn-example"] = _4_}
    return assert.equals("hello-world!", util["wrap-require-fn-call"]("example-module", "wrapped-fn-example")())
  end
  return it("creates a fn that requries a file and calls a fn", _3_)
end
describe("wrap-require-fn-call", _2_)
local function _5_()
  local function _6_()
    return assert.equals("hello\15world", util["replace-termcodes"]("hello<C-o>world"))
  end
  return it("escapes sequences like <C-o>", _6_)
end
describe("replace-termcodes", _5_)
local function _7_()
  local function _8_()
    return assert.same({"a", "b"}, util["concat-nodup"]({"a"}, {"b"}))
  end
  it("concats arrays [:a] and [:b] together", _8_)
  local function _9_()
    return assert.same({"a"}, util["concat-nodup"]({"a"}, {"a"}))
  end
  it("concats arrays [:a] and [:a] together to get [:a]", _9_)
  local function _10_()
    return assert.same({"a", "b", "c"}, util["concat-nodup"]({"a", "b"}, {"c", "a"}))
  end
  return it("concats arrays [:a :b] and [:c :a] together to get [:a :b :c]", _10_)
end
describe("concat-nodup", _7_)
local function _11_()
  local function _12_()
    return assert.same({"a"}, util.dedup({"a"}))
  end
  it("dedup array [:a] gives [:a]", _12_)
  local function _13_()
    return assert.same({"a", "b"}, util.dedup({"a", "b", "b"}))
  end
  it("dedup array [:a :b :b] gives [:a :b]", _13_)
  local function _14_()
    return assert.same({"a", "b", "c"}, util.dedup({"a", "b", "c", "b", "a", "c"}))
  end
  return it("dedup array [:a :b :c :b :a :c] gives [:a :b :c]", _14_)
end
describe("dedup", _11_)
local function _15_()
  local function _16_()
    local filter = util["make-prefix-filter"]("aa")
    return assert.same({"aaa"}, filter({"aaa", "bbb", "abb"}))
  end
  it("filters to aaa from aaa bbb abb with prefix aa", _16_)
  local function _17_()
    local filter = util["make-prefix-filter"]("%")
    return assert.same({"%thing"}, filter({"aaa", "%thing", "b%b"}))
  end
  it("filters to %thing from aaa %thing b%b with prefix %", _17_)
  local function _18_()
    local filter = util["make-prefix-filter"](nil)
    return assert.same({"aaa", "word", "2342"}, filter({"aaa", "word", "2342"}))
  end
  return it("filters nothing from aaa word 2342 with prefix nil", _18_)
end
return describe("make-prefix-filter", _15_)
