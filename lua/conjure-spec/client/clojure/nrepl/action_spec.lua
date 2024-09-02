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
describe("client.clojure.nrepl.action", _2_)
--[[ (local parse (require "conjure.client.clojure.nrepl.parse")) (local str (require "conjure.aniseed.string")) (local a (require "conjure.aniseed.core")) (local text (require "conjure.text")) (local config (require "conjure.config")) (parse.strip-meta "(deftest foo (+ 10 20))") (str.split (parse.strip-meta "(deftest foo (+ 10 20))") "%s+") (r (str.split (parse.strip-meta "(deftest foo (+ 10 20))") "%s+")) (parse.strip-meta "(   deftest  foo  (+ 10 20))") (str.split (parse.strip-meta "(   deftest  foo  (+ 10 20))") "%s+") (r (str.split (parse.strip-meta "(   deftest  foo  (+ 10 20))") "%s+")) (parse.strip-meta "(deftest ^:kaocha/skip foo :xyz)") (str.split (parse.strip-meta "(deftest ^:kaocha/skip foo :xyz)") "%s+") (r (str.split (parse.strip-meta "(deftest ^:kaocha/skip foo :xyz)") "%s+")) (local cfg (config.get-in-fn ["client" "clojure" "nrepl"])) (cfg ["connection" "port_number"]) (cfg ["test" "current_form_names"]) (cfg ["test" "runner"]) (cfg ["test" "raw_out"]) (. vim.g "conjure#client#clojure#nrepl#test#current_form_names") (cfg ["test" "current_form_names"]) (set vim.g.conjure#client#clojure#nrepl#test#current_form_names ["deftest"]) (fn r [words] (var seen-deftest? false) (a.some (fn [part] (if (a.some (fn [config-current-form-name] (text.ends-with part config-current-form-name)) (cfg ["test" "current_form_names"])) (do (set seen-deftest? true) false) seen-deftest? part)) words)) ]]
return nil
