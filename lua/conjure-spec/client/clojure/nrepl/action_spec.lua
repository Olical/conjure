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
    local function _9_()
      for _, t in ipairs({"function", "macro", "special-form", "var", "local", "namespace", "class", "keyword", "resource", "method", "static-method", "field", "static-field", "data-reader"}) do
        assert.are.equals(t, action["clojure->vim-completion"]({candidate = "x", type = t}).kind)
      end
      return nil
    end
    it("uses the full nREPL type as the kind", _9_)
    local function _10_()
      assert.is_nil(action["clojure->vim-completion"]({candidate = "x"}).kind)
      return assert.is_nil(action["clojure->vim-completion"]({candidate = "x", type = ""}).kind)
    end
    it("has no kind when the type is missing or empty", _10_)
    local function _11_()
      return assert.same({word = "map", menu = "clojure.core ([f coll]) ([f c1 c2])", info = "Returns a lazy sequence.", kind = "function"}, action["clojure->vim-completion"]({candidate = "map", type = "function", ns = "clojure.core", doc = "Returns a lazy sequence.", arglists = {"([f coll])", "([f c1 c2])"}}))
    end
    return it("builds the menu and info from the other fields", _11_)
  end
  return describe("clojure->vim-completion", _8_)
end
return describe("client.clojure.nrepl.action", _2_)
