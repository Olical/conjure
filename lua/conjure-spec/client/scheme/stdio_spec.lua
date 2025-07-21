-- [nfnl] fnl/conjure-spec/client/scheme/stdio_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_["describe"]
local it = _local_1_["it"]
local assert = require("luassert.assert")
local scheme = require("conjure.client.scheme.stdio")
local mock_stdio = require("conjure-spec.client.scheme.mock-stdio")
local function _2_()
  package.loaded["conjure.remote.stdio"] = mock_stdio
  local function _3_()
    local expected_code = "(some code)"
    local send_calls = {}
    local mock_send
    local function _4_(val)
      return table.insert(send_calls, val)
    end
    mock_send = _4_
    local function _5_(_)
      return true
    end
    scheme["valid-str?"] = _5_
    mock_stdio["set-mock-send"](mock_send)
    scheme.start()
    scheme["eval-str"]({code = expected_code})
    scheme.stop()
    return assert.same({(expected_code .. "\n")}, send_calls)
  end
  it("eval-str sends code to repl when parses", _3_)
  local function _6_()
    local send_calls = {}
    local mock_send
    local function _7_(val)
      return table.insert(send_calls, val)
    end
    mock_send = _7_
    local function _8_(_)
      return false
    end
    scheme["valid-str?"] = _8_
    mock_stdio["set-mock-send"](mock_send)
    scheme.start()
    scheme["eval-str"]({code = "(some invalid form"})
    scheme.stop()
    return assert.same({}, send_calls)
  end
  return it("eval-str does not send code to repl when valid-str? returns false", _6_)
end
return describe("conjure.client.scheme.stdio", _2_)
