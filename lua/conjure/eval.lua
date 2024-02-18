-- [nfnl] Compiled from fnl/conjure/eval.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.eval"
local _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
local _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
local autoload = (require("aniseed.autoload")).autoload
local a, buffer, client, config, editor, event, extract, fs, inline, log, nu, nvim, promise, str, text, timer, uuid = autoload("conjure.aniseed.core"), autoload("conjure.buffer"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.event"), autoload("conjure.extract"), autoload("conjure.fs"), autoload("conjure.inline"), autoload("conjure.log"), autoload("conjure.aniseed.nvim.util"), autoload("conjure.aniseed.nvim"), autoload("conjure.promise"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.timer"), autoload("conjure.uuid")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["buffer"] = buffer
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["editor"] = editor
_2amodule_locals_2a["event"] = event
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["inline"] = inline
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nu"] = nu
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["promise"] = promise
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["timer"] = timer
_2amodule_locals_2a["uuid"] = uuid
local buf = (_2amodule_2a).buf
local command = (_2amodule_2a).command
local comment_current_form = (_2amodule_2a)["comment-current-form"]
local comment_root_form = (_2amodule_2a)["comment-root-form"]
local comment_word = (_2amodule_2a)["comment-word"]
local completions = (_2amodule_2a).completions
local completions_promise = (_2amodule_2a)["completions-promise"]
local completions_sync = (_2amodule_2a)["completions-sync"]
local current_form = (_2amodule_2a)["current-form"]
local def_word = (_2amodule_2a)["def-word"]
local doc_word = (_2amodule_2a)["doc-word"]
local eval_str = (_2amodule_2a)["eval-str"]
local file = (_2amodule_2a).file
local marked_form = (_2amodule_2a)["marked-form"]
local previous = (_2amodule_2a).previous
local previous_evaluations = (_2amodule_2a)["previous-evaluations"]
local range = (_2amodule_2a).range
local replace_form = (_2amodule_2a)["replace-form"]
local root_form = (_2amodule_2a)["root-form"]
local selection = (_2amodule_2a).selection
local word = (_2amodule_2a).word
local wrap_emit = (_2amodule_2a)["wrap-emit"]
local a0 = (_2amodule_locals_2a).a
local apply_gsubs = (_2amodule_locals_2a)["apply-gsubs"]
local assoc_context = (_2amodule_locals_2a)["assoc-context"]
local buffer0 = (_2amodule_locals_2a).buffer
local client0 = (_2amodule_locals_2a).client
local client_exec_fn = (_2amodule_locals_2a)["client-exec-fn"]
local config0 = (_2amodule_locals_2a).config
local def_str = (_2amodule_locals_2a)["def-str"]
local display_request = (_2amodule_locals_2a)["display-request"]
local doc_str = (_2amodule_locals_2a)["doc-str"]
local editor0 = (_2amodule_locals_2a).editor
local event0 = (_2amodule_locals_2a).event
local extract0 = (_2amodule_locals_2a).extract
local fs0 = (_2amodule_locals_2a).fs
local highlight_range = (_2amodule_locals_2a)["highlight-range"]
local inline0 = (_2amodule_locals_2a).inline
local insert_result_comment = (_2amodule_locals_2a)["insert-result-comment"]
local log0 = (_2amodule_locals_2a).log
local nu0 = (_2amodule_locals_2a).nu
local nvim0 = (_2amodule_locals_2a).nvim
local preview = (_2amodule_locals_2a).preview
local promise0 = (_2amodule_locals_2a).promise
local str0 = (_2amodule_locals_2a).str
local text0 = (_2amodule_locals_2a).text
local timer0 = (_2amodule_locals_2a).timer
local uuid0 = (_2amodule_locals_2a).uuid
local with_last_result_hook = (_2amodule_locals_2a)["with-last-result-hook"]
local wrap_completion_result = (_2amodule_locals_2a)["wrap-completion-result"]
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local function preview0(opts)
  local sample_limit = editor0["percent-width"](config0["get-in"]({"preview", "sample_limit"}))
  local function _1_()
    if (("file" == opts.origin) or ("buf" == opts.origin)) then
      return text0["right-sample"](opts["file-path"], sample_limit)
    else
      return text0["left-sample"](opts.code, sample_limit)
    end
  end
  return str0.join({client0.get("comment-prefix"), opts.action, " (", opts.origin, "): ", _1_()})
end
_2amodule_locals_2a["preview"] = preview0
do local _ = {preview0, nil} end
local function display_request0(opts)
  return log0.append({opts.preview}, a0.merge(opts, {["break?"] = true}))
