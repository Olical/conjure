-- [nfnl] fnl/conjure-spec/client/common-lisp/swank_spec.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local _local_2_ = require("plenary.busted")
local describe = _local_2_.describe
local it = _local_2_.it
local before_each = _local_2_.before_each
local a = autoload("conjure.nfnl.core")
local assert = autoload("luassert.assert")
local swank = autoload("conjure.client.common-lisp.swank")
local config = autoload("conjure.config")
require("conjure-spec.assertions")
local mock_tsc = require("conjure-spec.mock-tree-sitter-completions")
local mock_remote = require("conjure-spec.remote.mock-swank")
local mock_log = require("conjure-spec.mock-log")
package.loaded["conjure.remote.swank"] = mock_remote
package.loaded["conjure.tree-sitter-completions"] = mock_tsc
package.loaded["conjure.log"] = mock_log
local function format_swank_return(output)
  local formatted_output = string.sub(a["pr-str"](output), 2, -2)
  return string.format("(:return (:ok (\"\" \"(%s)\")) 0)", formatted_output)
end
local function _3_()
  local function _4_()
    return mock_remote["clear-send-calls"]()
  end
  before_each(_4_)
  local function _5_()
    local function _6_()
      local completion_cb_calls = {}
      local completion_cb
      local function _7_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _7_
      mock_tsc["set-mock-completions"]({})
      swank.completions({prefix = "", cb = completion_cb})
      return assert.same({}, completion_cb_calls[1])
    end
    it("returns empty list when not connected and no treesitter completions", _6_)
    local function _8_()
      local completion_cb_calls = {}
      local completion_cb
      local function _9_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _9_
      mock_tsc["set-mock-completions"]({})
      swank.connect({})
      swank.completions({prefix = "def", cb = completion_cb})
      a["get-in"](mock_remote["send-calls"], {2, "cb"})(format_swank_return("(\"defun\") \"def\""))
      swank.disconnect()
      assert["has-substring"]("swank:simple%-completions \\\"def\\\"", a["get-in"](mock_remote["send-calls"], {2, "msg"}))
      return assert.same({"defun"}, completion_cb_calls[1])
    end
    it("returns defun when connected and swank completions returns defun and no treesitter completions", _8_)
    local function _10_()
      local completion_cb_calls = {}
      local completion_cb
      local function _11_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _11_
      mock_tsc["set-mock-completions"]({"some"})
      swank.connect({})
      swank.completions({prefix = nil, cb = completion_cb})
      a["get-in"](mock_remote["send-calls"], {2, "cb"})(format_swank_return("(\"something\") \"\""))
      swank.disconnect()
      assert["has-substring"]("swank:simple%-completions nil", a["get-in"](mock_remote["send-calls"], {2, "msg"}))
      return assert.same({"some", "something"}, completion_cb_calls[1])
    end
    it("returns some something when prefix nil swank completions returns something and treesitter completions returns some", _10_)
    local function _12_()
      local completion_cb_calls = {}
      local completion_cb
      local function _13_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _13_
      mock_tsc["set-mock-completions"]({"defunct"})
      swank.connect({})
      swank.completions({prefix = "def", cb = completion_cb})
      a["get-in"](mock_remote["send-calls"], {2, "cb"})(format_swank_return("(\"defun\") \"def\""))
      swank.disconnect()
      return assert.same({"defunct", "defun"}, completion_cb_calls[1])
    end
    it("returns defunct defun when connected and swank completions returns defun and treesitter completions returns defunct", _12_)
    local function _14_()
      local completion_cb_calls = {}
      local completion_cb
      local function _15_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _15_
      mock_tsc["set-mock-completions"]({"defunct"})
      swank.completions({prefix = "def", cb = completion_cb})
      assert.same({}, mock_remote["send-calls"])
      return assert.same({"defunct"}, completion_cb_calls[1])
    end
    it("returns defunct when not connected and treesitter completions returns defunct", _14_)
    local function _16_()
      local completion_cb_calls = {}
      local completion_cb
      local function _17_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _17_
      mock_tsc["set-mock-completions"]({"symbol"})
      swank.connect({})
      swank.completions({prefix = "s", cb = completion_cb})
      a["get-in"](mock_remote["send-calls"], {2, "cb"})(format_swank_return("(\"symbol\") \"s\""))
      swank.disconnect()
      return assert.same({"symbol"}, completion_cb_calls[1])
    end
    return it("returns symbol when connected and swank completions returns symbol and treesitter completions returns symbol", _16_)
  end
  describe("completions", _5_)
  local function _18_()
    local function _19_()
      config.merge({client = {common_lisp = {swank = {enable_completions = false}}}}, {["overwrite?"] = true})
      local completion_cb_calls = {}
      local completion_cb
      local function _20_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _20_
      mock_tsc["set-mock-completions"]({"something"})
      swank.connect({})
      swank.completions({prefix = "s", cb = completion_cb})
      swank.disconnect()
      assert.are.equal(1, #mock_remote["send-calls"])
      return assert.same({}, completion_cb_calls[1])
    end
    it("returns no completions when connected and completions disabled", _19_)
    local function _21_()
      config.merge({client = {common_lisp = {swank = {enable_completions = true}}}}, {["overwrite?"] = true})
      local completion_cb_calls = {}
      local completion_cb
      local function _22_(res)
        return table.insert(completion_cb_calls, res)
      end
      completion_cb = _22_
      mock_tsc["set-mock-completions"]({"dots"})
      swank.connect({})
      swank.completions({prefix = "dot", cb = completion_cb})
      a["get-in"](mock_remote["send-calls"], {2, "cb"})(format_swank_return("(\"dotimes\") \"dot\""))
      swank.disconnect()
      return assert.same({"dots", "dotimes"}, completion_cb_calls[1])
    end
    return it("returns completions dots dotimes when connected with tree sitter results dots and completions enabled", _21_)
  end
  return describe("config", _18_)
end
return describe("conjure.client.common-lisp.swank", _3_)
