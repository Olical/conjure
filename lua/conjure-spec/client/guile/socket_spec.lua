-- [nfnl] fnl/conjure-spec/client/guile/socket_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local spy = _local_1_["spy"]
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
local function _2_()
  package.loaded["conjure.remote.socket"] = fake_socket
  local function _3_()
    local function _4_()
      return assert.are.equal(nil, guile.context("(print \"Hello World\")"))
    end
    it("returns nil for hello world", _4_)
    local function _5_()
      return assert.are.equal("(my-module)", guile.context("(define-module (my-module))"))
    end
    it("returns (my-module) for (define-module (my-module))", _5_)
    local function _6_()
      return assert.are.equal("(my-module)", guile.context("(define-module\n(my-module))"))
    end
    it("returns (my-module) for (define-module\\n(my-module))", _6_)
    local function _7_()
      return assert.are.equal("(my-module spaces)", guile.context("(define-module ( my-module  spaces   ))"))
    end
    it("returns (my-module spaces) for (define-module ( my-module  spaces   ))", _7_)
    local function _8_()
      return assert.are.equal(nil, guile.context(";(define-module (my-module))"))
    end
    it("returns nil for ;(define-module (my-module))", _8_)
    local function _9_()
      return assert.are.equal(nil, guile.context("(define-m;odule (my-module))"))
    end
    it("returns nil for (define-m;odule (my-module))", _9_)
    local function _10_()
      return assert.are.equal("(another-module)", guile.context(";\n(define-module ( another-module ))"))
    end
    it("returns (another-module) for ;\n(define-module ( another-module ))", _10_)
    local function _11_()
      return assert.are.equal("(a-module specification)", guile.context(";\n(define-module\n;some comments\n( a-module\n; more comments\n specification))"))
    end
    return it("returns (a-module specification) for ;\\n(define-module\\n;some comments\\n( a-module\\n; more comments\\n specification))", _11_)
  end
  describe("context extraction", _3_)
  local function _12_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", ["host-port"] = nil}}}}, {["overwrite?"] = true})
    local function _13_()
      local calls = {}
      local spy_send
      local function _14_(call)
        return table.insert(calls, call)
      end
      spy_send = _14_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local expected_code = "(print \"Hello world\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      assert.contains(completion_code_define_match, calls[2])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("initializes (guile-user) when eval-str called on new repl in nil context", _13_)
    local function _15_()
      local calls = {}
      local spy_send
      local function _16_(call)
        return table.insert(calls, call)
      end
      spy_send = _16_
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
    it("initializes (guile-user) once when eval-str called twice on repl in nil context", _15_)
    local function _17_()
      local calls = {}
      local spy_send
      local function _18_(call)
        return table.insert(calls, call)
      end
      spy_send = _18_
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
      assert.contains(completion_code_define_match, calls[5])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[6])
    end
    it("initializes (guile-user) again when eval-str disconnect eval-str is called in nil context", _17_)
    local function _19_()
      local calls = {}
      local spy_send
      local function _20_(call)
        return table.insert(calls, call)
      end
      spy_send = _20_
      local fake_repl
      local function _21_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _21_}
      local expected_module = "a-module"
      local expected_code = "(print \"Hello second call\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile["eval-str"]({code = expected_code, context = expected_module})
      guile.disconnect()
      assert.are.equal((",m " .. expected_module .. "\n,import (guile)"), calls[4])
      assert.contains(completion_code_define_match, calls[5])
      return assert.are.equal((",m " .. expected_module .. "\n" .. expected_code), calls[6])
    end
    return it("initializes (a-module) when eval-str in (guile-user) then eval-str in (a-module)", _19_)
  end
  describe("module initialization", _12_)
  local function _22_()
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", ["host-port"] = nil}}}}, {["overwrite?"] = true})
    local function _23_()
      local calls = {}
      local spy_send
      local function _24_(call)
        return table.insert(calls, call)
      end
      spy_send = _24_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local callback_results = {}
      local fake_callback
      local function _25_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _25_
      fake_socket["set-fake-repl"](fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    it("Does not execute completions in REPL when not connected", _23_)
    local function _26_()
      local calls = {}
      local spy_send
      local function _27_(call, callback)
        return table.insert(calls, {code = call, callback = callback})
      end
      spy_send = _27_
      local fake_repl
      local function _28_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _28_}
      local expected_code = "%(%%conjure:get%-guile%-completions \"d\"%)"
      local callback_results = {}
      local fake_callback
      local function _29_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _29_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile.completions({cb = fake_callback, prefix = "d"})
      calls[3].callback({{out = "(\"define\")"}})
      guile.disconnect()
      assert.contains(expected_code, calls[3].code)
      return assert.same({"define"}, callback_results[1])
    end
    it("Executes completions in REPL for prefix d with result define", _26_)
    local function _30_()
      local calls = {}
      local spy_send
      local function _31_(_, callback)
        return table.insert(calls, callback)
      end
      spy_send = _31_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local expected_code = "%(%%conjure:get%-guile%-completions \"fu\"%)"
      local callback_results = {}
      local fake_callback
      local function _32_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _32_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile.completions({cb = fake_callback, prefix = "fu"})
      calls[3]({{out = "(\"fun\" \"func\" \"future\")"}})
      guile.disconnect()
      return assert.same({"future", "fun", "func"}, callback_results[1])
    end
    return it("Puts last completion first for prefix fu with results fun func and future", _30_)
  end
  describe("completions", _22_)
  local function _33_()
    local function _34_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", ["host-port"] = nil, ["enable-completions"] = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _35_(call)
        return table.insert(calls, call)
      end
      spy_send = _35_
      local fake_repl
      local function _36_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _36_}
      local expected_code = "(print \"Hello world\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[2])
    end
    it("Does not load completion code when completions disabled in config", _34_)
    local function _37_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", ["host-port"] = nil, ["enable-completions"] = true}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _38_(call)
        return table.insert(calls, call)
      end
      spy_send = _38_
      local fake_repl = fake_socket["build-fake-repl"](spy_send)
      local expected_code = "(print \"Hello world\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      assert.contains(completion_code_define_match, calls[2])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("Does load completion code when completions enabled in config", _37_)
    local function _39_()
      config.merge({client = {guile = {socket = {pipename = "fake-pipe", ["host-port"] = nil, ["enable-completions"] = false}}}}, {["overwrite?"] = true})
      local calls = {}
      local spy_send
      local function _40_(call)
        return table.insert(calls, call)
      end
      spy_send = _40_
      local fake_repl
      local function _41_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _41_}
      local callback_results = {}
      local fake_callback
      local function _42_(result)
        return table.insert(callback_results, result)
      end
      fake_callback = _42_
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      set_repl_connected(fake_repl)
      guile.completions({cb = fake_callback, prefix = "something"})
      guile.disconnect()
      assert.same({}, calls)
      return assert.same({}, callback_results[1])
    end
    return it("Does not execute completions in REPL when connected but completions disabled", _39_)
  end
  return describe("enable completions config setting", _33_)
end
return describe("conjure.client.guile.socket", _2_)
