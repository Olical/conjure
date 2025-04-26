-- [nfnl] fnl/conjure-spec/client/fennel/nfnl_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local fs = require("conjure.nfnl.fs")
local nfnlc = require("conjure.client.fennel.nfnl")
local function _2_()
  local function _3_()
    local function _4_()
      assert.is["nil"](nfnlc["module-path"](nil))
      return nil
    end
    it("returns nil when given nil", _4_)
    local function _5_()
      assert.are.equal("foo", nfnlc["module-path"](fs["full-path"]("fnl/foo.fnl")))
      return nil
    end
    it("handles single path segments", _5_)
    local function _6_()
      assert.are.equal("foo.bar.baz", nfnlc["module-path"](fs["full-path"]("fnl/foo/bar/baz.fnl")))
      return nil
    end
    return it("handles multiple path segments", _6_)
  end
  describe("module-path", _3_)
  local function _7_()
    local path = fs["full-path"]("fnl/foo.fnl")
    local function _8_()
      assert.is["function"](nfnlc["repl-for-path"](path))
      return nil
    end
    it("returns a new repl for a path", _8_)
    local function _9_()
      assert.is.equal(nfnlc["repl-for-path"](path), nfnlc["repl-for-path"](path))
      return nil
    end
    it("returns the same function each time", _9_)
    local function _10_()
      assert.are.same({30}, nfnlc["repl-for-path"](path)("(+ 10 20)"))
      return nil
    end
    return it("executes fennel and returns the results", _10_)
  end
  return describe("repl-for-path", _7_)
end
return describe("conjure.client.fennel.nfnl", _2_)
