-- [nfnl] fnl/conjure/eval.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
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
local log = autoload("conjure.log")
local event = autoload("conjure.event")
local M = define("conjure.eval")
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
  return log.append({opts.preview}, core.merge(opts, {["break?"] = true}))
end
local function highlight_range(range)
  if (config["get-in"]({"highlight", "enabled"}) and vim.highlight and range) then
    local bufnr = (range.bufnr or vim.api.nvim_get_current_buf())
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
M.results = (M.results or {})
local function with_on_result_hook(opts)
  local buf = vim.api.nvim_win_get_buf(0)
  local line = core.dec(core.first(vim.api.nvim_win_get_cursor(0)))
  local function _6_(f)
    local function _7_(result)
      vim.fn.setreg(config["get-in"]({"eval", "result_register"}), string.gsub(result, "%z", ""))
      table.insert(M.results, {client = core.get(client["current-client-module-name"](), "module-name", "unknown"), buf = buf, request = opts, result = result})
      while (core.count(M.results) > 1000) do
        table.remove(M.results, 1)
      end
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
  return core.update(opts, "on-result", _6_)
end
local function assoc_context(opts)
  if not opts.context then
    opts.context = (vim.b["conjure#context"] or extract.context())
  else
  end
  return opts
end
local function client_exec_fn(action, f_name, base_opts)
  local function _11_(opts)
    local opts0 = core.merge(opts, base_opts, {action = action, ["file-path"] = extract["file-path"]()})
    assoc_context(opts0)
    opts0.preview = preview(opts0)
    client["optional-call"]("modify-client-exec-fn-opts", action, f_name, opts0)
    if not opts0["passive?"] then
      display_request(opts0)
    else
    end
    if opts0["jumping?"] then
      local function _13_()
        do
          local win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_get_current_buf()
          vim.fn.settagstack(win, {items = {{tagname = opts0.code, bufnr = buf, from = core.concat({buf}, vim.api.nvim_win_get_cursor(win), {0}), matchnr = 0}}}, "a")
        end
        return vim.api.nvim_feedkeys("m'", "n", false)
      end
      pcall(_13_)
    else
    end
    return client.call(f_name, opts0)
  end
  return _11_
end
M.file = function()
  event.emit("eval", "file")
  local opts = {["file-path"] = fs["localise-path"](extract["file-path"]()), origin = "file", action = "eval"}
  opts.preview = preview(opts)
  local function _15_()
    if opts["passive?"] then
      return opts
    else
      return with_on_result_hook(opts)
    end
  end
  client_exec_fn("eval", "eval-file")(_15_())
  return nil
end
local function apply_gsubs(code)
  if code then
    local function _18_(code0, _16_)
      local name = _16_[1]
      local _arg_17_ = _16_[2]
      local pat = _arg_17_[1]
      local rep = _arg_17_[2]
      local ok_3f, val_or_err = pcall(string.gsub, code0, pat, rep)
      if ok_3f then
        return val_or_err
      else
        vim.notify(str.join({"Error from g:conjure#eval#gsubs: ", name, " - ", val_or_err}), vim.log.levels.ERROR)
        return code0
      end
    end
    return core.reduce(_18_, code, core["kv-pairs"]((vim.b["conjure#eval#gsubs"] or vim.g["conjure#eval#gsubs"])))
  else
    return nil
  end
end
M["previous-evaluations"] = {}
M["eval-str"] = function(opts)
  core.assoc(M["previous-evaluations"], core.get(client["current-client-module-name"](), "module-name", "unknown"), opts)
  highlight_range(opts.range)
  event.emit("eval", "str")
  core.update(opts, "code", apply_gsubs)
  local function _21_()
    if opts["passive?"] then
      return opts
    else
      return with_on_result_hook(opts)
    end
  end
  client_exec_fn("eval", "eval-str")(_21_())
  return nil
end
M.previous = function()
  local client_name = core.get(client["current-client-module-name"](), "module-name", "unknown")
  local opts = core.get(M["previous-evaluations"], client_name)
  if opts then
    return M["eval-str"](opts)
  else
    return nil
  end
end
M["wrap-emit"] = function(name, f)
  local function _23_(...)
    event.emit(name)
    return f(...)
  end
  return _23_
end
local doc_str = M["wrap-emit"]("doc", client_exec_fn("doc", "doc-str"))
local def_str = M["wrap-emit"]("def", client_exec_fn("def", "def-str", {["suppress-hud?"] = true, ["jumping?"] = true}))
M["current-form"] = function(extra_opts)
  local form = extract.form({})
  if form then
    local content = form.content
    local range = form.range
    local node = form.node
    M["eval-str"](core.merge({code = content, range = range, node = node, origin = "current-form"}, extra_opts))
    return form
  else
    return nil
  end
