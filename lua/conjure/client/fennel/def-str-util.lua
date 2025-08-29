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
local function rest_str(s)
  return string.sub(s, 2, -1)
end
local function resolve_lua_module_path(modname)
  return package.searchpath(("lua." .. modname), package.path)
end
local function resolve_fnl_module_path(modname)
  return package.searchpath(modname, fennel.path)
end
local function imported_modules(resolve, last_row)
  local root = get_current_root()
  local raw_mods
  do
    local tbl_21_auto = {}
    local i_22_auto = 0
    for _, node_t in ipairs(search_targets(path_query, root, 0, last_row)) do
      local val_23_auto = rest_str(node_t.content)
      if (nil ~= val_23_auto) then
        i_22_auto = (i_22_auto + 1)
        tbl_21_auto[i_22_auto] = val_23_auto
      else
      end
    end
    raw_mods = tbl_21_auto
  end
  local tbl_21_auto = {}
  local i_22_auto = 0
  for _, m in ipairs(raw_mods) do
    local val_23_auto = resolve(m)
    if (nil ~= val_23_auto) then
      i_22_auto = (i_22_auto + 1)
      tbl_21_auto[i_22_auto] = val_23_auto
    else
    end
  end
  return tbl_21_auto
end
--[[ (icollect [id node_t (ipairs (search-targets path-query (get-current-root) 0 30))] (rest-str node_t.content)) (imported-modules resolve-fnl-module-path -1) ]]
local function search_in_file(code_text, file_path)
  local buf = vim.fn.bufadd(file_path)
  vim.fn.bufload(buf)
  local cross_results = search_in_buffer(code_text, -1, buf)
  if (#cross_results > 0) then
    vim.api.nvim_set_current_buf(buf)
    jump_to_range(core.last(cross_results).range)
    return core.last(cross_results)
  else
    return nil
  end
end
--[[ (local f "/Users/laurencechen/.local/share/nvim/plugged/nfnl/fnl/nfnl/notify.fnl") (search-in-file "debug" f) ]]
local function search_and_jump(code_text, last_row)
  local results = search_in_buffer(code_text, last_row, 0)
  local fnl_imports = imported_modules(resolve_fnl_module_path, last_row)
  if (#results > 0) then
    do
      local node = core.last(results)
      jump_to_range(node.range)
    end
    return results
  elseif (#fnl_imports > 0) then
    for _, file_path in ipairs(fnl_imports) do
      local r = search_in_file(code_text, file_path)
      if r then
        return r
      else
      end
    end
    return {result = "definition not found"}
  else
    return nil
  end
end
--[[ (search-and-jump "search-and-jump" 39) (search-and-jump "search-and-jump" 49) ]]
return {["search-and-jump"] = search_and_jump, ["search-targets"] = search_targets, ["def-query"] = def_query, ["get-current-root"] = get_current_root}