end
_2amodule_locals_2a["display-request"] = display_request0
do local _ = {display_request0, nil} end
local function highlight_range0(range0)
  if (config0["get-in"]({"highlight", "enabled"}) and vim.highlight and range0) then
    local bufnr = ((range0).bufnr or nvim0.buf.nr())
    local namespace = vim.api.nvim_create_namespace("conjure_highlight")
    local hl_start = {((range0.start)[1] - 1), (range0.start)[2]}
    local hl_end = {((range0["end"])[1] - 1), (range0["end"])[2]}
    vim.highlight.range(bufnr, namespace, config0["get-in"]({"highlight", "group"}), hl_start, hl_end, unpack({{regtype = "v", inclusive = true}}))
    local function _2_()
      local function _3_()
        return vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      end
      return pcall(_3_)
    end
    return timer0.defer(_2_, config0["get-in"]({"highlight", "timeout"}))
  else
    return nil
  end
end
_2amodule_locals_2a["highlight-range"] = highlight_range0
do local _ = {highlight_range0, nil} end
local function with_last_result_hook0(opts)
  local buf0 = nvim0.win_get_buf(0)
  local line = a0.dec(a0.first(nvim0.win_get_cursor(0)))
  local function _5_(f)
    local function _6_(result)
      nvim0.fn.setreg(config0["get-in"]({"eval", "result_register"}), string.gsub(result, "%z", ""))
      if config0["get-in"]({"eval", "inline_results"}) then
        inline0.display({buf = buf0, text = str0.join({config0["get-in"]({"eval", "inline", "prefix"}), result}), line = line})
      else
      end
      if f then
        return f(result)
      else
        return nil
      end
    end
    return _6_
  end
  return a0.update(opts, "on-result", _5_)
end
_2amodule_locals_2a["with-last-result-hook"] = with_last_result_hook0
do local _ = {with_last_result_hook0, nil} end
local function file0()
  event0.emit("eval", "file")
  local opts = {["file-path"] = fs0["localise-path"](extract0["file-path"]()), origin = "file", action = "eval"}
  opts.preview = preview0(opts)
  display_request0(opts)
  return client0.call("eval-file", with_last_result_hook0(opts))
end
_2amodule_2a["file"] = file0
do local _ = {file0, nil} end
local function assoc_context0(opts)
  if not opts.context then
    opts.context = (nvim0.b["conjure#context"] or extract0.context())
  else
  end
  return opts
end
_2amodule_locals_2a["assoc-context"] = assoc_context0
do local _ = {assoc_context0, nil} end
local function client_exec_fn0(action, f_name, base_opts)
  local function _10_(opts)
    local opts0 = a0.merge(opts, base_opts, {action = action, ["file-path"] = extract0["file-path"]()})
    assoc_context0(opts0)
    opts0.preview = preview0(opts0)
    if not opts0["passive?"] then
      display_request0(opts0)
    else
    end
    if opts0["jumping?"] then
      local function _12_()
        do
          local win = nvim0.get_current_win()
          local buf0 = nvim0.get_current_buf()
          nvim0.fn.settagstack(win, {items = {{tagname = opts0.code, bufnr = buf0, from = a0.concat({buf0}, nvim0.win_get_cursor(win), {0}), matchnr = 0}}}, "a")
        end
        return nu0.normal("m'")
      end
      pcall(_12_)
    else
    end
    return client0.call(f_name, opts0)
  end
  return _10_
end
_2amodule_locals_2a["client-exec-fn"] = client_exec_fn0
do local _ = {client_exec_fn0, nil} end
local function apply_gsubs0(code)
  if code then
    local function _17_(code0, _14_)
      local _arg_15_ = _14_
      local name = _arg_15_[1]
      local _arg_16_ = _arg_15_[2]
      local pat = _arg_16_[1]
      local rep = _arg_16_[2]
      local ok_3f, val_or_err = pcall(string.gsub, code0, pat, rep)
      if ok_3f then
        return val_or_err
      else
        nvim0.err_writeln(str0.join({"Error from g:conjure#eval#gsubs: ", name, " - ", val_or_err}))
        return code0
      end
    end
    return a0.reduce(_17_, code, a0["kv-pairs"]((nvim0.b["conjure#eval#gsubs"] or nvim0.g["conjure#eval#gsubs"])))
  else
    return nil
  end
