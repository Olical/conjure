-- [nfnl] fnl/conjure-spec/client/clojure/nrepl/action_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
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
  describe("extract-test-name-from-form", _3_)
  local function _8_()
    vim.g["conjure#client#clojure#nrepl#test#current_form_names"] = {"tsetfed"}
    vim.g["conjure#client#clojure#nrepl#test#runner"] = "clojurescript"
    local function _9_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(deftest foo (+ 10 20))"))
    end
    return it("test-runner-specific deftest form", _9_)
  end
  describe("extract-test-runner-specific-name-from-form", _8_)
  local function _10_()
    vim.g["conjure#client#clojure#nrepl#test#current_form_names"] = {"deftest"}
    vim.g["conjure#client#clojure#nrepl#test#runner"] = "unknown-runner"
    local function _11_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(deftest foo (+ 10 20))"))
    end
    return it("test-runner-specific-unknown deftest form - uses fallback", _11_)
  end
  describe("extract-test-runner-specific-name-from-form-with-unknown-runner", _10_)
  local function _12_()
    vim.g["conjure#client#clojure#nrepl#test#current_form_names"] = nil
    vim.g["conjure#client#clojure#nrepl#test#runner"] = "unknown-runner"
    local function _13_()
      local function _14_()
        return action["extract-test-name-from-form"]("(deftest foo (+ 10 20))")
      end
      return assert.error.matches(_14_, "No value for current-form-names in test or runner configuration", 1, true)
    end
    return it("test-runner-specific-unknown deftest form - returns an error", _13_)
  end
  return describe("extract-test-runner-specific-name-from-form-with-no-config", _12_)
end
return describe("client.clojure.nrepl.action", _2_)
