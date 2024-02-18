-- [nfnl] Compiled from fnl/conjure-spec/util_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local util = require("conjure.util")
local function _2_()
  local function _3_()
    return assert.equals("hello\15world", util["replace-termcodes"]("hello<C-o>world"))
  end
  return it("escapes sequences like <C-o>", _3_)
end
return describe("replace-termcodes", _2_)