end
_2amodule_locals_2a["apply-gsubs"] = apply_gsubs0
do local _ = {apply_gsubs0, nil} end
local previous_evaluations0 = ((_2amodule_2a)["previous-evaluations"] or {})
do end (_2amodule_2a)["previous-evaluations"] = previous_evaluations0
do local _ = {nil, nil} end
local function eval_str0(opts)
  a0.assoc(previous_evaluations0, a0.get(client0["current-client-module-name"](), "module-name", "unknown"), opts)
  highlight_range0(opts.range)
  event0.emit("eval", "str")
  a0.update(opts, "code", apply_gsubs0)
  local function _20_()
    if opts["passive?"] then
      return opts
    else
      return with_last_result_hook0(opts)
    end
  end
  client_exec_fn0("eval", "eval-str")(_20_())
  return nil
end
_2amodule_2a["eval-str"] = eval_str0
do local _ = {eval_str0, nil} end
local function previous0()
  local client_name = a0.get(client0["current-client-module-name"](), "module-name", "unknown")
  local opts = a0.get(previous_evaluations0, client_name)
  if opts then
    return eval_str0(opts)
  else
    return nil
  end
end
_2amodule_2a["previous"] = previous0
do local _ = {previous0, nil} end
local function wrap_emit0(name, f)
  local function _22_(...)
    event0.emit(name)
    return f(...)
  end
  return _22_
end
_2amodule_2a["wrap-emit"] = wrap_emit0
do local _ = {wrap_emit0, nil} end
local doc_str0 = wrap_emit0("doc", client_exec_fn0("doc", "doc-str"))
do end (_2amodule_locals_2a)["doc-str"] = doc_str0
do local _ = {nil, nil} end
local def_str0 = wrap_emit0("def", client_exec_fn0("def", "def-str", {["suppress-hud?"] = true, ["jumping?"] = true}))
do end (_2amodule_locals_2a)["def-str"] = def_str0
do local _ = {nil, nil} end
local function current_form0(extra_opts)
  local form = extract0.form({})
  if form then
    local _let_23_ = form
    local content = _let_23_["content"]
    local range0 = _let_23_["range"]
    eval_str0(a0.merge({code = content, range = range0, origin = "current-form"}, extra_opts))
    return form
  else
    return nil
  end
end
_2amodule_2a["current-form"] = current_form0
do local _ = {current_form0, nil} end
local function replace_form0()
  local buf0 = nvim0.win_get_buf(0)
  local win = nvim0.tabpage_get_win(0)
  local form = extract0.form({})
  if form then
    local _let_25_ = form
    local content = _let_25_["content"]
    local range0 = _let_25_["range"]
    local function _26_(result)
      buffer0["replace-range"](buf0, range0, result)
      return editor0["go-to"](win, a0["get-in"](range0, {"start", 1}), a0.inc(a0["get-in"](range0, {"start", 2})))
    end
    eval_str0({code = content, range = range0, origin = "replace-form", ["suppress-hud?"] = true, ["on-result"] = _26_})
    return form
  else
    return nil
  end
end
_2amodule_2a["replace-form"] = replace_form0
do local _ = {replace_form0, nil} end
local function root_form0()
  local form = extract0.form({["root?"] = true})
  if form then
    local _let_28_ = form
    local content = _let_28_["content"]
    local range0 = _let_28_["range"]
    return eval_str0({code = content, range = range0, origin = "root-form"})
  else
    return nil
  end
end
_2amodule_2a["root-form"] = root_form0
do local _ = {root_form0, nil} end
local function marked_form0(mark)
  local comment_prefix = client0.get("comment-prefix")
  local mark0 = (mark or extract0["prompt-char"]())
  local ok_3f, err = nil, nil
  local function _30_()
    return editor0["go-to-mark"](mark0)
  end
  ok_3f, err = pcall(_30_)
  if ok_3f then
    current_form0({origin = str0.join({"marked-form [", mark0, "]"})})
    editor0["go-back"]()
  else
    log0.append({str0.join({comment_prefix, "Couldn't eval form at mark: ", mark0}), str0.join({comment_prefix, err})}, {["break?"] = true})
  end
  return mark0
end
_2amodule_2a["marked-form"] = marked_form0
do local _ = {marked_form0, nil} end
local function insert_result_comment0(tag, input)
  local buf0 = nvim0.win_get_buf(0)
  local comment_prefix = (config0["get-in"]({"eval", "comment_prefix"}) or client0.get("comment-prefix"))
  if input then
    local _let_32_ = input
    local content = _let_32_["content"]
    local range0 = _let_32_["range"]
    local function _33_(result)
      return buffer0["append-prefixed-line"](buf0, (range0)["end"], comment_prefix, result)
    end
    eval_str0({code = content, range = range0, origin = str0.join({"comment-", tag}), ["suppress-hud?"] = true, ["on-result"] = _33_})
    return input
  else
    return nil
  end
