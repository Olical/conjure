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
local a, buffer, client, config, editor, event, extract, fs, inline, log, nvim, promise, str, text, timer, uuid = autoload("conjure.aniseed.core"), autoload("conjure.buffer"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.event"), autoload("conjure.extract"), autoload("conjure.fs"), autoload("conjure.inline"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.promise"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.timer"), autoload("conjure.uuid")
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
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["promise"] = promise
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["timer"] = timer
_2amodule_locals_2a["uuid"] = uuid
local function preview(opts)
  local sample_limit = editor["percent-width"](config["get-in"]({"preview", "sample_limit"}))
  local _1_
  if (("file" == opts.origin) or ("buf" == opts.origin)) then
    _1_ = text["right-sample"](opts["file-path"], sample_limit)
  else
    _1_ = text["left-sample"](opts.code, sample_limit)
  end
  return (client.get("comment-prefix") .. opts.action .. " (" .. opts.origin .. "): " .. _1_)
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
    vim.highlight.range(bufnr, namespace, config["get-in"]({"highlight", "group"}), hl_start, hl_end, "v", true)
    local function _3_()
      local function _4_()
        return vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      end
      return pcall(_4_)
    end
    return timer.defer(_3_, config["get-in"]({"highlight", "timeout"}))
  end
end
_2amodule_locals_2a["highlight-range"] = highlight_range
local function with_last_result_hook(opts)
  local buf = nvim.win_get_buf(0)
  local line = a.dec(a.first(nvim.win_get_cursor(0)))
  local function _6_(f)
    local function _7_(result)
      nvim.fn.setreg(config["get-in"]({"eval", "result_register"}), string.gsub(result, "%z", ""))
      if config["get-in"]({"eval", "inline_results"}) then
        inline.display({buf = buf, line = line, text = ("=> " .. result)})
      end
      if f then
        return f(result)
      end
    end
    return _7_
  end
  return a.update(opts, "on-result", _6_)
end
_2amodule_locals_2a["with-last-result-hook"] = with_last_result_hook
local function file()
  event.emit("eval", "file")
  local opts = {["file-path"] = fs["localise-path"](extract["file-path"]()), action = "eval", origin = "file"}
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
  local function _10_(opts)
    local opts0 = a.merge(opts, base_opts, {["file-path"] = extract["file-path"](), action = action})
    assoc_context(opts0)
    opts0.preview = preview(opts0)
    if not opts0["passive?"] then
      display_request(opts0)
    end
    return client.call(f_name, opts0)
  end
  return _10_
end
_2amodule_locals_2a["client-exec-fn"] = client_exec_fn
local function apply_gsubs(code)
  if code then
    local function _15_(code0, _12_)
      local _arg_13_ = _12_
      local name = _arg_13_[1]
      local _arg_14_ = _arg_13_[2]
      local pat = _arg_14_[1]
      local rep = _arg_14_[2]
      local ok_3f, val_or_err = pcall(string.gsub, code0, pat, rep)
      if ok_3f then
        return val_or_err
      else
        nvim.err_writeln(str.join({"Error from g:conjure#eval#gsubs: ", name, " - ", val_or_err}))
        return code0
      end
    end
    return a.reduce(_15_, code, a["kv-pairs"](nvim.g["conjure#eval#gsubs"]))
  end
end
_2amodule_locals_2a["apply-gsubs"] = apply_gsubs
local function eval_str(opts)
  highlight_range(opts.range)
  event.emit("eval", "str")
  a.update(opts, "code", apply_gsubs)
  local function _18_()
    if opts["passive?"] then
      return opts
    else
      return with_last_result_hook(opts)
    end
  end
  client_exec_fn("eval", "eval-str")(_18_())
  return nil
end
_2amodule_2a["eval-str"] = eval_str
local function wrap_emit(name, f)
  local function _19_(...)
    event.emit(name)
    return f(...)
  end
  return _19_
end
_2amodule_2a["wrap-emit"] = wrap_emit
local doc_str = wrap_emit("doc", client_exec_fn("doc", "doc-str"))
do end (_2amodule_locals_2a)["doc-str"] = doc_str
local def_str = wrap_emit("def", client_exec_fn("def", "def-str", {["suppress-hud?"] = true}))
do end (_2amodule_locals_2a)["def-str"] = def_str
local function current_form(extra_opts)
  local form = extract.form({})
  if form then
    local _let_20_ = form
    local content = _let_20_["content"]
    local range = _let_20_["range"]
    eval_str(a.merge({code = content, origin = "current-form", range = range}, extra_opts))
    return form
  end
end
_2amodule_2a["current-form"] = current_form
local function replace_form()
  local buf = nvim.win_get_buf(0)
  local win = nvim.tabpage_get_win(0)
  local form = extract.form({})
  if form then
    local _let_22_ = form
    local content = _let_22_["content"]
    local range = _let_22_["range"]
    local function _23_(result)
      buffer["replace-range"](buf, range, result)
      return editor["go-to"](win, a["get-in"](range, {"start", 1}), a.inc(a["get-in"](range, {"start", 2})))
    end
    eval_str({["on-result"] = _23_, ["suppress-hud?"] = true, code = content, origin = "replace-form", range = range})
    return form
  end
end
_2amodule_2a["replace-form"] = replace_form
local function root_form()
  local form = extract.form({["root?"] = true})
  if form then
    local _let_25_ = form
    local content = _let_25_["content"]
    local range = _let_25_["range"]
    return eval_str({code = content, origin = "root-form", range = range})
  end
end
_2amodule_2a["root-form"] = root_form
local function marked_form(mark)
  local comment_prefix = client.get("comment-prefix")
  local mark0 = (mark or extract["prompt-char"]())
  local ok_3f, err = nil, nil
  local function _27_()
    return editor["go-to-mark"](mark0)
  end
  ok_3f, err = pcall(_27_)
  if ok_3f then
    current_form({origin = ("marked-form [" .. mark0 .. "]")})
    editor["go-back"]()
  else
    log.append({(comment_prefix .. "Couldn't eval form at mark: " .. mark0), (comment_prefix .. err)}, {["break?"] = true})
  end
  return mark0
end
_2amodule_2a["marked-form"] = marked_form
local function insert_result_comment(tag, input)
  local buf = nvim.win_get_buf(0)
  local comment_prefix = (config["get-in"]({"eval", "comment_prefix"}) or client.get("comment-prefix"))
  if input then
    local _let_29_ = input
    local content = _let_29_["content"]
    local range = _let_29_["range"]
    local function _30_(result)
      return buffer["append-prefixed-line"](buf, range["end"], comment_prefix, result)
    end
    eval_str({["on-result"] = _30_, ["suppress-hud?"] = true, code = content, origin = ("comment-" .. tag), range = range})
    return input
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
  local _let_32_ = extract.word()
  local content = _let_32_["content"]
  local range = _let_32_["range"]
  if not a["empty?"](content) then
    return eval_str({code = content, origin = "word", range = range})
  end
end
_2amodule_2a["word"] = word
local function doc_word()
  local _let_34_ = extract.word()
  local content = _let_34_["content"]
  local range = _let_34_["range"]
  if not a["empty?"](content) then
    return doc_str({code = content, origin = "word", range = range})
  end
end
_2amodule_2a["doc-word"] = doc_word
local function def_word()
  local _let_36_ = extract.word()
  local content = _let_36_["content"]
  local range = _let_36_["range"]
  if not a["empty?"](content) then
    return def_str({code = content, origin = "word", range = range})
  end
end
_2amodule_2a["def-word"] = def_word
local function buf()
  local _let_38_ = extract.buf()
  local content = _let_38_["content"]
  local range = _let_38_["range"]
  return eval_str({code = content, origin = "buf", range = range})
end
_2amodule_2a["buf"] = buf
local function command(code)
  return eval_str({code = code, origin = "command"})
end
_2amodule_2a["command"] = command
local function range(start, _end)
  local _let_39_ = extract.range(start, _end)
  local content = _let_39_["content"]
  local range0 = _let_39_["range"]
  return eval_str({code = content, origin = "range", range = range0})
end
_2amodule_2a["range"] = range
local function selection(kind)
  local _let_40_ = extract.selection({["visual?"] = not kind, kind = (kind or nvim.fn.visualmode())})
  local content = _let_40_["content"]
  local range0 = _let_40_["range"]
  return eval_str({code = content, origin = "selection", range = range0})
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
      local _42_ = config["get-in"]({"completion", "fallback"})
      if _42_ then
        return nvim.call_function(_42_, {0, prefix})
      else
        return _42_
      end
    end
    return cb(a.map(wrap_completion_result, (results or _43_())))
  end
  if ("function" == type(client.get("completions"))) then
    return client.call("completions", assoc_context({cb = cb_wrap, prefix = prefix}))
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