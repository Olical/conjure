-- [nfnl] Compiled from fnl/conjure/config.fnl by https://github.com/Olical/nfnl, do not edit.
local autoload = require("nfnl.autoload")
local nvim = autoload("conjure.aniseed.nvim")
local a = autoload("conjure.aniseed.core")
local str = autoload("conjure.aniseed.string")
local function ks__3evar(ks)
  return ("conjure#" .. str.join("#", ks))
end
local function get_in(ks)
  local key = ks__3evar(ks)
  local v = (a.get(nvim.b, key) or a.get(nvim.g, key))
  if (a["table?"](v) and a.get(v, vim.type_idx) and a.get(v, vim.val_idx)) then
    return a.get(v, vim.val_idx)
  else
    return v
  end
end
local function filetypes()
  return get_in({"filetypes"})
end
local function get_in_fn(prefix_ks)
  local function _2_(ks)
    return get_in(a.concat(prefix_ks, ks))
  end
  return _2_
end
local function assoc_in(ks, v)
  a.assoc(nvim.g, ks__3evar(ks), v)
  return v
end
local function merge(tbl, opts, ks)
  local ks0 = (ks or {})
  local opts0 = (opts or {})
  local function _4_(_3_)
    local k = _3_[1]
    local v = _3_[2]
    local ks1 = a.concat(ks0, {k})
    local current = get_in(ks1)
    if (a["table?"](v) and not a.get(v, 1)) then
      return merge(v, opts0, ks1)
    else
      if (a["nil?"](current) or opts0["overwrite?"]) then
        return assoc_in(ks1, v)
      else
        return nil
      end
    end
  end
  a["run!"](_4_, a["kv-pairs"](tbl))
  return nil
end
merge({relative_file_root = nil, path_subs = nil, client_on_load = true, filetypes = {"clojure", "fennel", "janet", "hy", "julia", "racket", "scheme", "lua", "lisp", "python", "rust", "sql"}, filetype = {clojure = "conjure.client.clojure.nrepl", fennel = "conjure.client.fennel.aniseed", janet = "conjure.client.janet.netrepl", hy = "conjure.client.hy.stdio", julia = "conjure.client.julia.stdio", racket = "conjure.client.racket.stdio", scheme = "conjure.client.scheme.stdio", lua = "conjure.client.lua.neovim", lisp = "conjure.client.common-lisp.swank", python = "conjure.client.python.stdio", rust = "conjure.client.rust.evcxr", sql = "conjure.client.sql.stdio"}, filetype_suffixes = {racket = {"rkt"}, scheme = {"scm", "ss"}}, eval = {result_register = "c", inline_results = true, inline = {highlight = "comment", prefix = "=> "}, comment_prefix = nil, gsubs = {}}, mapping = {prefix = "<localleader>", enable_ft_mappings = true, enable_defaults = true}, completion = {omnifunc = "ConjureOmnifunc", fallback = "syntaxcomplete#Complete"}, highlight = {group = "IncSearch", timeout = 500, enabled = false}, log = {treesitter = true, hud = {width = 0.42, height = 0.3, zindex = 1, enabled = true, passive_close_delay = 0, minimum_lifetime_ms = 20, overlap_padding = 0.1, border = "single", anchor = "NE", ignore_low_priority = false}, jump_to_latest = {cursor_scroll_position = "top", enabled = false}, break_length = 80, trim = {at = 10000, to = 6000}, strip_ansi_escape_sequences_line_limit = 1000, fold = {lines = 10, marker = {start = "~~~%{", ["end"] = "}%~~~"}, enabled = false}, botright = false, diagnostics = false, wrap = false}, extract = {context_header_lines = 24, form_pairs = {{"(", ")"}, {"{", "}"}, {"[", "]", true}}, tree_sitter = {enabled = true}}, preview = {sample_limit = 0.3}, debug = false})
if get_in({"mapping", "enable_defaults"}) then
  merge({mapping = {log_split = "ls", log_vsplit = "lv", log_tab = "lt", log_buf = "le", log_toggle = "lg", log_close_visible = "lq", log_reset_soft = "lr", log_reset_hard = "lR", log_jump_to_latest = "ll", eval_current_form = "ee", eval_comment_current_form = "ece", eval_root_form = "er", eval_comment_root_form = "ecr", eval_word = "ew", eval_comment_word = "ecw", eval_replace_form = "e!", eval_marked_form = "em", eval_file = "ef", eval_buf = "eb", eval_visual = "E", eval_motion = "E", eval_previous = "ep", def_word = "gd", doc_word = {"K"}}})
else
end
return {["get-in"] = get_in, filetypes = filetypes, ["get-in-fn"] = get_in_fn, ["assoc-in"] = assoc_in, merge = merge}
