-- [nfnl] Compiled from fnl/conjure/config.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.config"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local assoc_in = (_2amodule_2a)["assoc-in"]
local filetypes = (_2amodule_2a).filetypes
local get_in = (_2amodule_2a)["get-in"]
local get_in_fn = (_2amodule_2a)["get-in-fn"]
local merge = (_2amodule_2a).merge
local a0 = (_2amodule_locals_2a).a
local ks__3evar = (_2amodule_locals_2a)["ks->var"]
local nvim0 = (_2amodule_locals_2a).nvim
local str0 = (_2amodule_locals_2a).str
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local function ks__3evar0(ks)
  return ("conjure#" .. str0.join("#", ks))
end
_2amodule_locals_2a["ks->var"] = ks__3evar0
do local _ = {ks__3evar0, nil} end
local function get_in0(ks)
  local key = ks__3evar0(ks)
  local v = (a0.get(nvim0.b, key) or a0.get(nvim0.g, key))
  if (a0["table?"](v) and a0.get(v, vim.type_idx) and a0.get(v, vim.val_idx)) then
    return a0.get(v, vim.val_idx)
  else
    return v
  end
end
_2amodule_2a["get-in"] = get_in0
do local _ = {get_in0, nil} end
local function filetypes0()
  return get_in0({"filetypes"})
end
_2amodule_2a["filetypes"] = filetypes0
do local _ = {filetypes0, nil} end
local function get_in_fn0(prefix_ks)
  local function _2_(ks)
    return get_in0(a0.concat(prefix_ks, ks))
  end
  return _2_
end
_2amodule_2a["get-in-fn"] = get_in_fn0
do local _ = {get_in_fn0, nil} end
local function assoc_in0(ks, v)
  a0.assoc(nvim0.g, ks__3evar0(ks), v)
  return v
end
_2amodule_2a["assoc-in"] = assoc_in0
do local _ = {assoc_in0, nil} end
local function merge0(tbl, opts, ks)
  local ks0 = (ks or {})
  local opts0 = (opts or {})
  local function _5_(_3_)
    local _arg_4_ = _3_
    local k = _arg_4_[1]
    local v = _arg_4_[2]
    local ks1 = a0.concat(ks0, {k})
    local current = get_in0(ks1)
    if (a0["table?"](v) and not a0.get(v, 1)) then
      return merge0(v, opts0, ks1)
    else
      if (a0["nil?"](current) or opts0["overwrite?"]) then
        return assoc_in0(ks1, v)
      else
        return nil
      end
    end
  end
  a0["run!"](_5_, a0["kv-pairs"](tbl))
  return nil
end
_2amodule_2a["merge"] = merge
merge({relative_file_root = nil, path_subs = nil, client_on_load = true, filetypes = {"clojure", "fennel", "janet", "hy", "julia", "racket", "scheme", "lua", "lisp", "python", "rust", "sql"}, filetype = {clojure = "conjure.client.clojure.nrepl", fennel = "conjure.client.fennel.aniseed", janet = "conjure.client.janet.netrepl", hy = "conjure.client.hy.stdio", julia = "conjure.client.julia.stdio", racket = "conjure.client.racket.stdio", scheme = "conjure.client.scheme.stdio", lua = "conjure.client.lua.neovim", lisp = "conjure.client.common-lisp.swank", python = "conjure.client.python.stdio", rust = "conjure.client.rust.evcxr", sql = "conjure.client.sql.stdio"}, filetype_suffixes = {racket = {"rkt"}, scheme = {"scm", "ss"}}, eval = {result_register = "c", inline_results = true, inline = {highlight = "comment", prefix = "=> "}, comment_prefix = nil, gsubs = {}}, mapping = {prefix = "<localleader>", enable_ft_mappings = true, enable_defaults = true}, completion = {omnifunc = "ConjureOmnifunc", fallback = "syntaxcomplete#Complete"}, highlight = {group = "IncSearch", timeout = 500, enabled = false}, log = {treesitter = true, hud = {width = 0.42, height = 0.3, zindex = 1, enabled = true, passive_close_delay = 0, minimum_lifetime_ms = 20, overlap_padding = 0.1, border = "single", anchor = "NE", ignore_low_priority = false}, jump_to_latest = {cursor_scroll_position = "top", enabled = false}, break_length = 80, trim = {at = 10000, to = 6000}, strip_ansi_escape_sequences_line_limit = 1000, fold = {lines = 10, marker = {start = "~~~%{", ["end"] = "}%~~~"}, enabled = false}, botright = false, diagnostics = false, wrap = false}, extract = {context_header_lines = 24, form_pairs = {{"(", ")"}, {"{", "}"}, {"[", "]", true}}, tree_sitter = {enabled = true}}, preview = {sample_limit = 0.3}, debug = false})
if get_in({"mapping", "enable_defaults"}) then
  merge({mapping = {log_split = "ls", log_vsplit = "lv", log_tab = "lt", log_buf = "le", log_toggle = "lg", log_close_visible = "lq", log_reset_soft = "lr", log_reset_hard = "lR", log_jump_to_latest = "ll", eval_current_form = "ee", eval_comment_current_form = "ece", eval_root_form = "er", eval_comment_root_form = "ecr", eval_word = "ew", eval_comment_word = "ecw", eval_replace_form = "e!", eval_marked_form = "em", eval_file = "ef", eval_buf = "eb", eval_visual = "E", eval_motion = "E", eval_previous = "ep", def_word = "gd", doc_word = {"K"}}})
else
end
return _2amodule_2a
