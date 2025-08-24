-- [nfnl] fnl/conjure-spec/client/scheme/stdio_spec.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local _local_2_ = require("plenary.busted")
local describe = _local_2_["describe"]
local it = _local_2_["it"]
local assert = autoload("luassert.assert")
local a = autoload("conjure.nfnl.core")
local scheme = require("conjure.client.scheme.stdio")
local config = autoload("conjure.config")
local mock_stdio = require("conjure-spec.client.scheme.mock-stdio")
local mock_tsc = require("conjure-spec.mock-tree-sitter-completions")
local mock_log = require("conjure-spec.mock-log")
package.loaded["conjure.tree-sitter-completions"] = mock_tsc
package.loaded["conjure.log"] = mock_log
local function _3_()
  package.loaded["conjure.remote.stdio"] = mock_stdio
  local function _4_()
    local expected_code = "(some code)"
    local send_calls = {}
    local mock_send
    local function _5_(val)
      return table.insert(send_calls, val)
    end
    mock_send = _5_
    local function _6_(_)
      return true
    end
    scheme["valid-str?"] = _6_
    mock_stdio["set-mock-send"](mock_send)
    scheme.start()
    scheme["eval-str"]({code = expected_code})
    scheme.stop()
    return assert.same({(expected_code .. "\n")}, send_calls)
  end
  it("eval-str sends code to repl when parses", _4_)
  local function _7_()
    local send_calls = {}
    local mock_send
    local function _8_(val)
      return table.insert(send_calls, val)
    end
    mock_send = _8_
    local function _9_(_)
      return false
    end
    scheme["valid-str?"] = _9_
    mock_stdio["set-mock-send"](mock_send)
    scheme.start()
    scheme["eval-str"]({code = "(some invalid form"})
    scheme.stop()
    return assert.same({}, send_calls)
  end
  return it("eval-str does not send code to repl when valid-str? returns false", _7_)
end
local function _10_()
  local function _11_()
    local completion_results = {}
    local completion_callback
    local function _12_(res)
      return table.insert(completion_results, res)
    end
    completion_callback = _12_
    mock_tsc["set-mock-completions"]({})
    scheme.completions({prefix = "dela", cb = completion_callback})
    return assert.same({"delay"}, completion_results[1])
  end
  it("returns delay for prefix dela when no treesitter completions", _11_)
  local function _13_()
    local completion_results = {}
    local completion_callback
    local function _14_(res)
      return table.insert(completion_results, res)
    end
    completion_callback = _14_
    mock_tsc["set-mock-completions"]({"delta", "other"})
    scheme.completions({prefix = "delt", cb = completion_callback})
    return assert.same({"delta"}, completion_results[1])
  end
  it("returns delta for prefix delt when treesitter completion delta and other", _13_)
  local function _15_()
    local completion_results = {}
    local completion_callback
    local function _16_(res)
      return table.insert(completion_results, res)
    end
    completion_callback = _16_
    mock_tsc["set-mock-completions"]({"delay-more"})
    scheme.completions({prefix = "dela", cb = completion_callback})
    return assert.same({"delay-more", "delay"}, completion_results[1])
  end
  it("returns delay-more and delay for prefix dela when treesitter completion delay-more", _15_)
  local function _17_()
    local completion_results = {}
    local completion_callback
    local function _18_(res)
      return table.insert(completion_results, res)
    end
    completion_callback = _18_
    mock_tsc["set-mock-completions"]({"delta"})
    scheme.completions({prefix = nil, cb = completion_callback})
    return assert.same("delta", a["get-in"](completion_results, {1, 1}))
  end
  return it("returns delta as first result for prefix nil when treesitter completion delta", _17_)
end
local function _19_()
  local function _20_()
    config.merge({client = {scheme = {stdio = {enable_completions = false}}}}, {["overwrite?"] = true})
    local completion_results = {}
    local completion_callback
    local function _21_(res)
      return table.insert(completion_results, res)
    end
    completion_callback = _21_
    mock_tsc["set-mock-completions"]({"delay"})
    scheme.completions({prefix = "dela", cb = completion_callback})
    return assert.same({}, completion_results[1])
  end
  it("returns empty list for completions when completions disabled", _20_)
  local function _22_()
    config.merge({client = {scheme = {stdio = {enable_completions = true}}}}, {["overwrite?"] = true})
    local completion_results = {}
    local completion_callback
    local function _23_(res)
      return table.insert(completion_results, res)
    end
    completion_callback = _23_
    mock_tsc["set-mock-completions"]({"delay-more"})
    scheme.completions({prefix = "dela", cb = completion_callback})
    return assert.same({"delay-more", "delay"}, completion_results[1])
  end
  return it("returns delay delay-more for completions when completions enabled and tree sitter completion delay-more", _22_)
end
return describe("conjure.client.scheme.stdio", _3_, describe("completions", _10_), describe("config", _19_))
