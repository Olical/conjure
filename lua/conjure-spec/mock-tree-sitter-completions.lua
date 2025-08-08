-- [nfnl] fnl/conjure-spec/mock-tree-sitter-completions.fnl
local mock_completions = {}
local function set_mock_completions(r)
  mock_completions = r
  return nil
end
local function get_completions_at_cursor(_, _0)
  return mock_completions
end
return {["get-completions-at-cursor"] = get_completions_at_cursor, ["set-mock-completions"] = set_mock_completions}
