-- [nfnl] fnl/conjure-spec/school_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local school = require("conjure.school")
local function _2_()
  school.start()
  local function _3_()
    return assert.are.equals("conjure-school.fnl", vim.fn.bufname())
  end
  it("buffer has correct name", _3_)
  local function _4_()
    return assert.same({"(local school (require :conjure.school))"}, vim.api.nvim_buf_get_lines(0, 0, 1, false))
  end
  it("buffer requires conjure.school module", _4_)
  return vim.cmd.bdelete("conjure-school.fnl")
end
return describe("running :ConjureSchool", _2_)