end
_2amodule_locals_2a["insert-result-comment"] = insert_result_comment0
do local _ = {insert_result_comment0, nil} end
local function comment_current_form0()
  return insert_result_comment0("current-form", extract0.form({}))
end
_2amodule_2a["comment-current-form"] = comment_current_form0
do local _ = {comment_current_form0, nil} end
local function comment_root_form0()
  return insert_result_comment0("root-form", extract0.form({["root?"] = true}))
end
_2amodule_2a["comment-root-form"] = comment_root_form0
do local _ = {comment_root_form0, nil} end
local function comment_word0()
  return insert_result_comment0("word", extract0.word())
end
_2amodule_2a["comment-word"] = comment_word0
do local _ = {comment_word0, nil} end
local function word0()
  local _let_35_ = extract0.word()
  local content = _let_35_["content"]
  local range0 = _let_35_["range"]
  if not a0["empty?"](content) then
    return eval_str0({code = content, range = range0, origin = "word"})
  else
    return nil
  end
end
_2amodule_2a["word"] = word0
do local _ = {word0, nil} end
local function doc_word0()
  local _let_37_ = extract0.word()
  local content = _let_37_["content"]
  local range0 = _let_37_["range"]
  if not a0["empty?"](content) then
    return doc_str0({code = content, range = range0, origin = "word"})
  else
    return nil
  end
end
_2amodule_2a["doc-word"] = doc_word0
do local _ = {doc_word0, nil} end
local function def_word0()
  local _let_39_ = extract0.word()
  local content = _let_39_["content"]
  local range0 = _let_39_["range"]
  if not a0["empty?"](content) then
    return def_str0({code = content, range = range0, origin = "word"})
  else
    return nil
  end
end
_2amodule_2a["def-word"] = def_word0
do local _ = {def_word0, nil} end
local function buf0()
  local _let_41_ = extract0.buf()
  local content = _let_41_["content"]
  local range0 = _let_41_["range"]
  return eval_str0({code = content, range = range0, origin = "buf"})
end
_2amodule_2a["buf"] = buf0
do local _ = {buf0, nil} end
local function command0(code)
  return eval_str0({code = code, origin = "command"})
end
_2amodule_2a["command"] = command0
do local _ = {command0, nil} end
local function range0(start, _end)
  local _let_42_ = extract0.range(start, _end)
  local content = _let_42_["content"]
  local range1 = _let_42_["range"]
  return eval_str0({code = content, range = range1, origin = "range"})
end
_2amodule_2a["range"] = range0
do local _ = {range0, nil} end
local function selection0(kind)
  local _let_43_ = extract0.selection({kind = (kind or nvim0.fn.visualmode()), ["visual?"] = not kind})
  local content = _let_43_["content"]
  local range1 = _let_43_["range"]
  return eval_str0({code = content, range = range1, origin = "selection"})
end
_2amodule_2a["selection"] = selection0
do local _ = {selection0, nil} end
local function wrap_completion_result0(result)
  if a0["string?"](result) then
    return {word = result}
  else
    return result
  end
end
_2amodule_locals_2a["wrap-completion-result"] = wrap_completion_result0
do local _ = {wrap_completion_result0, nil} end
local function completions0(prefix, cb)
  local function cb_wrap(results)
    local function _45_()
      local _46_ = config0["get-in"]({"completion", "fallback"})
      if (nil ~= _46_) then
        return nvim0.call_function(_46_, {0, prefix})
      else
        return _46_
      end
    end
    return cb(a0.map(wrap_completion_result0, (results or _45_())))
  end
  if ("function" == type(client0.get("completions"))) then
    return client0.call("completions", assoc_context0({["file-path"] = extract0["file-path"](), prefix = prefix, cb = cb_wrap}))
  else
    return cb_wrap()
  end
end
_2amodule_2a["completions"] = completions0
do local _ = {completions0, nil} end
local function completions_promise0(prefix)
  local p = promise0.new()
  completions0(prefix, promise0["deliver-fn"](p))
  return p
end
_2amodule_2a["completions-promise"] = completions_promise0
do local _ = {completions_promise0, nil} end
local function completions_sync0(prefix)
  local p = completions_promise0(prefix)
  promise0.await(p)
  return promise0.close(p)
end
_2amodule_2a["completions-sync"] = completions_sync0
do local _ = {completions_sync0, nil} end
return _2amodule_2a
