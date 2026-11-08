-- [nfnl] fnl/conjure-spec/tree-sitter_spec.fnl
local _local_1_ = require("plenary.busted")
local describe = _local_1_.describe
local it = _local_1_.it
local before_each = _local_1_.before_each
local after_each = _local_1_.after_each
local _local_2_ = require("conjure.nfnl.module")
local autoload = _local_2_.autoload
local ts = require("conjure.tree-sitter")
local config = autoload("conjure.config")
local saved_get_string_parser = nil
local saved_get_parser = nil
local function _3_()
  local function _4_()
    local function _5_()
      saved_get_string_parser = vim.treesitter.get_string_parser
      saved_get_parser = vim.treesitter.get_parser
      config["assoc-in"]({"extract", "tree_sitter", "enabled"}, true)
      local function _6_()
        return {}
      end
      vim.treesitter["get_parser"] = _6_
      return nil
    end
    before_each(_5_)
    local function _7_()
      vim.treesitter["get_string_parser"] = saved_get_string_parser
      vim.treesitter["get_parser"] = saved_get_parser
      return config["assoc-in"]({"extract", "tree_sitter", "enabled"}, true)
    end
    after_each(_7_)
    local function _8_()
      local mock_root_node
      local function _9_()
        return true
      end
      mock_root_node = {has_error = _9_}
      local mock_root_tree
      local function _10_()
        return mock_root_node
      end
      mock_root_tree = {root = _10_}
      local function _11_()
        local function _12_()
        end
        local function _13_()
          return {mock_root_tree}
        end
        return {parse = _12_, trees = _13_}
      end
      vim.treesitter["get_string_parser"] = _11_
      return assert.is_false(ts["valid-str?"]("some-lang", "(some bad code"))
    end
    it("returns false when root node has error", _8_)
    local function _14_()
      local function _15_()
        local function _16_()
        end
        local function _17_()
          return nil
        end
        return {parse = _16_, trees = _17_}
      end
      vim.treesitter["get_string_parser"] = _15_
      return assert.is_falsy(ts["valid-str?"]("some-lang", "code"))
    end
    it("returns falsy when nil parse trees is returned", _14_)
    local function _18_()
      local function _19_()
        local function _20_()
        end
        local function _21_()
          return {}
        end
        return {parse = _20_, trees = _21_}
      end
      vim.treesitter["get_string_parser"] = _19_
      return assert.is_falsy(ts["valid-str?"]("some-lang", "code"))
    end
    it("returns falsy when empty parse trees array is returned", _18_)
    local function _22_()
      local mock_root_tree
      local function _23_()
        return nil
      end
      mock_root_tree = {root = _23_}
      local function _24_()
        local function _25_()
        end
        local function _26_()
          return {mock_root_tree}
        end
        return {parse = _25_, trees = _26_}
      end
      vim.treesitter["get_string_parser"] = _24_
      return assert.is_falsy(ts["valid-str?"]("some-lang", "code"))
    end
    it("returns falsy when returned root node nil", _22_)
    local function _27_()
      local mock_root_node
      local function _28_()
        return false
      end
      mock_root_node = {has_error = _28_}
      local mock_root_tree
      local function _29_()
        return mock_root_node
      end
      mock_root_tree = {root = _29_}
      local function _30_()
        local function _31_()
        end
        local function _32_()
          return {mock_root_tree}
        end
        return {parse = _31_, trees = _32_}
      end
      vim.treesitter["get_string_parser"] = _30_
      return assert.is_true(ts["valid-str?"]("some-lang", "(some code)"))
    end
    it("returns true when root node does not have errors", _27_)
    local function _33_()
      config["assoc-in"]({"extract", "tree_sitter", "enabled"}, false)
      return assert.is_true(ts["valid-str?"]("some-lang", "(some bad code"))
    end
    it("returns true when treesitter is disabled in config", _33_)
    local function _34_()
      vim.treesitter["get_parser"] = nil
      return assert.is_true(ts["valid-str?"]("some-lang", "(some bad code"))
    end
    return it("returns true when treesitter is not present", _34_)
  end
  describe("valid-str?", _4_)
  local function _35_()
    local function _36_()
      local saved_get_node = vim.treesitter.get_node
      local document
      local function _37_()
        return nil
      end
      local function _38_(_, ...)
        return {...}
      end
      document = {parent = _37_, named_descendant_for_range = _38_}
      local function _39_()
        return document
      end
      vim.treesitter["get_node"] = _39_
      vim.api.nvim_win_set_cursor(0, {1, 0})
      local range = ts["get-node-at-cursor"]()
      vim.treesitter["get_node"] = saved_get_node
      return assert.same({0, 0, 0, 1}, range)
    end
    return it("looks one column wider when get_node returns the whole document", _36_)
  end
  return describe("get-node-at-cursor", _35_)
end
return describe("conjure.tree-sitter", _3_)
