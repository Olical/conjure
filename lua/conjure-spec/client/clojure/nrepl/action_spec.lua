-- [nfnl] Compiled from fnl/conjure-spec/client/clojure/nrepl/action_spec.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local action = require("conjure.client.clojure.nrepl.action")
local function _2_()
  local function _3_()
    vim.g["conjure#client#clojure#nrepl#test#current_form_names"] = {"deftest"}
    local function _4_()
      return assert.are.equals(nil, action["extract-test-name-from-form"](""))
    end
    it("deftest form with missing name", _4_)
    local function _5_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(deftest foo (+ 10 20))"))
    end
    it("normal deftest form", _5_)
    local function _6_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(   deftest  foo  (+ 10 20))"))
    end
    it("deftest form with extra spaces", _6_)
    local function _7_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(deftest ^:kaocha/skip foo :xyz)"))
    end
    return it("deftest form with metadata", _7_)
  end
  return describe("extract-test-name-from-form", _3_)
end
return describe("client.clojure.nrepl.action", _2_)
