-- [nfnl] fnl/conjure-spec/client/guile/socket_spec.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local _local_2_ = require("plenary.busted")
local describe = _local_2_["describe"]
local it = _local_2_["it"]
local before_each = _local_2_["before_each"]
local a = autoload("conjure.nfnl.core")
local assert = autoload("luassert.assert")
local guile = autoload("conjure.client.guile.socket")
local config = autoload("conjure.config")
require("conjure-spec.assertions")
local mock_socket = require("conjure-spec.client.guile.mock-socket")
local mock_tsc = require("conjure-spec.mock-tree-sitter-completions")
local mock_log = require("conjure-spec.mock-log")
package.loaded["conjure.remote.socket"] = mock_socket
package.loaded["conjure.tree-sitter-completions"] = mock_tsc
package.loaded["conjure.log"] = mock_log
local completion_code_define_match = "%(define%* %(%%conjure:get%-guile%-completions"
local function set_repl_connected(repl)
  repl["status"] = "connected"
  return nil
end
local function set_repl_busy(repl)
  repl["current"] = "some command"
  return nil
end
local function _3_()
  package.loaded["conjure.remote.socket"] = mock_socket
  local function _4_(_)
    return true
  end
  guile["valid-str?"] = _4_
  local function _5_()
    local function _6_()
      return assert.are.equal(nil, guile.context("(print \"Hello World\")"))
    end
    it("returns nil for hello world", _6_)
    local function _7_()
      return assert.are.equal("(my-module)", guile.context("(define-module (my-module))"))
    end
    it("returns (my-module) for (define-module (my-module))", _7_)
    local function _8_()
      return assert.are.equal("(my-module)", guile.context("(define-module\n(my-module))"))
    end
    it("returns (my-module) for (define-module\\n(my-module))", _8_)
    local function _9_()
      return assert.are.equal("(my-module spaces)", guile.context("(define-module ( my-module  spaces   ))"))
    end
    it("returns (my-module spaces) for (define-module ( my-module  spaces   ))", _9_)
    local function _10_()
      return assert.are.equal(nil, guile.context(";(define-module (my-module))"))
    end
    it("returns nil for ;(define-module (my-module))", _10_)
    local function _11_()
      return assert.are.equal(nil, guile.context("(define-m;odule (my-module))"))
    end
    it("returns nil for (define-m;odule (my-module))", _11_)
    local function _12_()
      return assert.are.equal("(another-module)", guile.context(";\n(define-module ( another-module ))"))
    end
    it("returns (another-module) for ;\\n(define-module ( another-module ))", _12_)
    local function _13_()
      return assert.are.equal("(a-module specification)", guile.context(";\n(define-module\n;some comments\n( a-module\n; more comments\n specification))"))
    end
    return it("returns (a-module specification) for ;\\n(define-module\\n;some comments\\n( a-module\\n; more comments\\n specification))", _13_)
  end
  describe("context extraction", _5_)
  local function _14_()
    local function _15_()
      return assert.are.same({["done?"] = true, result = "1234", ["error?"] = false}, guile["parse-guile-result"]("$1 = 1234\nscheme@(guile-user)> "))
    end
    it("returns a result in the simple happy path", _15_)
    local function _16_()
      local stray_output = {}
      local capture_stray_output
      local function _17_(output)
        return table.insert(stray_output, output)
      end
      capture_stray_output = _17_
      assert.are.same({["done?"] = true, result = nil, ["error?"] = false}, guile["parse-guile-result"]("hischeme@(guile-user)> ", capture_stray_output))
      return assert.are.same({{"; (out) hi"}}, stray_output)
    end
    it("handles single line output from display, missing a newline", _16_)
    local function _18_()
      return assert.are.same({["done?"] = true, ["error?"] = true}, guile["parse-guile-result"]("scheme@(guile-user) [1]> "))
    end
    it("prompts with an error number report as an error", _18_)
    local function _19_()
      local stray_output = {}
      local capture_stray_output
      local function _20_(output)
        return table.insert(stray_output, output)
      end
      capture_stray_output = _20_
      assert.are.same({["done?"] = true, result = "(values 10 20 30)", ["error?"] = false}, guile["parse-guile-result"]("hi\n$1 = 10\n$2 = 20\n$3 = 30\nscheme@(guile-user)> ", capture_stray_output))
      return assert.are.same({{"; (out) hi"}}, stray_output)
    end
    it("handles multiple return values", _19_)
    local function _21_()
      local stray_output = {}
      local capture_stray_output
      local function _22_(output)
        return table.insert(stray_output, output)
      end
      capture_stray_output = _22_
      assert.are.same({["done?"] = true, result = "(values 10 20 30)", ["error?"] = false}, guile["parse-guile-result"]("hi$1 = 10\n$2 = 20\n$3 = 30\nscheme@(guile-user)> ", capture_stray_output))
      return assert.are.same({{"; (out) hi"}}, stray_output)
    end
    return it("return values with stray output that lacks a new line are parsed correctly", _21_)
  end
  describe("parse-guile-result", _14_)
  local function _23_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _24_()
      local expected_code = "(valid form)"
      local calls = {}
      local spy_send
      local function _25_(call)
        return table.insert(calls, call)
      end
      spy_send = _25_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("does eval string when valid-str? returns true", _24_)
    local function _26_()
      local calls = {}
      local spy_send
      local function _27_(call)
        return table.insert(calls, call)
      end
      spy_send = _27_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local function _28_(_)
        return false
      end
      guile["valid-str?"] = _28_
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = "(some invalid form", context = nil})
      guile.disconnect()
      assert.same({}, calls)
      local function _29_(_)
        return true
      end
      guile["valid-str?"] = _29_
      return nil
    end
    return it("does not eval string when valid-str? returns false", _26_)
  end
  describe("eval-str", _23_)
  local function _30_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _31_()
      local calls = {}
      local spy_send
      local function _32_(call)
        return table.insert(calls, call)
      end
      spy_send = _32_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local expected_code = "(print \"Hello world\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      assert["has-substring"](completion_code_define_match, calls[2])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("initializes (guile-user) when eval-str called on new repl in nil context", _31_)
    local function _33_()
      local calls = {}
      local spy_send
      local function _34_(call)
        return table.insert(calls, call)
      end
      spy_send = _34_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local expected_code = "(print \"Hello second call\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[4])
    end
    it("initializes (guile-user) once when eval-str called twice on repl in nil context", _33_)
    local function _35_()
      local calls = {}
      local spy_send
      local function _36_(call)
        return table.insert(calls, call)
      end
      spy_send = _36_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local expected_code = "(print \"Hello second call\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile.disconnect()
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[4])
      assert["has-substring"](completion_code_define_match, calls[5])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[6])
    end
    it("initializes (guile-user) again when eval-str disconnect eval-str is called in nil context", _35_)
    local function _37_()
      local calls = {}
      local spy_send
      local function _38_(call)
        return table.insert(calls, call)
      end
      spy_send = _38_
      local mock_repl
      local function _39_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _39_}
      local expected_module = "a-module"
      local expected_code = "(print \"Hello second call\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile["eval-str"]({code = expected_code, context = expected_module})
      guile.disconnect()
      assert.are.equal((",m " .. expected_module .. "\n,import (guile)"), calls[4])
      assert["has-substring"](completion_code_define_match, calls[5])
      return assert.are.equal((",m " .. expected_module .. "\n" .. expected_code), calls[6])
    end
    return it("initializes (a-module) when eval-str in (guile-user) then eval-str in (a-module)", _37_)
  end
  describe("module initialization", _30_)
  local function _40_()
    local function _41_()
      return config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    end
    before_each(_41_)
    local function _42_()
      local calls = {}
      local spy_send
      local function _43_(call)
        return table.insert(calls, call)
      end
      spy_send = _43_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local callback_results = {}
      local mock_callback
      local function _44_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _44_
      mock_socket["set-mock-repl"](mock_repl)
      guile.completions({cb = mock_callback, prefix = "something"})
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when not connected", _42_)
    local function _45_()
      local calls = {}
      local spy_send
      local function _46_(call)
        return table.insert(calls, call)
      end
      spy_send = _46_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local callback_results = {}
      local mock_callback
      local function _47_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _47_
      mock_socket["set-mock-repl"](mock_repl)
      guile.completions({cb = mock_callback, prefix = "define"})
      return assert.same("define", callback_results[1][1])
    end
    it("Gets built-in results for define when execute completions and REPL not connected", _45_)
    local function _48_()
      local calls = {}
      local spy_send
      local function _49_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _49_
      local mock_repl
      local function _50_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _50_}
      local callback_results = {}
      local mock_callback
      local function _51_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _51_
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "dela"})
      local completion_call = calls[3]
      completion_call.callback({{out = "(\"dela-something\")"}})
      guile.disconnect()
      return assert.same({"delay", "dela-something"}, callback_results[1])
    end
    it("Executes completions in REPL for prefix dela with result delay and dela-something", _48_)
    local function _52_()
      local calls = {}
      local spy_send
      local function _53_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _53_
      local mock_repl
      local function _54_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _54_}
      local callback_results = {}
      local mock_callback
      local function _55_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _55_
      mock_tsc["set-mock-completions"]({"delalex"})
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = nil})
      calls[3].callback({{out = "(\"dela-something\")"}})
      guile.disconnect()
      return assert.are.equal("delalex", a["get-in"](callback_results, {1, 1}))
    end
    it("Executes completions with tree sitter results given prefix nil with result delalex as first result", _52_)
    local function _56_()
      local calls = {}
      local spy_send
      local function _57_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _57_
      local mock_repl
      local function _58_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _58_}
      local callback_results = {}
      local mock_callback
      local function _59_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _59_
      mock_tsc["set-mock-completions"]({"delalex"})
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "dela"})
      calls[3].callback({{out = "(\"dela-something\")"}})
      guile.disconnect()
      return assert.same({"delalex", "delay", "dela-something"}, callback_results[1])
    end
    it("Executes completions with tree sitter results given prefix dela with result delay dela-something and delalex", _56_)
    local function _60_()
      local calls = {}
      local spy_send
      local function _61_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _61_
      local mock_repl
      local function _62_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _62_}
      local expected_code = "%(%%conjure:get%-guile%-completions \"dela\"%)"
      local callback_results = {}
      local mock_callback
      local function _63_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _63_
      mock_tsc["set-mock-completions"]({"delay"})
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "dela"})
      calls[3].callback({{out = "(\"delay\")"}})
      guile.disconnect()
      return assert.same({"delay"}, callback_results[1])
    end
    it("Deduplicates results when built-in tree sitter and repl results given prefix are all delay", _60_)
    local function _64_()
      local sent_callbacks = {}
      local spy_send
      local function _65_(_, callback)
        return table.insert(sent_callbacks, callback)
      end
      spy_send = _65_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local callback_results = {}
      local mock_callback
      local function _66_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _66_
      mock_tsc["set-mock-completions"]({})
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "fu"})
      sent_callbacks[3]({{out = "(\"fun\" \"func\" \"future\")"}})
      guile.disconnect()
      return assert.same({"future", "fun", "func"}, callback_results[1])
    end
    return it("Puts last completion first for prefix fu with results fun func and future", _64_)
  end
  describe("completions", _40_)
  local function _67_()
    local function _68_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _69_(call)
        return table.insert(calls, call)
      end
      spy_send = _69_
      local mock_repl
      local function _70_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _70_}
      local expected_code = "(print \"Hello world\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[2])
    end
    it("Does not load completion code when completions disabled in config", _68_)
    local function _71_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = true}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _72_(call)
        return table.insert(calls, call)
      end
      spy_send = _72_
      local mock_repl = mock_socket["build-mock-repl"](spy_send)
      local expected_code = "(print \"Hello world\")"
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      assert["has-substring"](completion_code_define_match, calls[2])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("Does load completion code when completions enabled in config", _71_)
    local function _73_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _74_(call)
        return table.insert(calls, call)
      end
      spy_send = _74_
      local mock_repl
      local function _75_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _75_}
      local callback_results = {}
      local mock_callback
      local function _76_(result)
        return table.insert(callback_results, result)
      end
      mock_callback = _76_
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      guile.completions({cb = mock_callback, prefix = "define"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when connected but completions disabled", _73_)
    local function _77_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = true}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _78_(call)
        return table.insert(calls, call)
      end
      spy_send = _78_
      local mock_repl
      local function _79_()
      end
      mock_repl = {send = spy_send, status = nil, destroy = _79_}
      local callback_results = {}
      local fake_callback
      local function _80_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _80_
      mock_socket["set-mock-repl"](mock_repl)
      guile.connect({})
      set_repl_connected(mock_repl)
      set_repl_busy(mock_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    return it("Does not execute completions in REPL when connected but busy", _77_)
  end
  return describe("enable completions config setting", _67_)
end
return describe("conjure.client.guile.socket", _3_)
