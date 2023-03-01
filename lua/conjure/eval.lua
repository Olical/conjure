local _2afile_2a = "fnl/conjure/eval.fnl"
local _2amodule_name_2a = "conjure.eval"
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
local function preview(opts)
  local sample_limit = editor["percent-width"](config["get-in"]({"preview", "sample_limit"}))
  local function _1_()
    if (("file" == opts.origin) or ("buf" == opts.origin)) then
      return text["right-sample"](opts["file-path"], sample_limit)
    else
      return text["left-sample"](opts.code, sample_limit)
    end
  end
  return str.join({client.get("comment-prefix"), opts.action, " (", opts.origin, "): ", _1_()})
end
_2amodule_locals_2a["preview"] = preview
local function display_request(opts)
  return log.append({opts.preview}, a.merge(opts, {["break?"] = true}))
end
_2amodule_locals_2a["display-request"] = display_request
local function highlight_range(range)
  if (config["get-in"]({"highlight", "enabled"}) and vim.highlight and range) then
    local bufnr = (range.bufnr or nvim.buf.nr())
    local namespace = vim.api.nvim_create_namespace("conjure_highlight")
    local hl_start = {(range.start[1] - 1), range.start[2]}
    local hl_end = {((range["end"])[1] - 1), (range["end"])[2]}
    vim.highlight.range(bufnr, namespace, config["get-in"]({"highlight", "group"}), hl_start, hl_end, unpack({{regtype = "v", inclusive = true}}))
    local function _2_()
      local function _3_()
        return vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      end
      return pcall(_3_)
    end
    return timer.defer(_2_, config["get-in"]({"highlight", "timeout"}))
  else
    return nil
  end
end
_2amodule_locals_2a["highlight-range"] = highlight_range
local function with_last_result_hook(opts)
  local buf = nvim.win_get_buf(0)
  local line = a.dec(a.first(nvim.win_get_cursor(0)))
  local function _5_(f)
    local function _6_(result)
      nvim.fn.setreg(config["get-in"]({"eval", "result_register"}), string.gsub(result, "%z", ""))
      if config["get-in"]({"eval", "inline_results"}) then
        inline.display({buf = buf, text = str.join({config["get-in"]({"eval", "inline", "prefix"}), result}), line = line})
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
  return a.update(opts, "on-result", _5_)
end
_2amodule_locals_2a["with-last-result-hook"] = with_last_result_hook
local function file()
  event.emit("eval", "file")
  local opts = {["file-path"] = fs["localise-path"](extract["file-path"]()), origin = "file", action = "eval"}
  opts.preview = preview(opts)
  display_request(opts)
  return client.call("eval-file", with_last_result_hook(opts))
end
_2amodule_2a["file"] = file
local function assoc_context(opts)
  opts.context = (nvim.b["conjure#context"] or extract.context())
  return opts
end
_2amodule_locals_2a["assoc-context"] = assoc_context
local function client_exec_fn(action, f_name, base_opts)
  local function _9_(opts)
    local opts0 = a.merge(opts, base_opts, {action = action, ["file-path"] = extract["file-path"]()})
    assoc_context(opts0)
    opts0.preview = preview(opts0)
    if not opts0["passive?"] then
      display_request(opts0)
    else
    end
    if opts0["jumping?"] then
      local function _11_()
        do
          local win = nvim.get_current_win()
          local buf = nvim.get_current_buf()
          nvim.fn.settagstack(win, {items = {{tagname = opts0.code, bufnr = buf, from = a.concat({buf}, nvim.win_get_cursor(win), {0}), matchnr = 0}}}, "a")
        end
        return nu.normal("m'")
      end
      pcall(_11_)
    else
    end
    return client.call(f_name, opts0)
  end
  return _9_
