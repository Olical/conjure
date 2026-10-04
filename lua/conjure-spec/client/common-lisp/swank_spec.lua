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
  describe("config", _18_)
  local function _23_()
    local function _24_()
      local logged = {}
      local orig_append = mock_log.append
      local function _25_(lines)
        return table.insert(logged, lines)
      end
      mock_log.append = _25_
      swank.connect({})
      swank["handle-event"](("(:debug 42 1 (\"break\" \"   [Condition of type SIMPLE-CONDITION]\" nil)" .. " ((\"CONTINUE\" \"Return from BREAK.\") (\"ABORT\" \"abort (#<THREAD \\\"worker\\\">)\"))" .. " ((0 \"(F 3)\") (1 \"(EVAL (F 3))\" (:restartable t))) (42))"))
      swank["invoke-restart"](0)
      swank.disconnect()
      mock_log.append = orig_append
      assert.same({"; Debugger level 1: break", ";    [Condition of type SIMPLE-CONDITION]", "; Restarts:", ";  0: [CONTINUE] Return from BREAK.", ";  1: [ABORT] abort (#<THREAD \"worker\">)", "; Backtrace:", ";  0: (F 3)", ";  1: (EVAL (F 3))"}, logged[1])
      return assert["has-substring"]("%(:emacs%-rex %(swank:invoke%-nth%-restart%-for%-emacs 1 0%) \"%*package%*\" 42 %d+%)", a["get-in"](mock_remote["send-calls"], {2, "msg"}))
    end
    it("logs the condition, restarts and backtrace, then invokes a restart by number", _24_)
    local function _26_()
      swank.connect({})
      swank["handle-event"]("(:debug-return 42 1 nil)")
      swank["invoke-restart"](0)
      swank.disconnect()
      return assert.are.equal(1, #mock_remote["send-calls"])
    end
    return it("does nothing but log when there is no debugger to answer", _26_)
  end
  describe("debugger", _23_)
  local function _27_()
    local function rec(id, form)
      local label = (7000000 + id)
      return ("(let ((#" .. label .. "=#:v (multiple-value-list " .. form .. "))) (push #" .. label .. "# (get :conjure-sticker-" .. vim.fn.getpid() .. "-" .. id .. " :values)) (values-list #" .. label .. "#))")
    end
    local function _28_()
      vim.cmd("new")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {"(defun f (x)", "  (+ 1 (* x x)))"})
      vim.api.nvim_win_set_cursor(0, {2, 9})
      swank["toggle-sticker"]()
      vim.api.nvim_win_set_cursor(0, {2, 3})
      swank["toggle-sticker"]()
      local code = "(defun f (x)\n  (+ 1 (* x x)))"
      local out = swank["instrument-stickers"](0, code, {start = {1, 0}, ["end"] = {2, 15}})
      vim.cmd("bwipeout!")
      return assert.are.equal(("(defun f (x)\n  " .. rec(2, ("(+ 1 " .. rec(1, "(* x x)") .. ")")) .. ")"), out)
    end
    it("wraps stickered forms, including nested ones, in the evaluated code", _28_)
    local function _29_()
      vim.cmd("new")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {"(* 2 3)"})
      vim.api.nvim_win_set_cursor(0, {1, 1})
      swank["toggle-sticker"]()
      swank["toggle-sticker"]()
      local out = swank["instrument-stickers"](0, "(* 2 3)", {start = {1, 0}, ["end"] = {1, 6}})
      vim.cmd("bwipeout!")
      return assert.are.equal("(* 2 3)", out)
    end
    return it("removes a sticker when toggled again and leaves code alone", _29_)
  end
  describe("stickers", _27_)
  local function _30_()
    local function _31_()
      local root = vim.fn.tempname()
      vim.fn.mkdir((root .. "/Data"), "p")
      vim.fn.writefile({"DEFUN", "../Body/m_defun.htm", "CAR", "../Body/f_car_c.htm"}, (root .. "/Data/Map_Sym.txt"))
      config.merge({client = {common_lisp = {swank = {hyperspec_root = root}}}}, {["overwrite?"] = true})
      assert.are.equal((root .. "/Body/m_defun.htm"), swank["hyperspec-file"]("defun"))
      assert.are.equal((root .. "/Body/f_car_c.htm"), swank["hyperspec-file"]("cl:car"))
      assert.is_nil(swank["hyperspec-file"]("no-such-symbol"))
      return vim.fn.delete(root, "rf")
    end
    return it("resolves symbols through Data/Map_Sym.txt under hyperspec_root", _31_)
  end
  describe("hyperspec", _30_)
  local function _32_()
    local function _33_()
      local logged = {}
      local orig_append = mock_log.append
      local function _34_(lines)
        return table.insert(logged, lines)
      end
      mock_log.append = _34_
      vim.cmd("new")
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {"(when a b)"})
      vim.api.nvim_win_set_cursor(0, {1, 1})
      swank.connect({})
      swank.macroexpand("swank-macroexpand-1")
      assert["has-substring"]("%(swank:swank%-macroexpand%-1 \\\"%(when a b%)\\\"%)", a["get-in"](mock_remote["send-calls"], {2, "msg"}))
      a["get-in"](mock_remote["send-calls"], {2, "cb"})("(:return (:ok (\"\" \"\\\"(IF A\n    B)\\\"\")) 2)")
      swank.disconnect()
      vim.cmd("bwipeout!")
      mock_log.append = orig_append
      return assert.same({"(IF A", "    B)"}, logged[1])
    end
    return it("sends the current form to swank-macroexpand-1 and logs the expansion", _33_)
  end
  describe("macroexpand", _32_)
  local function _35_()
    local function _36_()
      swank.connect({})
      swank["toggle-trace"]("sq")
      swank.disconnect()
      return assert["has-substring"]("%(swank:swank%-toggle%-trace \\\"sq\\\"%)", a["get-in"](mock_remote["send-calls"], {2, "msg"}))
    end
    it("toggles trace through swank", _36_)
    local function _37_()
      swank.connect({})
      swank["eval-str"]({code = "(sq 5)"})
      swank.disconnect()
      return assert["has-substring"]("%(let %(%(%*trace%-output%* %*standard%-output%*%)%) %(sq 5%)%)", a["get-in"](mock_remote["send-calls"], {2, "msg"}))
    end
    return it("binds *trace-output* to the captured stdout of every eval", _37_)
  end
  return describe("trace", _35_)
end
return describe("conjure.client.common-lisp.swank", _3_)
