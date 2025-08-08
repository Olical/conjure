-- [nfnl] fnl/conjure-spec/client/guile/socket_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local guile = require("conjure.client.guile.socket")
local config = require("conjure.config")
local fake_socket = require("conjure-spec.client.guile.fake-socket")
require("conjure-spec.assertions")
local completion_code_define_match = "%(define%* %(%%conjure:get%-guile%-completions"
local function set_repl_connected(repl)
  repl["status"] = "connected"
  return nil
end
local function set_repl_busy(repl)
  repl["current"] = "some command"
  return nil
end
local function _2_()
  package.loaded["conjure.remote.socket"] = fake_socket
  local function _3_(_)
    return true
  end
  guile["valid-str?"] = _3_
  local function _4_()
    local function _5_()
      return assert.are.equal(nil, guile.context("(print \"Hello World\")"))
    end
    it("returns nil for hello world", _5_)
    local function _6_()
      return assert.are.equal("(my-module)", guile.context("(define-module (my-module))"))
    end
    it("returns (my-module) for (define-module (my-module))", _6_)
    local function _7_()
      return assert.are.equal("(my-module)", guile.context("(define-module\n(my-module))"))
    end
    it("returns (my-module) for (define-module\\n(my-module))", _7_)
    local function _8_()
      return assert.are.equal("(my-module spaces)", guile.context("(define-module ( my-module  spaces   ))"))
    end
    it("returns (my-module spaces) for (define-module ( my-module  spaces   ))", _8_)
    local function _9_()
      return assert.are.equal(nil, guile.context(";(define-module (my-module))"))
    end
    it("returns nil for ;(define-module (my-module))", _9_)
    local function _10_()
      return assert.are.equal(nil, guile.context("(define-m;odule (my-module))"))
    end
    it("returns nil for (define-m;odule (my-module))", _10_)
    local function _11_()
      return assert.are.equal("(another-module)", guile.context(";\n(define-module ( another-module ))"))
    end
    it("returns (another-module) for ;\\n(define-module ( another-module ))", _11_)
    local function _12_()
      return assert.are.equal("(a-module specification)", guile.context(";\n(define-module\n;some comments\n( a-module\n; more comments\n specification))"))
    end
    return it("returns (a-module specification) for ;\\n(define-module\\n;some comments\\n( a-module\\n; more comments\\n specification))", _12_)
  end
  describe("context extraction", _4_)
  local function _13_()
    local function _14_()
      return assert.are.same({["done?"] = true, result = "1234", ["error?"] = false}, guile["parse-guile-result"]("$1 = 1234\nscheme@(guile-user)> "))
    end
    it("returns a result in the simple happy path", _14_)
    local function _15_()
      local stray_output = {}
      local capture_stray_output
      local function _16_(output)
        return table.insert(stray_output, output)
      end
      capture_stray_output = _16_
      assert.are.same({["done?"] = true, result = nil, ["error?"] = false}, guile["parse-guile-result"]("hischeme@(guile-user)> ", capture_stray_output))
      return assert.are.same({{"; (out) hi"}}, stray_output)
    end
    it("handles single line output from display, missing a newline", _15_)
    local function _17_()
      return assert.are.same({["done?"] = true, ["error?"] = true}, guile["parse-guile-result"]("scheme@(guile-user) [1]> "))
    end
    return it("prompts with an error number report as an error", _17_)
  end
  describe("parse-guile-result", _13_)
  local function _18_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _19_()
      local expected_code = "(valid form)"
      local calls = {}
      local spy_send
      local function _20_(call)
        return table.insert(calls, call)
      end
      spy_send = _20_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("does eval string when valid-str? returns true", _19_)
    local function _21_()
      local calls = {}
      local spy_send
      local function _22_(call)
        return table.insert(calls, call)
      end
      spy_send = _22_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local function _23_(_)
        return false
      end
      guile["valid-str?"] = _23_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = "(some invalid form", context = nil})
      guile.disconnect()
      assert.same({}, calls)
      local function _24_(_)
        return true
      end
      guile["valid-str?"] = _24_
      return nil
    end
    return it("does not eval string when valid-str? returns false", _21_)
  end
  describe("eval-str", _18_)
  local function _25_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _26_()
      local calls = {}
      local spy_send
      local function _27_(call)
        return table.insert(calls, call)
      end
      spy_send = _27_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local expected_code = "(print \"Hello world\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      assert["has-substring"](completion_code_define_match, calls[2])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("initializes (guile-user) when eval-str called on new repl in nil context", _26_)
    local function _28_()
      local calls = {}
      local spy_send
      local function _29_(call)
        return table.insert(calls, call)
      end
      spy_send = _29_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local expected_code = "(print \"Hello second call\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[4])
    end
    it("initializes (guile-user) once when eval-str called twice on repl in nil context", _28_)
    local function _30_()
      local calls = {}
      local spy_send
      local function _31_(call)
        return table.insert(calls, call)
      end
      spy_send = _31_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local expected_code = "(print \"Hello second call\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile.disconnect()
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[4])
      assert["has-substring"](completion_code_define_match, calls[5])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[6])
    end
    it("initializes (guile-user) again when eval-str disconnect eval-str is called in nil context", _30_)
    local function _32_()
      local calls = {}
      local spy_send
      local function _33_(call)
        return table.insert(calls, call)
      end
      spy_send = _33_
      local fake_repl
      local function _34_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _34_}
      local expected_module = "a-module"
      local expected_code = "(print \"Hello second call\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile["eval-str"]({code = expected_code, context = expected_module})
      guile.disconnect()
      assert.are.equal((",m " .. expected_module .. "\n,import (guile)"), calls[4])
      assert["has-substring"](completion_code_define_match, calls[5])
      return assert.are.equal((",m " .. expected_module .. "\n" .. expected_code), calls[6])
    end
    return it("initializes (a-module) when eval-str in (guile-user) then eval-str in (a-module)", _32_)
  end
  describe("module initialization", _25_)
  local function _35_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _36_()
      local calls = {}
      local spy_send
      local function _37_(call)
        return table.insert(calls, call)
      end
      spy_send = _37_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local callback_results = {}
      local fake_callback
      local function _38_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _38_
      fake_socket["set-fake-repl"](fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when not connected", _36_)
    local function _39_()
      local calls = {}
      local spy_send
      local function _40_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _40_
      local fake_repl
      local function _41_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _41_}
      local expected_code = "%(%%conjure:get%-guile%-completions \"d\"%)"
      local callback_results = {}
      local fake_callback
      local function _42_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _42_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile.completions({cb = fake_callback, prefix = "d"})
      local completion_call = calls[3]
      completion_call.callback({{out = "(\"define\")"}})
      guile.disconnect()
      assert["has-substring"](expected_code, completion_call.code)
      return assert.same({"define"}, callback_results[1])
    end
    it("Executes completions in REPL for prefix d with result define", _39_)
    local function _43_()
      local sent_callbacks = {}
      local spy_send
      local function _44_(_, callback)
        return table.insert(sent_callbacks, callback)
      end
      spy_send = _44_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local callback_results = {}
      local fake_callback
      local function _45_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _45_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile.completions({cb = fake_callback, prefix = "fu"})
      sent_callbacks[3]({{out = "(\"fun\" \"func\" \"future\")"}})
      guile.disconnect()
      return assert.same({"future", "fun", "func"}, callback_results[1])
    end
    return it("Puts last completion first for prefix fu with results fun func and future", _43_)
  end
  describe("completions", _35_)
  local function _46_()
    local function _47_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _48_(call)
        return table.insert(calls, call)
      end
      spy_send = _48_
      local fake_repl
      local function _49_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _49_}
      local expected_code = "(print \"Hello world\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[2])
    end
    it("Does not load completion code when completions disabled in config", _47_)
    local function _50_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = true}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _51_(call)
        return table.insert(calls, call)
      end
      spy_send = _51_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local expected_code = "(print \"Hello world\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      assert["has-substring"](completion_code_define_match, calls[2])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("Does load completion code when completions enabled in config", _50_)
    local function _52_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _53_(call)
        return table.insert(calls, call)
      end
      spy_send = _53_
      local fake_repl
      local function _54_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _54_}
      local callback_results = {}
      local fake_callback
      local function _55_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _55_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when connected but completions disabled", _52_)
    local function _56_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = true}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _57_(call)
        return table.insert(calls, call)
      end
      spy_send = _57_
      local fake_repl
      local function _58_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _58_}
      local callback_results = {}
      local fake_callback
      local function _59_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _59_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      set_repl_busy(fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    return it("Does not execute completions in REPL when connected but busy", _56_)
  end
  return describe("enable completions config setting", _46_)
end
return describe("conjure.client.guile.socket", _2_)
