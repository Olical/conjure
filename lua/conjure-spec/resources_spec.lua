-- [nfnl] fnl/conjure-spec/resources_spec.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local _local_2_ = require("plenary.busted")
local describe = _local_2_["describe"]
local it = _local_2_["it"]
local spy = _local_2_["spy"]
local before_each = _local_2_["before_each"]
local assert = require("luassert.assert")
local default_open
local function _3_()
  return nil
end
default_open = _3_
local default_get_runtime_file
local function _4_()
  return {}
end
default_get_runtime_file = _4_
local res = nil
local function _5_()
  local function _6_()
    package.loaded["conjure.resources"] = nil
    res = require("conjure.resources")
    vim.api["nvim_get_runtime_file"] = default_get_runtime_file
    io["open"] = default_open
    return nil
  end
  before_each(_6_)
  local function _7_()
    local function _8_()
      local open_call_paths = {}
      local mock_file_open
      local function _9_(path, _)
        return table.insert(open_call_paths, path)
      end
      mock_file_open = _9_
      io["open"] = mock_file_open
      assert.are.equal(nil, res["get-resource-contents"]("some-path"))
      return assert.same({}, open_call_paths)
    end
    it("returns nil when no file paths", _8_)
    local function _10_()
      local expected_path = "some-path"
      local open_call_paths = {}
      local mock_file_open
      local function _11_(path, _)
        table.insert(open_call_paths, path)
        return nil
      end
      mock_file_open = _11_
      local function _12_()
        return {expected_path}
      end
      vim.api["nvim_get_runtime_file"] = _12_
      io["open"] = mock_file_open
      assert.are.equal(nil, res["get-resource-contents"](expected_path))
      return assert.same({expected_path}, open_call_paths)
    end
    it("returns nil when file open fails", _10_)
    local function _13_()
      local requested_path = "requested-path"
      local get_runtime_file_paths = {}
      local function _14_(path)
        table.insert(get_runtime_file_paths, path)
        return {"full-path"}
      end
      vim.api["nvim_get_runtime_file"] = _14_
      assert.are.equal(nil, res["get-resource-contents"](requested_path))
      return assert.same({("res/" .. requested_path)}, get_runtime_file_paths)
    end
    it("prefixes res/ path to resource request", _13_)
    local function _15_()
      local expected_content = "Here is file content"
      local mock_file_open
      local function _16_(_, _0)
        local function _17_(_1)
          return expected_content
        end
        local function _18_()
          return nil
        end
        return {read = _17_, close = _18_}
      end
      mock_file_open = _16_
      local function _19_()
        return {"full-file-path"}
      end
      vim.api["nvim_get_runtime_file"] = _19_
      io["open"] = mock_file_open
      return assert.are.equal(expected_content, res["get-resource-contents"]("some-path"))
    end
    it("returns file contents when file open succeeds", _15_)
    local function _20_()
      local close_calls = {}
      local mock_file_open
      local function _21_(_, _0)
        local function _22_(_1)
          return "some content"
        end
        local function _23_()
          table.insert(close_calls, true)
          return nil
        end
        return {read = _22_, close = _23_}
      end
      mock_file_open = _21_
      local function _24_()
        return {"full-file-path"}
      end
      vim.api["nvim_get_runtime_file"] = _24_
      io["open"] = mock_file_open
      res["get-resource-contents"]("some-path")
      return assert.same({true}, close_calls)
    end
    it("closes file after file open", _20_)
    local function _25_()
      local open_call_paths = {}
      local mock_file_open
      local function _26_(path, _)
        table.insert(open_call_paths, path)
        local function _27_(_0)
          return "file content"
        end
        local function _28_()
          return nil
        end
        return {read = _27_, close = _28_}
      end
      mock_file_open = _26_
      local function _29_()
        return {"full-file-path"}
      end
      vim.api["nvim_get_runtime_file"] = _29_
      io["open"] = mock_file_open
      res["get-resource-contents"]("some-path")
      res["get-resource-contents"]("some-path")
      return assert.are.equal(1, #open_call_paths)
    end
    return it("returns cached file contents when read twice", _25_)
  end
  return describe("reading resources", _7_)
end
return describe("conjure.resources", _5_)
