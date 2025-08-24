-- [nfnl] fnl/conjure-spec/tree-sitter-completions_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local tsc = require("conjure.tree-sitter-completions")
local function _2_()
  local function _3_()
    local filter = tsc["make-prefix-filter"]("aa")
    return assert.same({"aaa"}, filter({"aaa", "bbb", "abb"}))
  end
  it("filters to aaa from aaa bbb abb with prefix aa", _3_)
  local function _4_()
    local filter = tsc["make-prefix-filter"]("%")
    return assert.same({"%thing"}, filter({"aaa", "%thing", "b%b"}))
  end
  it("filters to %thing from aaa %thing b%b with prefix %", _4_)
  local function _5_()
    local filter = tsc["make-prefix-filter"](nil)
    return assert.same({"aaa", "word", "2342"}, filter({"aaa", "word", "2342"}))
  end
  return it("filters nothing from aaa word 2342 with prefix nil", _5_)
end
return describe("make-prefix-filter", _2_)
