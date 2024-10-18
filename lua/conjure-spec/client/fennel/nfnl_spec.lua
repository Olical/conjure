-- [nfnl] Compiled from fnl/conjure-spec/client/fennel/nfnl_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local fs = require("nfnl.fs")
local nfnlc = require("conjure.client.fennel.nfnl")
local function _2_()
  local function _3_()
    local function _4_()
      return assert.is["nil"](nfnlc["module-path"](nil))
    end
    it("returns nil when given nil", _4_)
    local function _5_()
      return assert.are.equal("foo", nfnlc["module-path"](fs["full-path"]("fnl/foo.fnl")))
    end
    it("handles single path segments", _5_)
    local function _6_()
      return assert.are.equal("foo.bar.baz", nfnlc["module-path"](fs["full-path"]("fnl/foo/bar/baz.fnl")))
    end
    return it("handles multiple path segments", _6_)
  end
  return describe("module-path", _3_)
end
return describe("conjure.client.fennel.nfnl", _2_)
