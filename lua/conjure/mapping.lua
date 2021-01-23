local _0_0 = nil
do
  local name_0_ = "conjure.mapping"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.bridge"), require("conjure.client"), require("conjure.config"), require("conjure.eval"), require("conjure.extract"), require("conjure.aniseed.fennel"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", bridge = "conjure.bridge", client = "conjure.client", config = "conjure.config", eval = "conjure.eval", extract = "conjure.extract", fennel = "conjure.aniseed.fennel", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local bridge = _1_[2]
local client = _1_[3]
local config = _1_[4]
local eval = _1_[5]
local extract = _1_[6]
local fennel = _1_[7]
local nvim = _1_[8]
local str = _1_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.mapping"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local cfg = nil
do
  local v_0_ = nil
  local function cfg0(k)
    return config["get-in"]({"mapping", k})
  end
  v_0_ = cfg0
  _0_0["aniseed/locals"]["cfg"] = v_0_
  cfg = v_0_
end
local buf = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function buf0(mode, cmd_suffix, keys, ...)
      if keys then
        local args = {...}
        local cmd = (cmd_suffix and ("Conjure" .. cmd_suffix))
        if cmd then
          nvim.ex.command_(("-range " .. cmd), bridge["viml->lua"](unpack(args)))
        end
        local _4_
        if a["string?"](keys) then
          _4_ = (cfg("prefix") .. keys)
        else
          _4_ = a.first(keys)
        end
        local _6_
        if cmd then
          _6_ = (":" .. cmd .. "<cr>")
        else
          _6_ = unpack(args)
        end
        return nvim.buf_set_keymap(0, mode, _4_, _6_, {noremap = true, silent = true})
      end
    end
    v_0_0 = buf0
    _0_0["buf"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["buf"] = v_0_
  buf = v_0_
end
local on_filetype = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function on_filetype0()
      buf("n", nil, cfg("eval_motion"), ":set opfunc=ConjureEvalMotion<cr>g@")
      buf("n", "LogSplit", cfg("log_split"), "conjure.log", "split")
      buf("n", "LogVSplit", cfg("log_vsplit"), "conjure.log", "vsplit")
      buf("n", "LogTab", cfg("log_tab"), "conjure.log", "tab")
      buf("n", "LogCloseVisible", cfg("log_close_visible"), "conjure.log", "close-visible")
      buf("n", "LogResetSoft", cfg("log_reset_soft"), "conjure.log", "reset-soft")
      buf("n", "LogResetHard", cfg("log_reset_hard"), "conjure.log", "reset-hard")
      buf("n", "EvalCurrentForm", cfg("eval_current_form"), "conjure.eval", "current-form")
      buf("n", "EvalRootForm", cfg("eval_root_form"), "conjure.eval", "root-form")
      buf("n", "EvalReplaceForm", cfg("eval_replace_form"), "conjure.eval", "replace-form")
      buf("n", "EvalMarkedForm", cfg("eval_marked_form"), "conjure.eval", "marked-form")
      buf("n", "EvalWord", cfg("eval_word"), "conjure.eval", "word")
      buf("n", "EvalFile", cfg("eval_file"), "conjure.eval", "file")
      buf("n", "EvalBuf", cfg("eval_buf"), "conjure.eval", "buf")
      buf("v", "EvalVisual", cfg("eval_visual"), "conjure.eval", "selection")
      buf("n", "DocWord", cfg("doc_word"), "conjure.eval", "doc-word")
      buf("n", "DefWord", cfg("def_word"), "conjure.eval", "def-word")
      do
        local fn_name = config["get-in"]({"completion", "omnifunc"})
        if fn_name then
          nvim.ex.setlocal(("omnifunc=" .. fn_name))
        end
      end
      return client["optional-call"]("on-filetype")
    end
    v_0_0 = on_filetype0
    _0_0["on-filetype"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_0_
  on_filetype = v_0_
end
local init = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function init0(filetypes)
      nvim.ex.augroup("conjure_init_filetypes")
      nvim.ex.autocmd_()
      nvim.ex.autocmd("FileType", str.join(",", filetypes), bridge["viml->lua"]("conjure.mapping", "on-filetype", {}))
      nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
      nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
      nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.inline", "clear", {}))
      nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.inline", "clear", {}))
      nvim.ex.autocmd("VimLeavePre", "*", bridge["viml->lua"]("conjure.log", "clear-close-hud-passive-timer", {}))
      nvim.ex.autocmd("QuitPre", "*", bridge["viml->lua"]("conjure.log", "close-hud", {}))
      return nvim.ex.augroup("END")
    end
    v_0_0 = init0
    _0_0["init"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["init"] = v_0_
  init = v_0_
end
local eval_ranged_command = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_ranged_command0(start, _end, code)
      if ("" == code) then
        return eval.range(a.dec(start), _end)
      else
        return eval.command(code)
      end
    end
    v_0_0 = eval_ranged_command0
    _0_0["eval-ranged-command"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval-ranged-command"] = v_0_
  eval_ranged_command = v_0_
end
local connect_command = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connect_command0(...)
      local args = {...}
      local function _3_(...)
        if (1 == a.count(args)) then
          return {port = a.first(args)}
        else
          return {host = a.first(args), port = a.second(args)}
        end
      end
      return client.call("connect", _3_(...))
    end
    v_0_0 = connect_command0
    _0_0["connect-command"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connect-command"] = v_0_
  connect_command = v_0_
end
local client_state_command = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function client_state_command0(state_key)
      if state_key then
        return client["set-state-key!"](state_key)
      else
        return a.println(client["state-key"]())
      end
    end
    v_0_0 = client_state_command0
    _0_0["client-state-command"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["client-state-command"] = v_0_
  client_state_command = v_0_
end
local omnifunc = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
    v_0_0 = omnifunc0
    _0_0["omnifunc"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["omnifunc"] = v_0_
  omnifunc = v_0_
end
nvim.ex.function_(str.join("\n", {"ConjureEvalMotion(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
nvim.ex.function_(str.join("\n", {"ConjureOmnifunc(findstart, base)", "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])", "endfunction"}))
nvim.ex.command_("-nargs=? -range ConjureEval", bridge["viml->lua"]("conjure.mapping", "eval-ranged-command", {args = "<line1>, <line2>, <q-args>"}))
nvim.ex.command_("-nargs=* -range ConjureConnect", bridge["viml->lua"]("conjure.mapping", "connect-command", {args = "<f-args>"}))
nvim.ex.command_("-nargs=* ConjureClientState", bridge["viml->lua"]("conjure.mapping", "client-state-command", {args = "<f-args>"}))
return nvim.ex.command_("ConjureSchool", bridge["viml->lua"]("conjure.school", "start", {}))