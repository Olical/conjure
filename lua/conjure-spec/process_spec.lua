-- [nfnl] Compiled from fnl/conjure-spec/process_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local nvim = require("conjure.aniseed.nvim")
local process = require("conjure.process")
local function _2_()
  local function _3_()
    local function _4_()
      return assert.are.equals(false, process["executable?"]("nope-this-does-not-exist"))
    end
    it("thing's that don't exist return false", _4_)
    local function _5_()
      return assert.are.equals(true, process["executable?"]("sh"))
    end
    it("sh should always exist, I hope", _5_)
    local function _6_()
      return assert.are.equals(true, process["executable?"]("sh foo bar"))
    end
    return it("only the first word is checked", _6_)
  end
  describe("executable?", _3_)
  local function _7_()
    local sh = process.execute("sh")
    local function _8_()
      return assert.are.equals("table", type(sh))
    end
    it("we get a table to identify the process", _8_)
    local function _9_()
      return assert.are.equals(true, process["running?"](sh))
    end
    it("it starts out as running", _9_)
    local function _10_()
      return assert.are.equals(false, process["running?"](nil))
    end
    it("the running check handles nils", _10_)
    local function _11_()
      return assert.are.equals(1, nvim.fn.bufexists(sh.buf))
    end
    it("a buffer is created for the terminal / process", _11_)
    local function _12_()
      return assert.are.equals(sh, process.stop(sh))
    end
    it("stopping returns the process table", _12_)
    local function _13_()
      return assert.are.equals(sh, process.stop(sh))
    end
    it("stopping is idempotent", _13_)
    local function _14_()
      return assert.are.equals(false, process["running?"](sh))
    end
    return it("now it's not running", _14_)
  end
  describe("execute-stop-lifecycle", _7_)
  local function _15_()
    local state = {args = nil}
    local sh
    local function _16_(...)
      state["args"] = {...}
      return nil
    end
    sh = process.execute("sh", {["on-exit"] = _16_})
    local function _17_()
      process.stop(sh)
      return assert.same({sh}, state.args)
    end
    return it("called and given the proc", _17_)
  end
  return describe("on-exit-hook", _15_)
end
return describe("conjure.process", _2_)
