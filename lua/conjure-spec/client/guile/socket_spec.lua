-- [nfnl] fnl/conjure-spec/client/guile/socket_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local spy = _local_1_["spy"]
local assert = require("luassert.assert")
local guile = require("conjure.client.guile.socket")
local config = require("conjure.config")
local fake_socket = require("conjure-spec.client.guile.fake-socket")
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
    config.merge({client = {guile = {socket = {pipename = "fake-pipe", ["host-port"] = nil}}}})
    local function _13_()
      local calls = {}
      local spy_send
      local function _14_(call)
        return table.insert(calls, call)
      end
      spy_send = _14_
      local fake_repl
      local function _15_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _15_}
      local expected_code = "(print \"Hello world\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      fake_repl["status"] = "connected"
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[1])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[2])
    end
    it("initializes (guile-user) when eval-str called on new repl in nil context", _13_)
    local function _16_()
      local calls = {}
      local spy_send
      local function _17_(call)
        return table.insert(calls, call)
      end
      spy_send = _17_
      local fake_repl
      local function _18_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _18_}
      local expected_code = "(print \"Hello second call\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      fake_repl["status"] = "connected"
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile["eval-str"]({code = expected_code, context = nil})
      guile.disconnect()
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[3])
    end
    it("initializes (guile-user) once when eval-str called twice on repl in nil context", _16_)
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
      local expected_code = "(print \"Hello second call\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      fake_repl["status"] = "connected"
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile.disconnect()
      guile.connect({})
      fake_repl["status"] = "connected"
      guile["eval-str"]({code = expected_code, context = nil})
      assert.are.equal(",m (guile-user)\n,import (guile)", calls[3])
      return assert.are.equal((",m (guile-user)\n" .. expected_code), calls[4])
    end
    it("initializes (guile-user) again when eval-str disconnect eval-str is called in nil context", _19_)
    local function _22_()
      local calls = {}
      local spy_send
      local function _23_(call)
        return table.insert(calls, call)
      end
      spy_send = _23_
      local fake_repl
      local function _24_()
      end
      fake_repl = {send = spy_send, status = nil, destroy = _24_}
      local expected_module = "a-module"
      local expected_code = "(print \"Hello second call\")"
      fake_socket["set-fake-repl"](fake_repl)
      guile.connect({})
      fake_repl["status"] = "connected"
      guile["eval-str"]({code = "(first-call)", context = nil})
      guile["eval-str"]({code = expected_code, context = expected_module})
      assert.are.equal((",m " .. expected_module .. "\n,import (guile)"), calls[3])
      return assert.are.equal((",m " .. expected_module .. "\n" .. expected_code), calls[4])
    end
    return it("initializes (a-module) when eval-str in (guile-user) then eval-str in (a-module)", _22_)
  end
  return describe("module initialization", _12_)
end
return describe("conjure.client.guile.socket", _2_)
