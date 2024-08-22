-- [nfnl] Compiled from fnl/conjure/eval.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local nvim = autoload("conjure.aniseed.nvim")
local str = autoload("conjure.aniseed.string")
local nu = autoload("conjure.aniseed.nvim.util")
local extract = autoload("conjure.extract")
local client = autoload("conjure.client")
local text = autoload("conjure.text")
local fs = autoload("conjure.fs")
local timer = autoload("conjure.timer")
local config = autoload("conjure.config")
local promise = autoload("conjure.promise")
local editor = autoload("conjure.editor")
local buffer = autoload("conjure.buffer")
local inline = autoload("conjure.inline")
local uuid = autoload("conjure.uuid")
local log = autoload("conjure.log")
local event = autoload("conjure.event")
local function preview(opts)
  local sample_limit = editor["percent-width"](config["get-in"]({"preview", "sample_limit"}))
  local function _2_()
    if (("file" == opts.origin) or ("buf" == opts.origin)) then
      return text["right-sample"](opts["file-path"], sample_limit)
    else
      return text["left-sample"](opts.code, sample_limit)
    end
  end
  return str.join({client.get("comment-prefix"), opts.action, " (", opts.origin, "): ", _2_()})
end
local function display_request(opts)
  return log.append({opts.preview}, a.merge(opts, {["break?"] = true}))
end
local function highlight_range(range)
  if (config["get-in"]({"highlight", "enabled"}) and vim.highlight and range) then
    local bufnr = (range.bufnr or nvim.buf.nr())
    local namespace = vim.api.nvim_create_namespace("conjure_highlight")
    local hl_start = {(range.start[1] - 1), range.start[2]}
    local hl_end = {(range["end"][1] - 1), range["end"][2]}
    vim.highlight.range(bufnr, namespace, config["get-in"]({"highlight", "group"}), hl_start, hl_end, unpack({{regtype = "v", inclusive = true}}))
    local function _3_()
      local function _4_()
        return vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      end
      return pcall(_4_)
    end
    return timer.defer(_3_, config["get-in"]({"highlight", "timeout"}))
  else
    return nil
  end
end
local function with_last_result_hook(opts)
  local buf = nvim.win_get_buf(0)
  local line = a.dec(a.first(nvim.win_get_cursor(0)))
  local function _6_(f)
    local function _7_(result)
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
    return _7_
  end
  return a.update(opts, "on-result", _6_)
end
local function file()
  event.emit("eval", "file")
  local opts = {["file-path"] = fs["localise-path"](extract["file-path"]()), origin = "file", action = "eval"}
  opts.preview = preview(opts)
  display_request(opts)
  return client.call("eval-file", with_last_result_hook(opts))
end
local function assoc_context(opts)
  if not opts.context then
    opts.context = (nvim.b["conjure#context"] or extract.context())
  else
  end
  return opts
end
local function client_exec_fn(action, f_name, base_opts)
  local function _11_(opts)
    local opts0 = a.merge(opts, base_opts, {action = action, ["file-path"] = extract["file-path"]()})
    assoc_context(opts0)
    opts0.preview = preview(opts0)
    if not opts0["passive?"] then
      display_request(opts0)
    else
    end
    if opts0["jumping?"] then
      local function _13_()
        do
          local win = nvim.get_current_win()
          local buf = nvim.get_current_buf()
          nvim.fn.settagstack(win, {items = {{tagname = opts0.code, bufnr = buf, from = a.concat({buf}, nvim.win_get_cursor(win), {0}), matchnr = 0}}}, "a")
        end
        return nu.normal("m'")
      end
      pcall(_13_)
    else
    end
    return client.call(f_name, opts0)
  end
  return _11_
end
local function apply_gsubs(code)
  if code then
    local function _17_(code0, _15_)
      local name = _15_[1]
      local _arg_16_ = _15_[2]
      local pat = _arg_16_[1]
      local rep = _arg_16_[2]
      local ok_3f, val_or_err = pcall(string.gsub, code0, pat, rep)
      if ok_3f then
        return val_or_err
      else
        nvim.err_writeln(str.join({"Error from g:conjure#eval#gsubs: ", name, " - ", val_or_err}))
        return code0
      end
    end
    return a.reduce(_17_, code, a["kv-pairs"]((nvim.b["conjure#eval#gsubs"] or nvim.g["conjure#eval#gsubs"])))
  else
    return nil
  end
end
local previous_evaluations = {}
local function eval_str(opts)
  a.assoc(previous_evaluations, a.get(client["current-client-module-name"](), "module-name", "unknown"), opts)
  highlight_range(opts.range)
  event.emit("eval", "str")
  a.update(opts, "code", apply_gsubs)
  local function _20_()
    if opts["passive?"] then
      return opts
    else
      return with_last_result_hook(opts)
    end
  end
  client_exec_fn("eval", "eval-str")(_20_())
  return nil
end
local function previous()
  local client_name = a.get(client["current-client-module-name"](), "module-name", "unknown")
  local opts = a.get(previous_evaluations, client_name)
  if opts then
    return eval_str(opts)
  else
    return nil
  end
end
local function wrap_emit(name, f)
  local function _22_(...)
    event.emit(name)
    return f(...)
  end
  return _22_
