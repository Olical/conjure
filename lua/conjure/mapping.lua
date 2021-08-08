local _2afile_2a = "fnl/conjure/mapping.fnl"
local _1_
do
  local name_4_auto = "conjure.mapping"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.eval"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {["require-macros"] = {["conjure.macros"] = true}, autoload = {a = "conjure.aniseed.core", bridge = "conjure.bridge", client = "conjure.client", config = "conjure.config", eval = "conjure.eval", extract = "conjure.extract", log = "conjure.log", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local bridge = _local_4_[2]
local client = _local_4_[3]
local config = _local_4_[4]
local eval = _local_4_[5]
local extract = _local_4_[6]
local log = _local_4_[7]
local nvim = _local_4_[8]
local str = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.mapping"
do local _ = ({nil, _1_, nil, {{nil}, nil, nil, nil}})[2] end
local cfg
do
  local v_23_auto
  local function cfg0(k)
    return config["get-in"]({"mapping", k})
  end
  v_23_auto = cfg0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cfg"] = v_23_auto
  cfg = v_23_auto
end
local vim_repeat
do
  local v_23_auto
  local function vim_repeat0(mapping)
    return ("repeat#set(\"" .. nvim.fn.escape(mapping, "\"") .. "\", 1)")
  end
  v_23_auto = vim_repeat0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["vim-repeat"] = v_23_auto
  vim_repeat = v_23_auto
end
local buf
do
  local v_23_auto
  do
    local v_25_auto
    local function buf0(mode_or_opts, cmd_suffix, keys, ...)
      if keys then
        local function _9_(...)
          if ("table" == type(mode_or_opts)) then
            return {a.get(mode_or_opts, "mode"), mode_or_opts}
          else
            return {mode_or_opts, {}}
          end
        end
        local _let_8_ = _9_(...)
        local mode = _let_8_[1]
        local opts = _let_8_[2]
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
        local _12_
        if cmd then
          local _13_
          if (false ~= a.get(opts, "repeat?")) then
            _13_ = (":silent! call " .. vim_repeat(mapping) .. "<cr>")
          else
            _13_ = ""
          end
          _12_ = (":" .. cmd .. "<cr>" .. _13_)
        else
          _12_ = unpack(args)
        end
        return nvim.buf_set_keymap(0, mode, mapping, _12_, {noremap = true, silent = true})
      end
    end
    v_25_auto = buf0
    _1_["buf"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf"] = v_23_auto
  buf = v_23_auto
end
local eval_marked_form
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_marked_form0()
      local mark = eval["marked-form"]()
      local mapping
      local function _17_(m)
        return ((":ConjureEvalMarkedForm<CR>" == m.rhs) and m.lhs)
      end
      mapping = a.some(_17_, nvim.buf_get_keymap(0, "n"))
      if (mark and mapping) then
        return nvim.ex.silent_("call", vim_repeat((mapping .. mark)))
      end
    end
    v_25_auto = eval_marked_form0
    _1_["eval-marked-form"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-marked-form"] = v_23_auto
  eval_marked_form = v_23_auto
end
local on_filetype
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = on_filetype0
    _1_["on-filetype"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-filetype"] = v_23_auto
  on_filetype = v_23_auto
end
local on_exit
do
  local v_23_auto
  do
    local v_25_auto
    local function on_exit0()
      local function _20_()
        return client["optional-call"]("on-exit")
      end
      return client["each-loaded-client"](_20_)
    end
    v_25_auto = on_exit0
    _1_["on-exit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-exit"] = v_23_auto
  on_exit = v_23_auto
end
local on_quit
do
  local v_23_auto
  do
    local v_25_auto
    local function on_quit0()
      return log["close-hud"]()
    end
    v_25_auto = on_quit0
    _1_["on-quit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-quit"] = v_23_auto
  on_quit = v_23_auto
end
local init
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = init0
    _1_["init"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["init"] = v_23_auto
  init = v_23_auto
end
local eval_ranged_command
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_ranged_command0(start, _end, code)
      if ("" == code) then
        return eval.range(a.dec(start), _end)
      else
        return eval.command(code)
      end
    end
    v_25_auto = eval_ranged_command0
    _1_["eval-ranged-command"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-ranged-command"] = v_23_auto
  eval_ranged_command = v_23_auto
end
local connect_command
do
  local v_23_auto
  do
    local v_25_auto
    local function connect_command0(...)
      local args = {...}
      local function _22_(...)
        if (1 == a.count(args)) then
          return {port = a.first(args)}
        else
          return {host = a.first(args), port = a.second(args)}
        end
      end
      return client.call("connect", _22_(...))
    end
    v_25_auto = connect_command0
    _1_["connect-command"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect-command"] = v_23_auto
  connect_command = v_23_auto
end
local client_state_command
do
  local v_23_auto
  do
    local v_25_auto
    local function client_state_command0(state_key)
      if state_key then
        return client["set-state-key!"](state_key)
      else
        return a.println(client["state-key"]())
      end
    end
    v_25_auto = client_state_command0
    _1_["client-state-command"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["client-state-command"] = v_23_auto
  client_state_command = v_23_auto
end
local omnifunc
do
  local v_23_auto
  do
    local v_25_auto
    local function omnifunc0(find_start_3f, base)
      if find_start_3f then
        local _let_24_ = nvim.win_get_cursor(0)
        local row = _let_24_[1]
        local col = _let_24_[2]
        local _let_25_ = nvim.buf_get_lines(0, a.dec(row), row, false)
        local line = _let_25_[1]
        return (col - a.count(nvim.fn.matchstr(string.sub(line, 1, col), "\\k\\+$")))
      else
        return eval["completions-sync"](base)
      end
    end
    v_25_auto = omnifunc0
    _1_["omnifunc"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["omnifunc"] = v_23_auto
  omnifunc = v_23_auto
end
nvim.ex.function_(str.join("\n", {"ConjureEvalMotion(kind)", "call luaeval(\"require('conjure.eval')['selection'](_A)\", a:kind)", "endfunction"}))
nvim.ex.function_(str.join("\n", {"ConjureOmnifunc(findstart, base)", "return luaeval(\"require('conjure.mapping')['omnifunc'](_A[1] == 1, _A[2])\", [a:findstart, a:base])", "endfunction"}))
nvim.ex.command_("-nargs=? -range ConjureEval", bridge["viml->lua"]("conjure.mapping", "eval-ranged-command", {args = "<line1>, <line2>, <q-args>"}))
nvim.ex.command_("-nargs=* -range -complete=file ConjureConnect", bridge["viml->lua"]("conjure.mapping", "connect-command", {args = "<f-args>"}))
nvim.ex.command_("-nargs=* ConjureClientState", bridge["viml->lua"]("conjure.mapping", "client-state-command", {args = "<f-args>"}))
return nvim.ex.command_("ConjureSchool", bridge["viml->lua"]("conjure.school", "start", {}))