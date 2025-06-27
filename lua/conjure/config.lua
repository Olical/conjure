-- [nfnl] fnl/conjure/config.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local M = define("conjure.config")
local function ks__3evar(ks)
  return ("conjure#" .. str.join("#", ks))
end
M["get-in"] = function(ks)
  local key = ks__3evar(ks)
  local v = (core.get(vim.b, key) or core.get(vim.g, key))
  if (core["table?"](v) and core.get(v, vim.type_idx) and core.get(v, vim.val_idx)) then
    return core.get(v, vim.val_idx)
  else
    return v
  end
end
M.filetypes = function()
  return M["get-in"]({"filetypes"})
end
M["get-in-fn"] = function(prefix_ks)
  local function _3_(ks)
    return M["get-in"](core.concat(prefix_ks, ks))
  end
  return _3_
end
M["assoc-in"] = function(ks, v)
  core.assoc(vim.g, ks__3evar(ks), v)
  return v
end
M.merge = function(tbl, opts, ks)
  local ks0 = (ks or {})
  local opts0 = (opts or {})
  local function _5_(_4_)
    local k = _4_[1]
    local v = _4_[2]
    local ks1 = core.concat(ks0, {k})
    local current = M["get-in"](ks1)
    if (core["table?"](v) and not core.get(v, 1)) then
      return M.merge(v, opts0, ks1)
    else
      if (core["nil?"](current) or opts0["overwrite?"]) then
        return M["assoc-in"](ks1, v)
      else
        return nil
      end
    end
  end
  core["run!"](_5_, core["kv-pairs"](tbl))
  return nil
end
M.merge({relative_file_root = nil, path_subs = nil, client_on_load = true, filetypes = {"clojure", "fennel", "janet", "hy", "julia", "racket", "scheme", "lua", "lisp", "python", "rust", "sql", "r"}, filetype = {clojure = "conjure.client.clojure.nrepl", fennel = "conjure.client.fennel.nfnl", janet = "conjure.client.janet.netrepl", hy = "conjure.client.hy.stdio", julia = "conjure.client.julia.stdio", racket = "conjure.client.racket.stdio", scheme = "conjure.client.scheme.stdio", lua = "conjure.client.lua.neovim", lisp = "conjure.client.common-lisp.swank", python = "conjure.client.python.stdio", r = "conjure.client.r.stdio", rust = "conjure.client.rust.evcxr", sql = "conjure.client.sql.stdio"}, filetype_suffixes = {racket = {"rkt"}, scheme = {"scm", "ss"}}, eval = {result_register = "c", inline_results = true, inline = {highlight = "comment", prefix = "=> "}, comment_prefix = nil, gsubs = {}}, mapping = {prefix = "<localleader>", enable_ft_mappings = true, enable_defaults = true}, completion = {omnifunc = "ConjureOmnifunc", fallback = "syntaxcomplete#Complete"}, highlight = {group = "IncSearch", timeout = 500, enabled = false}, log = {treesitter = true, split = {width = nil, height = nil}, hud = {width = 0.42, height = 0.3, zindex = 1, enabled = true, passive_close_delay = 0, minimum_lifetime_ms = 250, overlap_padding = 0.1, border = "single", anchor = "NE", open_when = "last-log-line-not-visible", ignore_low_priority = false}, jump_to_latest = {cursor_scroll_position = "top", enabled = false}, break_length = 80, trim = {at = 10000, to = 6000}, strip_ansi_escape_sequences_line_limit = 1000, fold = {lines = 10, marker = {start = "~~~%{", ["end"] = "}%~~~"}, enabled = false}, botright = false, diagnostics = false, wrap = false}, extract = {context_header_lines = -1, form_pairs = {{"(", ")"}, {"{", "}"}, {"[", "]", true}}, tree_sitter = {enabled = true}}, preview = {sample_limit = 0.3}, debug = false})
if M["get-in"]({"mapping", "enable_defaults"}) then
  M.merge({mapping = {log_split = "ls", log_vsplit = "lv", log_tab = "lt", log_buf = "le", log_toggle = "lg", log_close_visible = "lq", log_reset_soft = "lr", log_reset_hard = "lR", log_jump_to_latest = "ll", eval_current_form = "ee", eval_comment_current_form = "ece", eval_root_form = "er", eval_comment_root_form = "ecr", eval_word = "ew", eval_comment_word = "ecw", eval_replace_form = "e!", eval_marked_form = "em", eval_file = "ef", eval_buf = "eb", eval_visual = "E", eval_motion = "E", eval_previous = "ep", def_word = "gd", doc_word = {"K"}}})
else
end
return M