end
local doc_str = wrap_emit("doc", client_exec_fn("doc", "doc-str"))
local def_str = wrap_emit("def", client_exec_fn("def", "def-str", {["suppress-hud?"] = true, ["jumping?"] = true}))
local function current_form(extra_opts)
  local form = extract.form({})
  if form then
    local content = form["content"]
    local range = form["range"]
    eval_str(a.merge({code = content, range = range, origin = "current-form"}, extra_opts))
    return form
  else
    return nil
  end
end
local function replace_form()
  local buf = nvim.win_get_buf(0)
  local win = nvim.tabpage_get_win(0)
  local form = extract.form({})
  if form then
    local content = form["content"]
    local range = form["range"]
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
local function root_form()
  local form = extract.form({["root?"] = true})
  if form then
    local content = form["content"]
    local range = form["range"]
    return eval_str({code = content, range = range, origin = "root-form"})
  else
    return nil
  end
end
local function marked_form(mark)
  local comment_prefix = client.get("comment-prefix")
  local mark0 = (mark or extract["prompt-char"]())
  local ok_3f, err = nil, nil
  local function _27_()
    return editor["go-to-mark"](mark0)
  end
  ok_3f, err = pcall(_27_)
  if ok_3f then
    current_form({origin = str.join({"marked-form [", mark0, "]"})})
    editor["go-back"]()
  else
    log.append({str.join({comment_prefix, "Couldn't eval form at mark: ", mark0}), str.join({comment_prefix, err})}, {["break?"] = true})
  end
  return mark0
end
local function insert_result_comment(tag, input)
  local buf = nvim.win_get_buf(0)
  local comment_prefix = (config["get-in"]({"eval", "comment_prefix"}) or client.get("comment-prefix"))
  if input then
    local content = input["content"]
    local range = input["range"]
    local function _29_(result)
      return buffer["append-prefixed-line"](buf, range["end"], comment_prefix, result)
    end
    eval_str({code = content, range = range, origin = str.join({"comment-", tag}), ["suppress-hud?"] = true, ["on-result"] = _29_})
    return input
  else
    return nil
  end
end
local function comment_current_form()
  return insert_result_comment("current-form", extract.form({}))
end
local function comment_root_form()
  return insert_result_comment("root-form", extract.form({["root?"] = true}))
end
local function comment_word()
  return insert_result_comment("word", extract.word())
end
local function word()
  local _let_31_ = extract.word()
  local content = _let_31_["content"]
  local range = _let_31_["range"]
  if not a["empty?"](content) then
    return eval_str({code = content, range = range, origin = "word"})
  else
    return nil
  end
end
local function doc_word()
  local _let_33_ = extract.word()
  local content = _let_33_["content"]
  local range = _let_33_["range"]
  if not a["empty?"](content) then
    return doc_str({code = content, range = range, origin = "word"})
  else
    return nil
  end
end
local function def_word()
  local _let_35_ = extract.word()
  local content = _let_35_["content"]
  local range = _let_35_["range"]
  if not a["empty?"](content) then
    return def_str({code = content, range = range, origin = "word"})
  else
    return nil
  end
end
local function buf()
  local _let_37_ = extract.buf()
  local content = _let_37_["content"]
  local range = _let_37_["range"]
  return eval_str({code = content, range = range, origin = "buf"})
end
local function command(code)
  return eval_str({code = code, origin = "command"})
end
local function range(start, _end)
  local _let_38_ = extract.range(start, _end)
  local content = _let_38_["content"]
  local range0 = _let_38_["range"]
  return eval_str({code = content, range = range0, origin = "range"})
end
local function selection(kind)
  local _let_39_ = extract.selection({kind = (kind or nvim.fn.visualmode()), ["visual?"] = not kind})
  local content = _let_39_["content"]
  local range0 = _let_39_["range"]
  return eval_str({code = content, range = range0, origin = "selection"})
end
local function wrap_completion_result(result)
  if a["string?"](result) then
    return {word = result}
  else
    return result
  end
end
local function completions(prefix, cb)
  local function cb_wrap(results)
    local or_41_ = results
    if not or_41_ then
      local tmp_3_auto = config["get-in"]({"completion", "fallback"})
      if (nil ~= tmp_3_auto) then
        or_41_ = nvim.call_function(tmp_3_auto, {0, prefix})
      else
        or_41_ = nil
      end
    end
    return cb(a.map(wrap_completion_result, or_41_))
  end
  if ("function" == type(client.get("completions"))) then
    return client.call("completions", assoc_context({["file-path"] = extract["file-path"](), prefix = prefix, cb = cb_wrap}))
  else
    return cb_wrap()
  end
end
local function completions_promise(prefix)
  local p = promise.new()
  completions(prefix, promise["deliver-fn"](p))
  return p
end
local function completions_sync(prefix)
  local p = completions_promise(prefix)
  promise.await(p)
  return promise.close(p)
end
return {file = file, ["previous-evaluation"] = __fnl_global__previous_2devaluation, ["eval-str"] = eval_str, previous = previous, ["wrap-emit"] = wrap_emit, ["current-form"] = current_form, ["replace-form"] = replace_form, ["root-form"] = root_form, ["marked-form"] = marked_form, ["comment-current-form"] = comment_current_form, ["comment-root-form"] = comment_root_form, ["comment-word"] = comment_word, word = word, ["doc-word"] = doc_word, ["def-word"] = def_word, buf = buf, command = command, range = range, selection = selection, completions = completions, ["completions-promise"] = completions_promise, ["completions-sync"] = completions_sync}
