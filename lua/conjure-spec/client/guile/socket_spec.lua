-- [nfnl] fnl/conjure-spec/client/guile/socket_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local spy = _local_1_["spy"]
local assert = require("luassert.assert")
local guile = require("conjure.client.guile.socket")
local config = require("conjure.config")
local fake_socket = require("conjure-spec.client.guile.fake-socket")
local ts = require("conjure.tree-sitter")
require("conjure-spec.assertions")
package.loaded["conjure.remote.socket"] = fake_socket
local function _2_(_, _0)
  return true
end
ts["valid-str?"] = _2_
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
    it("returns (another-module) for ;\n(define-module ( another-module ))", _11_)
    local function _12_()
      return assert.are.equal("(a-module specification)", guile.context(";\n(define-module\n;some comments\n( a-module\n; more comments\n specification))"))
    end
    return it("returns (a-module specification) for ;\\n(define-module\\n;some comments\\n( a-module\\n; more comments\\n specification))", _12_)
  end
  describe("context extraction", _4_)
  local function _13_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _14_()
      local calls = {}
      local spy_send
      local function _15_(call)
        return table.insert(calls, call)
      end
      spy_send = _15_
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
    it("initializes (guile-user) when eval-str called on new repl in nil context", _14_)
    local function _16_()
      local calls = {}
      local spy_send
      local function _17_(call)
        return table.insert(calls, call)
      end
      spy_send = _17_
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
    it("initializes (guile-user) once when eval-str called twice on repl in nil context", _16_)
    local function _18_()
      local calls = {}
      local spy_send
      local function _19_(call)
        return table.insert(calls, call)
      end
      spy_send = _19_
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
    it("initializes (guile-user) again when eval-str disconnect eval-str is called in nil context", _18_)
    local function _20_()
      local calls = {}
      local spy_send
      local function _21_(call)
        return table.insert(calls, call)
      end
      spy_send = _21_
      local fake_repl
      local function _22_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _22_}
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
    return it("initializes (a-module) when eval-str in (guile-user) then eval-str in (a-module)", _20_)
  end
  describe("module initialization", _13_)
  local function _23_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil}}}}, {["overwrite?"] = true})
    local function _24_()
      local calls = {}
      local spy_send
      local function _25_(call)
        return table.insert(calls, call)
      end
      spy_send = _25_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local callback_results = {}
      local fake_callback
      local function _26_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _26_
      fake_socket["set-fake-repl"](fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when not connected", _24_)
    local function _27_()
      local calls = {}
      local spy_send
      local function _28_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _28_
      local fake_repl
      local function _29_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _29_}
      local expected_code = "%(%%conjure:get%-guile%-completions \"d\"%)"
      local callback_results = {}
      local fake_callback
      local function _30_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _30_
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
    it("Executes completions in REPL for prefix d with result define", _27_)
    local function _31_()
      local sent_callbacks = {}
      local spy_send
      local function _32_(_, callback)
        return table.insert(sent_callbacks, callback)
      end
      spy_send = _32_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local callback_results = {}
      local fake_callback
      local function _33_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _33_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile.completions({cb = fake_callback, prefix = "fu"})
      sent_callbacks[3]({{out = "(\"fun\" \"func\" \"future\")"}})
      guile.disconnect()
      return assert.same({"future", "fun", "func"}, callback_results[1])
    end
    return it("Puts last completion first for prefix fu with results fun func and future", _31_)
  end
  describe("completions", _23_)
  local function _34_()
    local function _35_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _36_(call)
        return table.insert(calls, call)
      end
      spy_send = _36_
      local fake_repl
      local function _37_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _37_}
      local expected_code = "(print \"Hello world\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[2])
    end
    it("Does not load completion code when completions disabled in config", _35_)
    local function _38_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = true}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _39_(call)
        return table.insert(calls, call)
      end
      spy_send = _39_
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
    it("Does load completion code when completions enabled in config", _38_)
    local function _40_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _41_(call)
        return table.insert(calls, call)
      end
      spy_send = _41_
      local fake_repl
      local function _42_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _42_}
      local callback_results = {}
      local fake_callback
      local function _43_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _43_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when connected but completions disabled", _40_)
    local function _44_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", host_port = nil, enable_completions = true}}}}, {["overwrite?"] = true})
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
      local callback_results = {}
      local fake_callback
      local function _47_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _47_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      set_repl_busy(fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    return it("Does not execute completions in REPL when connected but busy", _44_)
  end
  return describe("enable completions config setting", _34_)
end
return describe("conjure.client.guile.socket", _3_)
