-- [nfnl] fnl/conjure-spec/buffer_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local assert = require("luassert.assert")
local buffer = require("conjure.buffer")
local function _2_()
  local function _3_()
    local function _4_()
      local original_directory = vim.o.directory
      local swap_dir = (vim.fn.tempname() .. "-swap")
      local buf_name = (vim.fn.tempname() .. "-conjure-log.fnl")
      vim.o.directory = (swap_dir .. "//")
      local buf = buffer["upsert-hidden"](buf_name)
      vim.o.directory = original_directory
      assert.is_false(vim.bo[buf].swapfile)
      assert.are.equals(0, vim.fn.isdirectory(swap_dir))
      return vim.api.nvim_buf_delete(buf, {force = true})
    end
    return it("never touches the swap directory, parallel spec processes race to create it", _4_)
  end
  return describe("upsert-hidden", _3_)
end
return describe("buffer", _2_)
