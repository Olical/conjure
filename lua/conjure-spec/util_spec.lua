-- [nfnl] fnl/conjure-spec/util_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
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
    return assert.same({"a"}, util["ordered-distinct"]({"a"}))
  end
  it("[:a] gives [:a]", _8_)
  local function _9_()
    return assert.same({"b", "a"}, util["ordered-distinct"]({"b", "b", "a"}))
  end
  it("[:b :b :a] gives [:b :a]", _9_)
  local function _10_()
    return assert.same({"b", "c", "a"}, util["ordered-distinct"]({"b", "c", "b", "a", "c", "a"}))
  end
  return it("[:b :c :b :a :c :a] gives [:b :c :a]", _10_)
end
return describe("ordered-distinct", _7_)
