-- [nfnl] Compiled from fnl/conjure-spec/util_spec.fnl by https://github.com/Olical/nfnl, do not edit.
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
return describe("replace-termcodes", _5_)
