-- [nfnl] Compiled from fnl/conjure/client/fennel/def-str-util.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("conjure.nfnl.core")
local conjure_ts = autoload("conjure.tree-sitter")
local ts_utils = autoload("nvim-treesitter.ts_utils")
local vim_ts = autoload("vim.treesitter")
local fennel = autoload("nfnl.fennel")
local notify = autoload("nfnl.notify")
--[[ (fennel.view {:a 15 :b 16}) (notify.info "hello") ]]
local def_query = vim_ts.query.parse("fennel", "\n(local_form\n (binding_pair\n   lhs: (symbol_binding) @local.def)) \n(fn_form\n  name: [(symbol) (multi_symbol)] @fn.def)")
local path_query = vim_ts.query.parse("fennel", "\n(local_form\n  (binding_pair\n    rhs: (list\n           call: (symbol) (#any-of? \"autoload\" \"require\")\n           item: (string) @import.path)))")
local function get_current_root()
  local bufnr = 0
  local parser = vim_ts.get_parser(bufnr)
  local tree = parser:parse()[1]
  return tree:root()
end
local function search_targets(query, root_node, bufnr, last)
  local bufnr0 = (bufnr or 0)
  local last0 = (last or ( - 1))
  local tbl_21_ = {}
  local i_22_ = 0
  for id, node in query:iter_captures(root_node, bufnr0, 0, last0) do
    local val_23_ = conjure_ts["node->table"](node)
    if (nil ~= val_23_) then
      i_22_ = (i_22_ + 1)
      tbl_21_[i_22_] = val_23_
    else
    end
  end
  return tbl_21_
end
--[[ (search-targets def-query (get-current-root) 0 20) ]]
local function search_in_buffer(code_text, last_row, bufnr)
  local curr_targets = search_targets(def_query, get_current_root(), bufnr, last_row)
  local results
  local function _3_(node_t)
    return (code_text == node_t.content)
  end
  results = core.filter(_3_, curr_targets)
  return results
end
local function jump_to_range(range)
  return vim.api.nvim_win_set_cursor(0, range.start)
end
local function search_and_jump(code_text, last_row)
  local results = search_in_buffer(code_text, last_row, 0)
  if (#results > 0) then
    do
      local node = core.last(results)
      jump_to_range(node.range)
    end
    return results
  else
    return {result = "definition not found"}
  end
end
--[[ (search-and-jump "search-and-jump" 39) (search-and-jump "search-and-jump" 49) ]]
local function rest_str(s)
  return string.sub(s, 2, -1)
end
--[[ (icollect [id node_t (ipairs (search-targets path-query (get-current-root) 0 30))] (rest-str node_t.content)) ]]
local function resolve_module_path(modname)
  return package.searchpath(modname, package.path)
end
local function imported_modules()
  local root = get_current_root()
  local raw_mods
  do
    local tbl_21_ = {}
    local i_22_ = 0
    for _, node_t in ipairs(search_targets(path_query, root, 0, 200)) do
      local val_23_ = rest_str(node_t.content)
      if (nil ~= val_23_) then
        i_22_ = (i_22_ + 1)
        tbl_21_[i_22_] = val_23_
      else
      end
    end
    raw_mods = tbl_21_
  end
  local tbl_21_ = {}
  local i_22_ = 0
  for _, m in ipairs(raw_mods) do
    local val_23_ = resolve_module_path(m)
    if (nil ~= val_23_) then
      i_22_ = (i_22_ + 1)
      tbl_21_[i_22_] = val_23_
    else
    end
  end
  return tbl_21_
end
imported_modules()
return {["search-and-jump"] = search_and_jump, ["search-targets"] = search_targets, ["def-query"] = def_query, ["get-current-root"] = get_current_root}
