local _0_0 = nil
do
  local name_23_0_ = "conjure.mapping"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", bridge = "conjure.bridge", client = "conjure.client", config = "conjure.config2", eval = "conjure.eval", extract = "conjure.extract", fennel = "conjure.aniseed.fennel", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
  return {require("conjure.aniseed.core"), require("conjure.bridge"), require("conjure.client"), require("conjure.config2"), require("conjure.eval"), require("conjure.extract"), require("conjure.aniseed.fennel"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
end
local _2_ = _1_(...)
local a = _2_[1]
local bridge = _2_[2]
local client = _2_[3]
local config = _2_[4]
local eval = _2_[5]
local extract = _2_[6]
local fennel = _2_[7]
local nvim = _2_[8]
local str = _2_[9]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local cfg = nil
do
  local v_23_0_ = nil
  local function cfg0(k)
    return config["get-in"]({"mapping", k})
  end
  v_23_0_ = cfg0
  _0_0["aniseed/locals"]["cfg"] = v_23_0_
  cfg = v_23_0_
end
local buf = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function buf0(mode, keys, ...)
      if keys then
        local args = {...}
        local _3_
        if a["string?"](keys) then
          _3_ = (cfg("prefix") .. keys)
        else
          _3_ = a.first(keys)
        end
        local _5_
        if (2 == a.count(args)) then
          _5_ = (":" .. bridge["viml->lua"](unpack(args)) .. "<cr>")
        else
          _5_ = unpack(args)
        end
        return nvim.buf_set_keymap(0, mode, _3_, _5_, {noremap = true, silent = true})
      end
    end
    v_23_0_0 = buf0
    _0_0["buf"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["buf"] = v_23_0_
  buf = v_23_0_
end
local on_filetype = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function on_filetype0()
      buf("n", cfg("eval_motion"), ":set opfunc=ConjureEvalMotion<cr>g@")
      buf("n", cfg("log_split"), "conjure.log", "split")
      buf("n", cfg("log_vsplit"), "conjure.log", "vsplit")
      buf("n", cfg("log_tab"), "conjure.log", "tab")
      buf("n", cfg("log_close_visible"), "conjure.log", "close-visible")
      buf("n", cfg("eval_current_form"), "conjure.eval", "current-form")
      buf("n", cfg("eval_root_form"), "conjure.eval", "root-form")
      buf("n", cfg("eval_replace_form"), "conjure.eval", "replace-form")
      buf("n", cfg("eval_marked_form"), "conjure.eval", "marked-form")
      buf("n", cfg("eval_word"), "conjure.eval", "word")
      buf("n", cfg("eval_file"), "conjure.eval", "file")
      buf("n", cfg("eval_buf"), "conjure.eval", "buf")
      buf("v", cfg("eval_visual"), "conjure.eval", "selection")
      buf("n", cfg("doc_word"), "conjure.eval", "doc-word")
      buf("n", cfg("def_word"), "conjure.eval", "def-word")
      nvim.ex.setlocal("omnifunc=ConjureOmnifunc")
      return client["optional-call"]("on-filetype")
    end
    v_23_0_0 = on_filetype0
    _0_0["on-filetype"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_23_0_
  on_filetype = v_23_0_
end
local init = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function init0(filetypes)
      nvim.ex.augroup("conjure_init_filetypes")
      nvim.ex.autocmd_()
      nvim.ex.autocmd("FileType", str.join(",", filetypes), bridge["viml->lua"]("conjure.mapping", "on-filetype", {}))
      nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
      nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
      nvim.ex.autocmd("VimLeavePre", "*", bridge["viml->lua"]("conjure.log", "clear-close-hud-passive-timer", {}))
      return nvim.ex.augroup("END")
    end
    v_23_0_0 = init0
    _0_0["init"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["init"] = v_23_0_
  init = v_23_0_
end
local eval_ranged_command = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_ranged_command0(start, _end, code)
      if ("" == code) then
        return eval.range(a.dec(start), _end)
      else
        return eval.command(code)
      end
    end
    v_23_0_0 = eval_ranged_command0
    _0_0["eval-ranged-command"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-ranged-command"] = v_23_0_
  eval_ranged_command = v_23_0_
end
local omnifunc = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function omnifunc0(find_start_3f, base)
      if find_start_3f then
        local _3_ = nvim.win_get_cursor(0)
        local row = _3_[1]
        local col = _3_[2]
        local _4_ = nvim.buf_get_lines(0, a.dec(row), row, false)
        local line = _4_[1]
        return (col - a.count(nvim.fn.matchstr(string.sub(line, 1, col), "\\k\\+$")))
      else
        return eval["completions-sync"](base)
      end
    end
    v_23_0_0 = omnifunc0
    _0_0["omnifunc"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["omnifunc"] = v_23_0_
  omnifunc = v_23_0_
end
nvim.ex.function_(str.join("\n", {"ConjureEvalMotion(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
nvim.ex.function_(str.join("\n", {"ConjureOmnifunc(findstart, base)", "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])", "endfunction"}))
nvim.ex.command_("-nargs=? -range ConjureEval", bridge["viml->lua"]("conjure.mapping", "eval-ranged-command", {args = "<line1>, <line2>, <q-args>"}))
return nvim.ex.command_("ConjureSchool", bridge["viml->lua"]("conjure.school", "start", {}))