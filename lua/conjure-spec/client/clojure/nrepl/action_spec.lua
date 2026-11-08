-- [nfnl] fnl/conjure-spec/client/clojure/nrepl/action_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local assert = require("luassert.assert")
local action = require("conjure.client.clojure.nrepl.action")
local state = require("conjure.client.clojure.nrepl.state")
local core = require("conjure.nfnl.core")
local log = require("conjure.log")
require("conjure.client.clojure.nrepl")
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
  describe("clojure->vim-completion", _8_)
  local function _12_()
    local current_session = "c0ffee00-0000-4000-8000-000000000001"
    local eval_session = "e7a10000-0000-4000-8000-000000000002"
    local other_session = "07e40000-0000-4000-8000-000000000003"
    local function pending_msg(id, op, session, sent_at, code)
      return {msg = {id = id, op = op, session = session, code = code}, ["sent-at"] = sent_at}
    end
    local function interrupt_with_pending_msgs(pending_msgs)
      local sent = {}
      local logged = {}
      local original_append = log.append
      local conn
      local function _13_(msg, cb)
        table.insert(sent, msg)
        if ("eval" == msg.op) then
          return cb({value = "clj", status = {done = true}})
        else
          return nil
        end
      end
      conn = {["ready?"] = true, session = current_session, state = {msgs = pending_msgs}, send = _13_}
      local function _15_(lines)
        for _, line in ipairs(lines) do
          table.insert(logged, line)
        end
        return nil
      end
      log.append = _15_
      core.assoc(state.get(), "conn", conn)
      action.interrupt()
      core.assoc(state.get(), "conn", nil)
      log.append = original_append
      local function _16_(_241)
        return core["select-keys"](_241, {"op", "interrupt-id", "session"})
      end
      local function _17_(_241)
        return ("interrupt" == _241.op)
      end
      return {interrupts = core.map(_16_, core.filter(_17_, sent)), logged = logged}
    end
    local function _18_()
      local _let_19_ = interrupt_with_pending_msgs({["eval-new"] = pending_msg("eval-new", "eval", other_session, 200, "(new)"), ["eval-old"] = pending_msg("eval-old", "eval", eval_session, 100, "(Thread/sleep 20000)"), describe = pending_msg("describe", "describe", current_session, 50)})
      local interrupts = _let_19_.interrupts
      local logged = _let_19_.logged
      assert.same({{op = "interrupt", ["interrupt-id"] = "eval-old", session = eval_session}}, interrupts)
      return assert.same({"; Interrupted: (Thread/sleep 20000)"}, logged)
    end
    it("targets the oldest pending eval with its id and session", _18_)
    local function _20_()
      local _let_21_ = interrupt_with_pending_msgs({})
      local interrupts = _let_21_.interrupts
      local logged = _let_21_.logged
      assert.same({{op = "interrupt", session = current_session}}, interrupts)
      return assert.is_truthy(string.find(core.first(logged), "^; Interrupted: session: "))
    end
    return it("interrupts the current session without an interrupt-id when no eval is pending", _20_)
  end
  return describe("interrupt", _12_)
end
return describe("client.clojure.nrepl.action", _2_)