end
_2amodule_locals_2a["client-exec-fn"] = client_exec_fn
local function apply_gsubs(code)
  if code then
    local function _16_(code0, _13_)
      local _arg_14_ = _13_
      local name = _arg_14_[1]
      local _arg_15_ = _arg_14_[2]
      local pat = _arg_15_[1]
      local rep = _arg_15_[2]
      local ok_3f, val_or_err = pcall(string.gsub, code0, pat, rep)
      if ok_3f then
        return val_or_err
      else
        nvim.err_writeln(str.join({"Error from g:conjure#eval#gsubs: ", name, " - ", val_or_err}))
        return code0
      end
    end
    return a.reduce(_16_, code, a["kv-pairs"]((nvim.b["conjure#eval#gsubs"] or nvim.g["conjure#eval#gsubs"])))
  else
    return nil
  end
end
_2amodule_locals_2a["apply-gsubs"] = apply_gsubs
local function eval_str(opts)
  highlight_range(opts.range)
  event.emit("eval", "str")
  a.update(opts, "code", apply_gsubs)
  local function _19_()
    if opts["passive?"] then
      return opts
    else
      return with_last_result_hook(opts)
    end
  end
  client_exec_fn("eval", "eval-str")(_19_())
  return nil
end
_2amodule_2a["eval-str"] = eval_str
local function wrap_emit(name, f)
  local function _20_(...)
    event.emit(name)
    return f(...)
  end
  return _20_
end
_2amodule_2a["wrap-emit"] = wrap_emit
local doc_str = wrap_emit("doc", client_exec_fn("doc", "doc-str"))
do end (_2amodule_locals_2a)["doc-str"] = doc_str
local def_str = wrap_emit("def", client_exec_fn("def", "def-str", {["suppress-hud?"] = true, ["jumping?"] = true}))
do end (_2amodule_locals_2a)["def-str"] = def_str
local function current_form(extra_opts)
  local form = extract.form({})
  if form then
    local _let_21_ = form
    local content = _let_21_["content"]
    local range = _let_21_["range"]
    eval_str(a.merge({code = content, range = range, origin = "current-form"}, extra_opts))
    return form
  else
    return nil
  end
end
_2amodule_2a["current-form"] = current_form
local function replace_form()
  local buf = nvim.win_get_buf(0)
  local win = nvim.tabpage_get_win(0)
  local form = extract.form({})
  if form then
    local _let_23_ = form
    local content = _let_23_["content"]
    local range = _let_23_["range"]
    local function _24_(result)
      buffer["replace-range"](buf, range, result)
      return editor["go-to"](win, a["get-in"](range, {"start", 1}), a.inc(a["get-in"](range, {"start", 2})))
    end
    eval_str({code = content, range = range, origin = "replace-form", ["suppress-hud?"] = true, ["on-result"] = _24_})
    return form
  else
    return nil
  end
end
_2amodule_2a["replace-form"] = replace_form
local function root_form()
  local form = extract.form({["root?"] = true})
  if form then
    local _let_26_ = form
    local content = _let_26_["content"]
    local range = _let_26_["range"]
    return eval_str({code = content, range = range, origin = "root-form"})
  else
    return nil
  end
end
_2amodule_2a["root-form"] = root_form
local function marked_form(mark)
  local comment_prefix = client.get("comment-prefix")
  local mark0 = (mark or extract["prompt-char"]())
  local ok_3f, err = nil, nil
  local function _28_()
    return editor["go-to-mark"](mark0)
  end
  ok_3f, err = pcall(_28_)
  if ok_3f then
    current_form({origin = str.join({"marked-form [", mark0, "]"})})
    editor["go-back"]()
  else
    log.append({str.join({comment_prefix, "Couldn't eval form at mark: ", mark0}), str.join({comment_prefix, err})}, {["break?"] = true})
  end
  return mark0
