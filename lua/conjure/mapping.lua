local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.mapping"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.bridge"), require("conjure.client"), require("conjure.config"), require("conjure.eval"), require("conjure.extract"), require("conjure.aniseed.fennel"), require("conjure.log"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local str = _local_0_[10]
local bridge = _local_0_[2]
local client = _local_0_[3]
local config = _local_0_[4]
local eval = _local_0_[5]
local extract = _local_0_[6]
local fennel = _local_0_[7]
local log = _local_0_[8]
local nvim = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.mapping"
do local _ = ({nil, _0_0, {{nil}, nil, nil, nil}})[2] end
local function cfg(k)
  return config["get-in"]({"mapping", k})
end
local function vim_repeat(mapping)
  return ("repeat#set(\"" .. nvim.fn.escape(mapping, "\"") .. "\", 1)")
end
local buf
do
  local v_0_
  local function buf0(mode_or_opts, cmd_suffix, keys, ...)
    if keys then
      local function _1_(...)
        if ("table" == type(mode_or_opts)) then
          return {a.get(mode_or_opts, "mode"), mode_or_opts}
        else
          return {mode_or_opts, {}}
        end
      end
      local _let_0_ = _1_(...)
      local mode = _let_0_[1]
      local opts = _let_0_[2]
      local args = {...}
      local mapping
      if a["string?"](keys) then
        mapping = (cfg("prefix") .. keys)
      else
        mapping = a.first(keys)
      end
      local cmd = (cmd_suffix and ("Conjure" .. cmd_suffix))
      if cmd then
        nvim.ex.command_(("-range " .. cmd), bridge["viml->lua"](unpack(args)))
      end
      local _4_
      if cmd then
        local function _5_(...)
          if (false ~= a.get(opts, "repeat?")) then
            return (":silent! call " .. vim_repeat(mapping) .. "<cr>")
          else
            return ""
          end
        end
        _4_ = (":" .. cmd .. "<cr>" .. _5_(...))
      else
        _4_ = unpack(args)
      end
      return nvim.buf_set_keymap(0, mode, mapping, _4_, {noremap = true, silent = true})
    end
  end
  v_0_ = buf0
  _0_0["buf"] = v_0_
  buf = v_0_
end
local eval_marked_form
do
  local v_0_
  local function eval_marked_form0()
    local mark = eval["marked-form"]()
    local mapping
    local function _1_(m)
      return ((":ConjureEvalMarkedForm<CR>" == m.rhs) and m.lhs)
    end
    mapping = a.some(_1_, nvim.buf_get_keymap(0, "n"))
    if (mark and mapping) then
      return nvim.ex.silent_("call", vim_repeat((mapping .. mark)))
    end
  end
  v_0_ = eval_marked_form0
  _0_0["eval-marked-form"] = v_0_
  eval_marked_form = v_0_
end
local on_filetype
do
  local v_0_
  local function on_filetype0()
    buf("n", "LogSplit", cfg("log_split"), "conjure.log", "split")
    buf("n", "LogVSplit", cfg("log_vsplit"), "conjure.log", "vsplit")
    buf("n", "LogTab", cfg("log_tab"), "conjure.log", "tab")
    buf("n", "LogCloseVisible", cfg("log_close_visible"), "conjure.log", "close-visible")
    buf("n", "LogResetSoft", cfg("log_reset_soft"), "conjure.log", "reset-soft")
    buf("n", "LogResetHard", cfg("log_reset_hard"), "conjure.log", "reset-hard")
    buf("n", nil, cfg("eval_motion"), ":set opfunc=ConjureEvalMotion<cr>g@")
    buf("n", "EvalCurrentForm", cfg("eval_current_form"), "conjure.eval", "current-form")
    buf("n", "EvalCommentCurrentForm", cfg("eval_comment_current_form"), "conjure.eval", "comment-current-form")
    buf("n", "EvalRootForm", cfg("eval_root_form"), "conjure.eval", "root-form")
    buf("n", "EvalCommentRootForm", cfg("eval_comment_root_form"), "conjure.eval", "comment-root-form")
    buf("n", "EvalWord", cfg("eval_word"), "conjure.eval", "word")
    buf("n", "EvalCommentWord", cfg("eval_comment_word"), "conjure.eval", "comment-word")
    buf("n", "EvalReplaceForm", cfg("eval_replace_form"), "conjure.eval", "replace-form")
    buf({["repeat?"] = false, mode = "n"}, "EvalMarkedForm", cfg("eval_marked_form"), "conjure.mapping", "eval-marked-form")
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
  v_0_ = on_filetype0
  _0_0["on-filetype"] = v_0_
  on_filetype = v_0_
end
local on_exit
do
  local v_0_
  local function on_exit0()
    local function _1_()
      return client["optional-call"]("on-exit")
    end
    return client["each-loaded-client"](_1_)
  end
  v_0_ = on_exit0
  _0_0["on-exit"] = v_0_
  on_exit = v_0_
end
local on_quit
do
  local v_0_
  local function on_quit0()
    return log["close-hud"]()
  end
  v_0_ = on_quit0
  _0_0["on-quit"] = v_0_
  on_quit = v_0_
end
local init
do
  local v_0_
  local function init0(filetypes)
    nvim.ex.augroup("conjure_init_filetypes")
    nvim.ex.autocmd_()
    nvim.ex.autocmd("FileType", str.join(",", filetypes), bridge["viml->lua"]("conjure.mapping", "on-filetype", {}))
    nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
    nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.log", "close-hud-passive", {}))
    nvim.ex.autocmd("CursorMoved", "*", bridge["viml->lua"]("conjure.inline", "clear", {}))
    nvim.ex.autocmd("CursorMovedI", "*", bridge["viml->lua"]("conjure.inline", "clear", {}))
    nvim.ex.autocmd("VimLeavePre", "*", bridge["viml->lua"]("conjure.log", "clear-close-hud-passive-timer", {}))
    nvim.ex.autocmd("ExitPre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "on-exit" .. "']()"))
    nvim.ex.autocmd("QuitPre", "*", ("lua require('" .. _2amodule_name_2a .. "')['" .. "on-quit" .. "']()"))
    return nvim.ex.augroup("END")
  end
  v_0_ = init0
  _0_0["init"] = v_0_
  init = v_0_
end
local eval_ranged_command
do
  local v_0_
  local function eval_ranged_command0(start, _end, code)
    if ("" == code) then
      return eval.range(a.dec(start), _end)
    else
      return eval.command(code)
    end
  end
  v_0_ = eval_ranged_command0
  _0_0["eval-ranged-command"] = v_0_
  eval_ranged_command = v_0_
end
local connect_command
do
  local v_0_
  local function connect_command0(...)
    local args = {...}
    local function _1_(...)
      if (1 == a.count(args)) then
        return {port = a.first(args)}
      else
        return {host = a.first(args), port = a.second(args)}
      end
    end
    return client.call("connect", _1_(...))
  end
  v_0_ = connect_command0
  _0_0["connect-command"] = v_0_
  connect_command = v_0_
end
local client_state_command
do
  local v_0_
  local function client_state_command0(state_key)
    if state_key then
      return client["set-state-key!"](state_key)
    else
      return a.println(client["state-key"]())
    end
  end
  v_0_ = client_state_command0
  _0_0["client-state-command"] = v_0_
  client_state_command = v_0_
end
local omnifunc
do
  local v_0_
  local function omnifunc0(find_start_3f, base)
    if find_start_3f then
      local _let_0_ = nvim.win_get_cursor(0)
      local row = _let_0_[1]
      local col = _let_0_[2]
      local _let_1_ = nvim.buf_get_lines(0, a.dec(row), row, false)
      local line = _let_1_[1]
      return (col - a.count(nvim.fn.matchstr(string.sub(line, 1, col), "\\k\\+$")))
    else
      return eval["completions-sync"](base)
    end
  end
  v_0_ = omnifunc0
  _0_0["omnifunc"] = v_0_
  omnifunc = v_0_
end
nvim.ex.function_(str.join("\n", {"ConjureEvalMotion(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
nvim.ex.function_(str.join("\n", {"ConjureOmnifunc(findstart, base)", "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])", "endfunction"}))
nvim.ex.command_("-nargs=? -range ConjureEval", bridge["viml->lua"]("conjure.mapping", "eval-ranged-command", {args = "<line1>, <line2>, <q-args>"}))
nvim.ex.command_("-nargs=* -range -complete=file ConjureConnect", bridge["viml->lua"]("conjure.mapping", "connect-command", {args = "<f-args>"}))
nvim.ex.command_("-nargs=* ConjureClientState", bridge["viml->lua"]("conjure.mapping", "client-state-command", {args = "<f-args>"}))
return nvim.ex.command_("ConjureSchool", bridge["viml->lua"]("conjure.school", "start", {}))