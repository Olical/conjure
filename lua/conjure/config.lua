local _2afile_2a = "fnl/conjure/config.fnl"
local _2amodule_name_2a = "conjure.config"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local function ks__3evar(ks)
  return ("conjure#" .. str.join("#", ks))
end
_2amodule_locals_2a["ks->var"] = ks__3evar
local function get_in(ks)
  local key = ks__3evar(ks)
  local v = (a.get(nvim.b, key) or a.get(nvim.g, key))
  if (a["table?"](v) and a.get(v, vim.type_idx) and a.get(v, vim.val_idx)) then
    return a.get(v, vim.val_idx)
  else
    return v
  end
end
_2amodule_2a["get-in"] = get_in
local function filetypes()
  return get_in({"filetypes"})
end
_2amodule_2a["filetypes"] = filetypes
local function get_in_fn(prefix_ks)
  local function _2_(ks)
    return get_in(a.concat(prefix_ks, ks))
  end
  return _2_
end
_2amodule_2a["get-in-fn"] = get_in_fn
local function assoc_in(ks, v)
  a.assoc(nvim.g, ks__3evar(ks), v)
  return v
end
_2amodule_2a["assoc-in"] = assoc_in
local function merge(tbl, opts, ks)
  local ks0 = (ks or {})
  local opts0 = (opts or {})
  local function _5_(_3_)
    local _arg_4_ = _3_
    local k = _arg_4_[1]
    local v = _arg_4_[2]
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
  a["run!"](_5_, a["kv-pairs"](tbl))
  return nil
end
_2amodule_2a["merge"] = merge
merge({relative_file_root = nil, path_subs = nil, client_on_load = true, filetypes = {"clojure", "fennel", "janet", "hy", "julia", "racket", "scheme", "lua", "lisp", "python", "rust"}, filetype = {clojure = "conjure.client.clojure.nrepl", fennel = "conjure.client.fennel.aniseed", janet = "conjure.client.janet.netrepl", hy = "conjure.client.hy.stdio", julia = "conjure.client.julia.stdio", racket = "conjure.client.racket.stdio", scheme = "conjure.client.scheme.stdio", lua = "conjure.client.lua.neovim", lisp = "conjure.client.common-lisp.swank", python = "conjure.client.python.stdio", rust = "conjure.client.rust.evcxr"}, filetype_suffixes = {racket = {"rkt"}, scheme = {"scm", "ss"}}, eval = {result_register = "c", inline_results = true, inline = {highlight = "comment", prefix = "=> "}, comment_prefix = nil, gsubs = {}}, mapping = {prefix = "<localleader>", log_split = "ls", log_vsplit = "lv", log_tab = "lt", log_buf = "le", log_toggle = "lg", log_close_visible = "lq", log_reset_soft = "lr", log_reset_hard = "lR", log_jump_to_latest = "ll", eval_current_form = "ee", eval_comment_current_form = "ece", eval_root_form = "er", eval_comment_root_form = "ecr", eval_word = "ew", eval_comment_word = "ecw", eval_replace_form = "e!", eval_marked_form = "em", eval_file = "ef", eval_buf = "eb", eval_visual = "E", eval_motion = "E", def_word = "gd", doc_word = {"K"}}, completion = {omnifunc = "ConjureOmnifunc", fallback = "syntaxcomplete#Complete"}, highlight = {group = "IncSearch", timeout = 500, enabled = false}, log = {hud = {width = 0.42, height = 0.3, enabled = true, passive_close_delay = 0, minimum_lifetime_ms = 20, overlap_padding = 0.1, border = "single", anchor = "NE", ignore_low_priority = false}, jump_to_latest = {cursor_scroll_position = "top", enabled = false}, break_length = 80, trim = {at = 10000, to = 6000}, strip_ansi_escape_sequences_line_limit = 1000, fold = {lines = 10, marker = {start = "~~~%{", ["end"] = "}%~~~"}, enabled = false}, wrap = false, botright = false}, extract = {context_header_lines = 24, form_pairs = {{"(", ")"}, {"{", "}"}, {"[", "]", true}}, tree_sitter = {enabled = true}}, preview = {sample_limit = 0.3}, debug = false})
return _2amodule_2a