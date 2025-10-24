-- [nfnl] fnl/conjure-spec/mock-tree-sitter-completions.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local tsc = autoload("conjure.tree-sitter-completions")
local mock_completions = {}
local function set_mock_completions(r)
  mock_completions = r
  return nil
end
local function get_completions_at_cursor(_, _0)
  return mock_completions
end
return {["set-mock-completions"] = set_mock_completions, ["get-completions-at-cursor"] = get_completions_at_cursor, ["make-prefix-filter"] = tsc["make-prefix-filter"]}
