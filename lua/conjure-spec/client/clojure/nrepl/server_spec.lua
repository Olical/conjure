-- [nfnl] fnl/conjure-spec/client/clojure/nrepl/server_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local assert = require("luassert.assert")
local server = require("conjure.client.clojure.nrepl.server")
local state = require("conjure.client.clojure.nrepl.state")
local core = require("nfnl.core")
local function make_conn(opts)
  local function _2_()
  end
  local function _3_()
  end
  return core.merge({["pending-evals"] = {}, ["setup-timeout"] = nil, host = "localhost", port = 12345, session = "test-session", describe = {}, ["seen-ns"] = {}, send = _2_, destroy = _3_, ["ready?"] = false}, opts)
end
local function set_conn_21(conn)
  return core.assoc(state.get(), "conn", conn)
end
local function clear_conn_21()
  return core.assoc(state.get(), "conn", nil)
end
local function _4_()
  local function _5_()
    local function _6_()
      set_conn_21(make_conn())
      local called_3f = false
      local function _7_(_conn)
        called_3f = true
        return nil
      end
      server["with-conn-or-warn"](_7_)
      assert.is_true(called_3f)
      return clear_conn_21()
    end
    it("calls f when conn exists", _6_)
    local function _8_()
      clear_conn_21()
      local called_3f = false
      local function _9_(_conn)
        called_3f = true
        return nil
      end
      server["with-conn-or-warn"](_9_, {["silent?"] = true})
      return assert.is_false(called_3f)
    end
    return it("does not call f when no conn", _8_)
  end
  describe("with-conn-or-warn", _5_)
  local function _10_()
    local function _11_()
      set_conn_21(make_conn({["ready?"] = true}))
      local called_3f = false
      local function _12_(_conn)
        called_3f = true
        return nil
      end
      server["with-conn-ready-or-queue"](_12_)
      assert.is_true(called_3f)
      return clear_conn_21()
    end
    it("calls f immediately when conn is ready", _11_)
    local function _13_()
      local conn = make_conn({["ready?"] = false})
      set_conn_21(conn)
      local called_3f = false
      local function _14_(_conn)
        called_3f = true
        return nil
      end
      server["with-conn-ready-or-queue"](_14_)
      assert.is_false(called_3f)
      assert.are.equals(1, #conn["pending-evals"])
      return clear_conn_21()
    end
    it("queues f when conn is not ready", _13_)
    local function _15_()
      clear_conn_21()
      local called_3f = false
      local function _16_(_conn)
        called_3f = true
        return nil
      end
      server["with-conn-ready-or-queue"](_16_, {["silent?"] = true})
      return assert.is_false(called_3f)
    end
    return it("does not call f or queue when no conn", _15_)
  end
  describe("with-conn-ready-or-queue", _10_)
  local function _17_()
    local function _18_()
      local conn = make_conn({["ready?"] = false})
      local results = {}
      set_conn_21(conn)
      local function _19_(_conn)
        return table.insert(results, "first")
      end
      table.insert(conn["pending-evals"], _19_)
      local function _20_(_conn)
        return table.insert(results, "second")
      end
      table.insert(conn["pending-evals"], _20_)
      local function _21_(_conn)
        return table.insert(results, "third")
      end
      table.insert(conn["pending-evals"], _21_)
      server["mark-ready!"]()
      assert.is_true(conn["ready?"])
      assert.same({"first", "second", "third"}, results)
      assert.are.equals(0, #conn["pending-evals"])
      return clear_conn_21()
    end
    it("sets ready? and drains pending evals in order", _18_)
    local function _22_()
      local conn = make_conn({["ready?"] = false})
      local call_count = {n = 0}
      set_conn_21(conn)
      local function _23_(_conn)
        call_count.n = (call_count.n + 1)
        return nil
      end
      table.insert(conn["pending-evals"], _23_)
      server["mark-ready!"]()
      assert.are.equals(1, call_count.n)
      local function _24_(_conn)
        call_count.n = (call_count.n + 1)
        return nil
      end
      table.insert(conn["pending-evals"], _24_)
      server["mark-ready!"]()
      assert.are.equals(1, call_count.n)
      return clear_conn_21()
    end
    it("is idempotent \226\128\148 second call is a no-op", _22_)
    local function _25_()
      clear_conn_21()
      return server["mark-ready!"]()
    end
    return it("no-ops when no conn exists", _25_)
  end
  describe("mark-ready!", _17_)
  local function _26_()
    local function _27_()
      set_conn_21(make_conn())
      assert.is_true(server["connected?"]())
      return clear_conn_21()
    end
    it("returns true when conn exists", _27_)
    local function _28_()
      clear_conn_21()
      return assert.is_false(server["connected?"]())
    end
    return it("returns false when no conn", _28_)
  end
  describe("connected?", _26_)
  local function _29_()
    local function _30_()
      return assert.are.equals("(+ 1 2)", server["un-comment"]("#_(+ 1 2)"))
    end
    it("strips leading #_ from code", _30_)
    local function _31_()
      return assert.are.equals("(+ 1 2)", server["un-comment"]("(+ 1 2)"))
    end
    it("leaves code without #_ unchanged", _31_)
    local function _32_()
      return assert.are.equals(nil, server["un-comment"](nil))
    end
    return it("returns nil for nil input", _32_)
  end
  return describe("un-comment", _29_)
end
return describe("client.clojure.nrepl.server", _4_)