end
M["replace-form"] = function()
  local buf = vim.api.nvim_win_get_buf(0)
  local win = vim.api.nvim_tabpage_get_win(0)
  local form = extract.form({})
  if form then
    local content = form.content
    local range = form.range
    local node = form.node
    local function _25_(result)
      buffer["replace-range"](buf, range, result)
      return editor["go-to"](win, core["get-in"](range, {"start", 1}), core.inc(core["get-in"](range, {"start", 2})))
    end
    M["eval-str"]({code = content, range = range, node = node, origin = "replace-form", ["suppress-hud?"] = true, ["on-result"] = _25_})
    return form
  else
    return nil
  end
end
M["root-form"] = function()
  local form = extract.form({["root?"] = true})
  if form then
    local content = form.content
    local range = form.range
    local node = form.node
    return M["eval-str"]({code = content, range = range, node = node, origin = "root-form"})
  else
    return nil
  end
end
M["marked-form"] = function(mark)
  local comment_prefix = client.get("comment-prefix")
  local mark0 = (mark or extract["prompt-char"]())
  local ok_3f, err
  local function _28_()
    return editor["go-to-mark"](mark0)
  end
  ok_3f, err = pcall(_28_)
  if ok_3f then
    M["current-form"]({origin = str.join({"marked-form [", mark0, "]"})})
    editor["go-back"]()
  else
    log.append({str.join({comment_prefix, "Couldn't eval form at mark: ", mark0}), str.join({comment_prefix, err})}, {["break?"] = true})
  end
  return mark0
end
local function insert_result_comment(tag, input)
  local buf = vim.api.nvim_win_get_buf(0)
  local comment_prefix = (config["get-in"]({"eval", "comment_prefix"}) or client.get("comment-prefix"))
  if input then
    local content = input.content
    local range = input.range
    local node = input.node
    local function _30_(result)
      return buffer["append-prefixed-line"](buf, range["end"], comment_prefix, result)
    end
    M["eval-str"]({code = content, range = range, node = node, origin = str.join({"comment-", tag}), ["suppress-hud?"] = true, ["on-result"] = _30_})
    return input
  else
    return nil
  end
end
M["comment-current-form"] = function()
  return insert_result_comment("current-form", extract.form({}))
end
M["comment-root-form"] = function()
  return insert_result_comment("root-form", extract.form({["root?"] = true}))
end
M["comment-word"] = function()
  return insert_result_comment("word", extract.word())
end
M.word = function()
  local _let_32_ = extract.word()
  local content = _let_32_.content
  local range = _let_32_.range
  local node = _let_32_.node
  if not core["empty?"](content) then
    return M["eval-str"]({code = content, range = range, node = node, origin = "word"})
  else
    return nil
  end
end
M["doc-word"] = function()
  local _let_34_ = extract.word()
  local content = _let_34_.content
  local range = _let_34_.range
  local node = _let_34_.node
  if not core["empty?"](content) then
    return doc_str({code = content, range = range, node = node, origin = "word"})
  else
    return nil
  end
end
M["def-word"] = function()
  local _let_36_ = extract.word()
  local content = _let_36_.content
  local range = _let_36_.range
  local node = _let_36_.node
  if not core["empty?"](content) then
    return def_str({code = content, range = range, node = node, origin = "word"})
  else
    return nil
  end
end
M.buf = function()
  local _let_38_ = extract.buf()
  local content = _let_38_.content
  local range = _let_38_.range
  return M["eval-str"]({code = content, range = range, origin = "buf"})
end
M.command = function(code)
  return M["eval-str"]({code = code, origin = "command"})
end
M.range = function(start, _end)
  local _let_39_ = extract.range(start, _end)
  local content = _let_39_.content
  local range = _let_39_.range
  return M["eval-str"]({code = content, range = range, origin = "range"})
end
M.selection = function(kind)
  local _let_40_ = extract.selection({kind = (kind or vim.fn.visualmode()), ["visual?"] = not kind})
  local content = _let_40_.content
  local range = _let_40_.range
  return M["eval-str"]({code = content, range = range, origin = "selection"})
end
local function wrap_completion_result(result)
  if core["string?"](result) then
    return {word = result}
  else
    return result
  end
end
M.completions = function(prefix, cb)
  local function cb_wrap(results)
    local or_42_ = results
    if not or_42_ then
      local tmp_3_ = config["get-in"]({"completion", "fallback"})
      if (nil ~= tmp_3_) then
        or_42_ = vim.api.nvim_call_function(tmp_3_, {0, prefix})
      else
        or_42_ = nil
      end
    end
    return cb(core.map(wrap_completion_result, or_42_))
  end
  if ("function" == type(client.get("completions"))) then
    return client.call("completions", assoc_context({["file-path"] = extract["file-path"](), prefix = prefix, cb = cb_wrap}))
  else
    return cb_wrap()
  end
end
M["completions-promise"] = function(prefix)
  local p = promise.new()
  M.completions(prefix, promise["deliver-fn"](p))
  return p
end
M["completions-sync"] = function(prefix)
  local p = M["completions-promise"](prefix)
  promise.await(p)
  return promise.close(p)
end
return M
