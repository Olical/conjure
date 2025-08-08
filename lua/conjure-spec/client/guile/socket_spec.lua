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
    return it("returns a result in the simple happy path", _14_)
  end
  describe("parse-guile-result", _13_)
  local function _15_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _16_()
      local expected_code = "(valid form)"
      local calls = {}
      local spy_send
      local function _17_(call)
        return table.insert(calls, call)
      end
      spy_send = _17_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("does eval string when valid-str? returns true", _16_)
    local function _18_()
      local calls = {}
      local spy_send
      local function _19_(call)
        return table.insert(calls, call)
      end
      spy_send = _19_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local function _20_(_)
        return false
      end
      guile["valid-str?"] = _20_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = "(some invalid form", context = nil})
      guile.disconnect()
      assert.same({}, calls)
      local function _21_(_)
        return true
      end
      guile["valid-str?"] = _21_
      return nil
    end
    return it("does not eval string when valid-str? returns false", _18_)
  end
  describe("eval-str", _15_)
  local function _22_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _23_()
      local calls = {}
      local spy_send
      local function _24_(call)
        return table.insert(calls, call)
      end
      spy_send = _24_
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
    it("initializes (guile-user) when eval-str called on new repl in nil context", _23_)
    local function _25_()
      local calls = {}
      local spy_send
      local function _26_(call)
        return table.insert(calls, call)
      end
      spy_send = _26_
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
    it("initializes (guile-user) once when eval-str called twice on repl in nil context", _25_)
    local function _27_()
      local calls = {}
      local spy_send
      local function _28_(call)
        return table.insert(calls, call)
      end
      spy_send = _28_
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
    it("initializes (guile-user) again when eval-str disconnect eval-str is called in nil context", _27_)
    local function _29_()
      local calls = {}
      local spy_send
      local function _30_(call)
        return table.insert(calls, call)
      end
      spy_send = _30_
      local fake_repl
      local function _31_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _31_}
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
    return it("initializes (a-module) when eval-str in (guile-user) then eval-str in (a-module)", _29_)
  end
  describe("module initialization", _22_)
  local function _32_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _33_()
      local calls = {}
      local spy_send
      local function _34_(call)
        return table.insert(calls, call)
      end
      spy_send = _34_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local callback_results = {}
      local fake_callback
      local function _35_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _35_
      fake_socket["set-fake-repl"](fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when not connected", _33_)
    local function _36_()
      local calls = {}
      local spy_send
      local function _37_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _37_
      local fake_repl
      local function _38_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _38_}
      local expected_code = "%(%%conjure:get%-guile%-completions \"d\"%)"
      local callback_results = {}
      local fake_callback
      local function _39_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _39_
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
    it("Executes completions in REPL for prefix d with result define", _36_)
    local function _40_()
      local sent_callbacks = {}
      local spy_send
      local function _41_(_, callback)
        return table.insert(sent_callbacks, callback)
      end
      spy_send = _41_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local callback_results = {}
      local fake_callback
      local function _42_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _42_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile.completions({cb = fake_callback, prefix = "fu"})
      sent_callbacks[3]({{out = "(\"fun\" \"func\" \"future\")"}})
      guile.disconnect()
      return assert.same({"future", "fun", "func"}, callback_results[1])
    end
    return it("Puts last completion first for prefix fu with results fun func and future", _40_)
  end
  describe("completions", _32_)
  local function _43_()
    local function _44_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _45_(call)
        return table.insert(calls, call)
      end
      spy_send = _45_
      local fake_repl
      local function _46_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _46_}
      local expected_code = "(print \"Hello world\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[2])
    end
    it("Does not load completion code when completions disabled in config", _44_)
    local function _47_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = true}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _48_(call)
        return table.insert(calls, call)
      end
      spy_send = _48_
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
    it("Does load completion code when completions enabled in config", _47_)
    local function _49_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _50_(call)
        return table.insert(calls, call)
      end
      spy_send = _50_
      local fake_repl
      local function _51_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _51_}
      local callback_results = {}
      local fake_callback
      local function _52_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _52_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when connected but completions disabled", _49_)
    local function _53_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = true}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _54_(call)
        return table.insert(calls, call)
      end
      spy_send = _54_
      local fake_repl
      local function _55_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _55_}
      local callback_results = {}
      local fake_callback
      local function _56_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _56_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      set_repl_busy(fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    return it("Does not execute completions in REPL when connected but busy", _53_)
  end
  return describe("enable completions config setting", _43_)
end
return describe("conjure.client.guile.socket", _2_)
