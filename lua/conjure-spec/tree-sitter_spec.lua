-- [nfnl] fnl/conjure-spec/tree-sitter_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local before_each = _local_1_.before_each
local after_each = _local_1_.after_each
local ts = require("conjure.tree-sitter")
local saved_get_string_parser = nil
local function _2_()
  local function _3_()
    local function _4_()
      saved_get_string_parser = vim.treesitter.get_string_parser
      return nil
    end
    before_each(_4_)
    local function _5_()
      vim.treesitter["get_string_parser"] = saved_get_string_parser
      return nil
    end
    after_each(_5_)
    local function _6_()
      local mock_root_node
      local function _7_()
        return true
      end
      mock_root_node = {has_error = _7_}
      local mock_root_tree
      local function _8_()
        return mock_root_node
      end
      mock_root_tree = {root = _8_}
      local function _9_()
        local function _10_()
        end
        local function _11_()
          return {mock_root_tree}
        end
        return {parse = _10_, trees = _11_}
      end
      vim.treesitter["get_string_parser"] = _9_
      return assert.is_false(ts["valid-str?"]("some-lang", "(some bad code"))
    end
    it("returns false when root node has error", _6_)
    local function _12_()
      local function _13_()
        local function _14_()
        end
        local function _15_()
          return nil
        end
        return {parse = _14_, trees = _15_}
      end
      vim.treesitter["get_string_parser"] = _13_
      return assert.is_falsy(ts["valid-str?"]("some-lang", "code"))
    end
    it("returns falsy when nil parse trees is returned", _12_)
    local function _16_()
      local function _17_()
        local function _18_()
        end
        local function _19_()
          return {}
        end
        return {parse = _18_, trees = _19_}
      end
      vim.treesitter["get_string_parser"] = _17_
      return assert.is_falsy(ts["valid-str?"]("some-lang", "code"))
    end
    it("returns falsy when empty parse trees array is returned", _16_)
    local function _20_()
      local mock_root_tree
      local function _21_()
        return nil
      end
      mock_root_tree = {root = _21_}
      local function _22_()
        local function _23_()
        end
        local function _24_()
          return {mock_root_tree}
        end
        return {parse = _23_, trees = _24_}
      end
      vim.treesitter["get_string_parser"] = _22_
      return assert.is_falsy(ts["valid-str?"]("some-lang", "code"))
    end
    it("returns falsy when returned root node nil", _20_)
    local function _25_()
      local mock_root_node
      local function _26_()
        return false
      end
      mock_root_node = {has_error = _26_}
      local mock_root_tree
      local function _27_()
        return mock_root_node
      end
      mock_root_tree = {root = _27_}
      local function _28_()
        local function _29_()
        end
        local function _30_()
          return {mock_root_tree}
        end
        return {parse = _29_, trees = _30_}
      end
      vim.treesitter["get_string_parser"] = _28_
      return assert.is_true(ts["valid-str?"]("some-lang", "(some code)"))
    end
    return it("returns true when root node does not have errors", _25_)
  end
  return describe("valid-str?", _3_)
end
return describe("conjure.tree-sitter", _2_)