end
_2amodule_2a["marked-form"] = marked_form
local function insert_result_comment(tag, input)
  local buf = nvim.win_get_buf(0)
  local comment_prefix = (config["get-in"]({"eval", "comment_prefix"}) or client.get("comment-prefix"))
  if input then
    local _let_30_ = input
    local content = _let_30_["content"]
    local range = _let_30_["range"]
    local function _31_(result)
      return buffer["append-prefixed-line"](buf, range["end"], comment_prefix, result)
    end
    eval_str({code = content, range = range, origin = str.join({"comment-", tag}), ["suppress-hud?"] = true, ["on-result"] = _31_})
    return input
  else
    return nil
  end
end
_2amodule_locals_2a["insert-result-comment"] = insert_result_comment
local function comment_current_form()
  return insert_result_comment("current-form", extract.form({}))
end
_2amodule_2a["comment-current-form"] = comment_current_form
local function comment_root_form()
  return insert_result_comment("root-form", extract.form({["root?"] = true}))
end
_2amodule_2a["comment-root-form"] = comment_root_form
local function comment_word()
  return insert_result_comment("word", extract.word())
end
_2amodule_2a["comment-word"] = comment_word
local function word()
  local _let_33_ = extract.word()
  local content = _let_33_["content"]
  local range = _let_33_["range"]
  if not a["empty?"](content) then
    return eval_str({code = content, range = range, origin = "word"})
  else
    return nil
  end
end
_2amodule_2a["word"] = word
local function doc_word()
  local _let_35_ = extract.word()
  local content = _let_35_["content"]
  local range = _let_35_["range"]
  if not a["empty?"](content) then
    return doc_str({code = content, range = range, origin = "word"})
  else
    return nil
  end
end
_2amodule_2a["doc-word"] = doc_word
local function def_word()
  local _let_37_ = extract.word()
  local content = _let_37_["content"]
  local range = _let_37_["range"]
  if not a["empty?"](content) then
    return def_str({code = content, range = range, origin = "word"})
  else
    return nil
  end
end
_2amodule_2a["def-word"] = def_word
local function buf()
  local _let_39_ = extract.buf()
  local content = _let_39_["content"]
  local range = _let_39_["range"]
  return eval_str({code = content, range = range, origin = "buf"})
end
_2amodule_2a["buf"] = buf
local function command(code)
  return eval_str({code = code, origin = "command"})
end
_2amodule_2a["command"] = command
local function range(start, _end)
  local _let_40_ = extract.range(start, _end)
  local content = _let_40_["content"]
  local range0 = _let_40_["range"]
  return eval_str({code = content, range = range0, origin = "range"})
end
_2amodule_2a["range"] = range
local function selection(kind)
  local _let_41_ = extract.selection({kind = (kind or nvim.fn.visualmode()), ["visual?"] = not kind})
  local content = _let_41_["content"]
  local range0 = _let_41_["range"]
  return eval_str({code = content, range = range0, origin = "selection"})
end
_2amodule_2a["selection"] = selection
local function wrap_completion_result(result)
  if a["string?"](result) then
    return {word = result}
  else
    return result
  end
end
_2amodule_locals_2a["wrap-completion-result"] = wrap_completion_result
local function completions(prefix, cb)
  local function cb_wrap(results)
    local function _43_()
      local _44_ = config["get-in"]({"completion", "fallback"})
      if (nil ~= _44_) then
        return nvim.call_function(_44_, {0, prefix})
      else
        return _44_
      end
    end
    return cb(a.map(wrap_completion_result, (results or _43_())))
  end
  if ("function" == type(client.get("completions"))) then
    return client.call("completions", assoc_context({["file-path"] = extract["file-path"](), prefix = prefix, cb = cb_wrap}))
  else
    return cb_wrap()
  end
end
_2amodule_2a["completions"] = completions
local function completions_promise(prefix)
  local p = promise.new()
  completions(prefix, promise["deliver-fn"](p))
  return p
end
_2amodule_2a["completions-promise"] = completions_promise
local function completions_sync(prefix)
  local p = completions_promise(prefix)
  promise.await(p)
  return promise.close(p)
end
_2amodule_2a["completions-sync"] = completions_sync
return _2amodule_2a