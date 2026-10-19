-- [nfnl] fnl/conjure-spec/client/clojure/nrepl/action_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local assert = require("luassert.assert")
local stub = require("luassert.stub")
local config = require("conjure.config")
local original_get_in_fn = config["get-in-fn"]
local get_in_fn_stub = stub(config, "get-in-fn")
get_in_fn_stub.invokes(original_get_in_fn)
local action_cfg = get_in_fn_stub.on_call_with({"client", "clojure", "nrepl"})
local test_current_form_names = {"test-symbol-x", "test-symbol-y"}
local test_runner = "some-custom-runner"
local function _2_(args)
  if ((_G.type(args) == "table") and (args[1] == "test") and (args[2] == "current_form_names")) then
    return test_current_form_names
  elseif ((_G.type(args) == "table") and (args[1] == "test") and (args[2] == "runner")) then
    return test_runner
  else
    local _ = args
    return original_get_in_fn(args)
  end
end
action_cfg.returns(_2_)
local action = require("conjure.client.clojure.nrepl.action")
local function _4_()
  local function _5_()
    local function _6_()
      return assert.are.equals(nil, action["extract-test-name-from-form"](""))
    end
    it("deftest form with missing name", _6_)
    local function _7_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(test-symbol-x foo (+ 10 20))"))
    end
    it("normal deftest form", _7_)
    local function _8_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(test-symbol-y foo (+ 10 20))"))
    end
    it("normal deftest form - using another symbol", _8_)
    local function _9_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(   test-symbol-x  foo  (+ 10 20))"))
    end
    it("deftest form with extra spaces", _9_)
    local function _10_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(test-symbol-x ^:kaocha/skip foo :xyz)"))
    end
    return it("deftest form with metadata", _10_)
  end
  describe("extract-test-name-from-form", _5_)
  local function _11_()
    action["test-runners"] = {["some-custom-runner"] = {["current-form-names"] = {"test-symbol-a", "test-symbol-b"}}}
    local function _12_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(test-symbol-a foo (+ 10 20))"))
    end
    it("uses test-runner-specific deftest form", _12_)
    local function _13_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(test-symbol-b foo (+ 10 20))"))
    end
    it("also uses test-runner-specific deftest form with multiple symbols", _13_)
    local function _14_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(test-symbol-x foo (+ 10 20))"))
    end
    it("also uses test form from conjure config", _14_)
    local function _15_()
      return assert.are.equals("foo", action["extract-test-name-from-form"]("(test-symbol-y foo (+ 10 20))"))
    end
    return it("also uses other deftest form from conjure config", _15_)
  end
  describe("extract-test-runner-specific-name-from-form", _11_)
  local function _16_()
    local function _17_()
      for _, t in ipairs({"function", "macro", "special-form", "var", "local", "namespace", "class", "keyword", "resource", "method", "static-method", "field", "static-field", "data-reader"}) do
        assert.are.equals(t, action["clojure->vim-completion"]({candidate = "x", type = t}).kind)
      end
      return nil
    end
    it("uses the full nREPL type as the kind", _17_)
    local function _18_()
      assert.is_nil(action["clojure->vim-completion"]({candidate = "x"}).kind)
      return assert.is_nil(action["clojure->vim-completion"]({candidate = "x", type = ""}).kind)
    end
    it("has no kind when the type is missing or empty", _18_)
    local function _19_()
      return assert.same({word = "map", menu = "clojure.core ([f coll]) ([f c1 c2])", info = "Returns a lazy sequence.", kind = "function"}, action["clojure->vim-completion"]({candidate = "map", type = "function", ns = "clojure.core", doc = "Returns a lazy sequence.", arglists = {"([f coll])", "([f c1 c2])"}}))
    end
    return it("builds the menu and info from the other fields", _19_)
  end
  return describe("clojure->vim-completion", _16_)
end
return describe("client.clojure.nrepl.action", _4_)
