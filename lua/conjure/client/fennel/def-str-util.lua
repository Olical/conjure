-- [nfnl] Compiled from fnl/conjure/client/fennel/def-str-util.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("conjure.nfnl.core")
local conjure_ts = autoload("conjure.tree-sitter")
local ts_utils = autoload("nvim-treesitter.ts_utils")
local vim_ts = autoload("vim.treesitter")
local def_query = vim_ts.query.parse("fennel", "\n(local_form\n (binding_pair\n   lhs: (symbol_binding) @local.def)) \n(fn_form\n  name: [(symbol) (multi_symbol)] @fn.def)")
local function prt(t)
  for k, v in pairs(t) do
    if (type(v) ~= "table") then
      print(k, v)
    else
      print(k)
      prt(v)
    end
  end
  return nil
end
local function get_current_root()
  local bufnr = 0
  local parser = vim_ts.get_parser(bufnr)
  local tree = parser:parse()[1]
  return tree:root()
end
local function search_targets(query, root_node, bufnr, last)
  local bufnr0 = (bufnr or 0)
  local last0 = (last or ( - 1))
  local tbl_21_auto = {}
  local i_22_auto = 0
  for id, node in query:iter_captures(root_node, bufnr0, 0, last0) do
    local val_23_auto = conjure_ts["node->table"](node)
    if (nil ~= val_23_auto) then
      i_22_auto = (i_22_auto + 1)
      tbl_21_auto[i_22_auto] = val_23_auto
    else
    end
  end
  return tbl_21_auto
end
--[[ (search-targets def-query (get-current-root) 0 20) ]]
local function search_and_jump(code_text, last_row)
  local curr_targets = search_targets(def_query, get_current_root(), 0, last_row)
  local results
  local function _4_(node_t)
    return (code_text == node_t.content)
  end
  results = core.filter(_4_, curr_targets)
  if (#results > 0) then
    do
      local node = core.last(results)
      local range = node.range
      vim.api.nvim_win_set_cursor(0, range.start)
    end
    return results
  else
    return {result = "definition not found"}
  end
end
--[[ (search-and-jump "search-and-jump" 39) (search-and-jump "search-and-jump" 49) ]]
return {["search-and-jump"] = search_and_jump, ["search-targets"] = search_targets, ["def-query"] = def_query, ["get-current-root"] = get_current_root}
