-- [nfnl] Compiled from fnl/conjure-spec/client/clojure/nrepl/auto-repl_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local a = require("nfnl.core")
local auto_repl = require("conjure.client.clojure.nrepl.auto-repl")
local function _2_()
  local function _3_()
    local function _4_()
      return assert.same({subject = "foo"}, auto_repl.enportify("foo"))
    end
    it("subject is foo", _4_)
    local _let_5_ = auto_repl.enportify("foo:$port")
    local subject = _let_5_["subject"]
    local port = _let_5_["port"]
    local function _6_()
      return assert.are.equals("string", type(port))
    end
    it("port is in string form", _6_)
    local function _7_()
      local _8_ = tonumber(port)
      return assert.is_true(((1000 < _8_) and (_8_ < 100000)))
    end
    it("port number is between 1000 and 100000", _7_)
    local function _9_()
      return assert.are.equals(("foo:" .. port), subject)
    end
    return it("subject is foo:port", _9_)
  end
  return describe("enportify", _3_)
end
return describe("client.clojure.nrepl.auto-repl", _2_)
