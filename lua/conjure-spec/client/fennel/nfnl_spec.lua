-- [nfnl] fnl/conjure-spec/client/fennel/nfnl_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
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
  describe("repl-for-path", _7_)
  local function _11_()
    local function _12_()
      do
        local root_dir = vim.fn.tempname()
        local macro_path = (root_dir .. "/fnl/conjure-spec-reload-macros.fnlm")
        local eval_buf
        local function _13_()
          local result = nil
          local function _14_(_241)
            result = _241
            return nil
          end
          nfnlc["eval-str"]({["file-path"] = (root_dir .. "/fnl/app.fnl"), origin = "buf", code = "(import-macros m :conjure-spec-reload-macros) (m.version)", ["on-result"] = _14_})
          return result
        end
        eval_buf = _13_
        vim.fn.mkdir((root_dir .. "/fnl"), "p")
        vim.fn.writefile({"{:version (fn [] :v1)}"}, macro_path)
        assert.are.equal("\"v1\"", eval_buf())
        vim.fn.writefile({"{:version (fn [] :v2)}"}, macro_path)
        assert.are.equal("\"v2\"", eval_buf())
        vim.fn.delete(root_dir, "rf")
      end
      return nil
    end
    return it("picks up macro changes from disk when evaluating a whole buffer", _12_)
  end
  return describe("eval-str", _11_)
end
return describe("conjure.client.fennel.nfnl", _2_)
