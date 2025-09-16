-- [nfnl] Compiled from fnl/conjure/client/fennel/def-str-util.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local core = autoload("conjure.nfnl.core")
local conjure_ts = autoload("conjure.tree-sitter")
local vim_ts = autoload("vim.treesitter")
local config = autoload("conjure.nfnl.config")
local notify = autoload("conjure.nfnl.notify")
local res = autoload("conjure.resources")
local def_local_query = vim_ts.query.parse("fennel", res["get-resource-contents"]("queries/fennel/local-def.scm"))
local def_ext_query = vim_ts.query.parse("fennel", res["get-resource-contents"]("queries/fennel/ext-def.scm"))
local path_query = vim_ts.query.parse("fennel", res["get-resource-contents"]("queries/fennel/import-path.scm"))
local function get_current_root(bufnr, lang)
  local bufnr0 = (bufnr or 0)
  local lang0 = (lang or "fennel")
  local parser = vim_ts.get_parser(bufnr0, lang0)
  local tree = parser:parse()[1]
  return tree:root()
end
local function search_targets(query, root_node, bufnr, last, first)
  local bufnr0 = (bufnr or 0)
  local last0 = (last or ( - 1))
  local first0 = (first or 0)
  local tbl_21_auto = {}
  local i_22_auto = 0
  for id, node in query:iter_captures(root_node, bufnr0, first0, last0) do
    local val_23_auto = conjure_ts["node->table"](node)
    if (nil ~= val_23_auto) then
      i_22_auto = (i_22_auto + 1)
      tbl_21_auto[i_22_auto] = val_23_auto
    else
    end
  end
  return tbl_21_auto
end
--[[ (search-targets def-local-query (get-current-root) 0 20) ]]
local function search_in_buffer(code_text, last_row, bufnr)
  local curr_targets = search_targets(def_local_query, get_current_root(bufnr), bufnr, last_row)
  local results
  local function _3_(node_t)
    return (code_text == node_t.content)
  end
  results = core.filter(_3_, curr_targets)
  return results
end
local function search_ext_targets(query, root_node, bufnr, last)
  local last0 = (last or -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local tbl_21_auto = {}
  local i_22_auto = 0
  for id, node in query:iter_captures(root_node, bufnr, 0, last0) do
    local val_23_auto
    do
      local range = conjure_ts.range(node)
      local start_row = core["get-in"](range, {"start", 1})
      local start_col = core["get-in"](range, {"start", 2})
      local end_row = core["get-in"](range, {"end", 1})
      local end_col = core["get-in"](range, {"end", 2})
      local content = string.sub(core.get(lines, start_row), (1 + start_col), (1 + end_col))
      val_23_auto = {content = content, range = range}
    end
    if (nil ~= val_23_auto) then
      i_22_auto = (i_22_auto + 1)
      tbl_21_auto[i_22_auto] = val_23_auto
    else
    end
  end
  return tbl_21_auto
end
local function search_in_ext_buffer(code_text, last_row, bufnr)
  local curr_targets = search_ext_targets(def_ext_query, get_current_root(bufnr), bufnr, last_row)
  local results
  local function _5_(node_t)
    return (code_text == node_t.content)
  end
  results = core.filter(_5_, curr_targets)
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
  return package.searchpath(modname, config.default()["fennel-path"])
end
local function imported_modules(resolve, last_row, first_row)
  local root = get_current_root()
  local raw_mods
  do
    local tbl_21_auto = {}
    local i_22_auto = 0
    for _, node_t in ipairs(search_targets(path_query, root, 0, last_row, first_row)) do
      local val_23_auto = rest_str(node_t.content)
      if (nil ~= val_23_auto) then
        i_22_auto = (i_22_auto + 1)
        tbl_21_auto[i_22_auto] = val_23_auto
      else
      end
    end
    raw_mods = tbl_21_auto
  end
  notify.debug(("raw-mods: " .. core["pr-str"](raw_mods)))
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
local function search_in_ext_file(code_text, file_path)
  local bufnr = vim.fn.bufadd(file_path)
  vim.fn.bufload(bufnr)
  local cross_results = search_in_ext_buffer(code_text, -1, bufnr)
  if (#cross_results > 0) then
    vim.api.nvim_set_current_buf(bufnr)
    jump_to_range(core.last(cross_results).range)
    core.last(cross_results)
    return true
  else
    vim.api.nvim_buf_delete(bufnr, {})
    return false
  end
end
--[[ (local f "/Users/laurencechen/.local/share/nvim/plugged/nfnl/fnl/nfnl/notify.fnl") (local bufnr (vim.fn.bufadd f)) (vim.fn.bufload bufnr) (search-ext-targets def-local-query (get-current-root bufnr "fennel") bufnr) (search-in-ext-buffer "debug" -1 bufnr) (search-in-ext-file "debug" f) ]]
local function fn_name(s)
  local start_index, _ = string.find(s, "%.")
  if start_index then
    return string.sub(s, (1 + start_index))
  else
    return s
  end
end
local function module_name(s)
  local start_index, _ = string.find(s, "%.")
  if start_index then
    return string.sub(s, 1, (start_index - 1))
  else
    return nil
  end
end
local function reverse(xs)
  local new_list = {}
  local n = #xs
  for i = n, 1, -1 do
    table.insert(new_list, xs[i])
  end
  return new_list
end
local function cross_jump(fn_text, fnl_imports)
  notify.debug(("fnl-path: " .. config.default()["fennel-path"]))
  notify.debug(("search symbol in the following fnl libs: " .. core["pr-str"](fnl_imports)))
  local results = {}
  for _, file_path in ipairs(fnl_imports) do
    notify.debug(("search in file-path: " .. file_path .. " for fn-text " .. fn_text))
    local r = search_in_ext_file(fn_text, file_path)
    notify.debug(("get result " .. tostring(r) .. " from search"))
    table.insert(results, r)
  end
  if not core.some(core.identity, results) then
    return {result = "definition not found"}
  else
    return nil
  end
end
local function search_and_jump(code_text, last_row)
  notify.debug(("code-text: " .. code_text))
  local results = search_in_buffer(code_text, last_row, 0)
  local module_text = module_name(code_text)
  local module_results = search_in_buffer(module_text, last_row, 0)
  local fn_text = fn_name(code_text)
  local fnl_imports = imported_modules(resolve_fnl_module_path, last_row)
  if (#results > 0) then
    do
      local node = core.last(results)
      jump_to_range(node.range)
    end
    return results
  elseif (#module_results > 0) then
    notify.debug("begin direct cross fnl module jump to certain module")
    notify.debug(core.str(module_results))
    local target = core.first(module_results)
    local end_row = core["get-in"](target, {"range", "end", 1})
    local fnl_imports0 = imported_modules(resolve_fnl_module_path, end_row, (end_row - 1))
    return cross_jump(fn_text, fnl_imports0)
  elseif (#fnl_imports > 0) then
    notify.debug("begin cross fnl module jump")
    local r_fnl_imports = reverse(fnl_imports)
    return cross_jump(fn_text, r_fnl_imports)
  else
    return nil
  end
end
--[[ (search-and-jump "search-and-jump" 39) (search-and-jump "search-and-jump" 49) ]]
return {["search-and-jump"] = search_and_jump, ["search-targets"] = search_targets, ["get-current-root"] = get_current_root, ["def-local-query"] = def_local_query, ["def-ext-query"] = def_ext_query, ["path-query"] = path_query, ["imported-modules"] = imported_modules, ["resolve-fnl-module-path"] = resolve_fnl_module_path}
