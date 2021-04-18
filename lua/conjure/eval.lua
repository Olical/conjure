local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.eval"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.buffer"), require("conjure.client"), require("conjure.config"), require("conjure.editor"), require("conjure.event"), require("conjure.extract"), require("conjure.fs"), require("conjure.inline"), require("conjure.log"), require("conjure.aniseed.nvim"), require("conjure.promise"), require("conjure.text"), require("conjure.timer"), require("conjure.uuid")}
local a = _local_0_[1]
local log = _local_0_[10]
local nvim = _local_0_[11]
local promise = _local_0_[12]
local text = _local_0_[13]
local timer = _local_0_[14]
local uuid = _local_0_[15]
local buffer = _local_0_[2]
local client = _local_0_[3]
local config = _local_0_[4]
local editor = _local_0_[5]
local event = _local_0_[6]
local extract = _local_0_[7]
local fs = _local_0_[8]
local inline = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.eval"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local function preview(opts)
  local sample_limit = editor["percent-width"](config["get-in"]({"preview", "sample_limit"}))
  local function _1_()
    if (("file" == opts.origin) or ("buf" == opts.origin)) then
      return text["right-sample"](opts["file-path"], sample_limit)
    else
      return text["left-sample"](opts.code, sample_limit)
    end
  end
  return (client.get("comment-prefix") .. opts.action .. " (" .. opts.origin .. "): " .. _1_())
end
local function display_request(opts)
  return log.append({opts.preview}, a.merge(opts, {["break?"] = true}))
end
local function highlight_range(range)
  if (config["get-in"]({"highlight", "enabled"}) and vim.highlight) then
    local bufnr = (range.bufnr or nvim.buf.nr())
    local namespace = vim.api.nvim_create_namespace("conjure_highlight")
    local hl_start = {(range.start[1] - 1), range.start[2]}
    local hl_end = {((range["end"])[1] - 1), (range["end"])[2]}
    vim.highlight.range(bufnr, namespace, config["get-in"]({"highlight", "group"}), hl_start, hl_end, "v", true)
    local function _1_()
      local function _2_()
        return vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      end
      return pcall(_2_)
    end
    return timer.defer(_1_, config["get-in"]({"highlight", "timeout"}))
  end
end
local function with_last_result_hook(opts)
  local buf = nvim.win_get_buf(0)
  local line = a.dec(a.first(nvim.win_get_cursor(0)))
  local function _1_(f)
    local function _2_(result)
      nvim.fn.setreg(config["get-in"]({"eval", "result_register"}), result)
      if config["get-in"]({"eval", "inline_results"}) then
        inline.display({buf = buf, line = line, text = ("=> " .. result)})
      end
      if f then
        return f(result)
      end
    end
    return _2_
  end
  return a.update(opts, "on-result", _1_)
end
local file
do
  local v_0_
  local function file0()
    event.emit("eval", "file")
    local opts = {["file-path"] = fs["localise-path"](extract["file-path"]()), action = "eval", origin = "file"}
    opts.preview = preview(opts)
    display_request(opts)
    return client.call("eval-file", with_last_result_hook(opts))
  end
  v_0_ = file0
  _0_0["file"] = v_0_
  file = v_0_
end
local function assoc_context(opts)
  opts.context = (nvim.b["conjure#context"] or extract.context())
  return opts
end
local function client_exec_fn(action, f_name, base_opts)
  local function _1_(opts)
    local opts0 = a.merge(opts, base_opts, {["file-path"] = extract["file-path"](), action = action})
    assoc_context(opts0)
    opts0.preview = preview(opts0)
    if not opts0["passive?"] then
      display_request(opts0)
    end
    return client.call(f_name, opts0)
  end
  return _1_
end
local eval_str
do
  local v_0_
  local function eval_str0(opts)
    highlight_range(opts.range)
    event.emit("eval", "str")
    local function _1_()
      if opts["passive?"] then
        return opts
      else
        return with_last_result_hook(opts)
      end
    end
    client_exec_fn("eval", "eval-str")(_1_())
    return nil
  end
  v_0_ = eval_str0
  _0_0["eval-str"] = v_0_
  eval_str = v_0_
end
local wrap_emit
do
  local v_0_
  local function wrap_emit0(name, f)
    local function _1_(...)
      event.emit(name)
      return f(...)
    end
    return _1_
  end
  v_0_ = wrap_emit0
  _0_0["wrap-emit"] = v_0_
  wrap_emit = v_0_
end
local doc_str = wrap_emit("doc", client_exec_fn("doc", "doc-str"))
local def_str = wrap_emit("def", client_exec_fn("def", "def-str", {["suppress-hud?"] = true}))
local current_form
do
  local v_0_
  local function current_form0(extra_opts)
    local form = extract.form({})
    if form then
      local _let_0_ = form
      local content = _let_0_["content"]
      local range = _let_0_["range"]
      eval_str(a.merge({code = content, origin = "current-form", range = range}, extra_opts))
      return form
    end
  end
  v_0_ = current_form0
  _0_0["current-form"] = v_0_
  current_form = v_0_
end
local replace_form
do
  local v_0_
  local function replace_form0()
    local buf = nvim.win_get_buf(0)
    local win = nvim.tabpage_get_win(0)
    local form = extract.form({})
    if form then
      local _let_0_ = form
      local content = _let_0_["content"]
      local range = _let_0_["range"]
      local function _1_(result)
        buffer["replace-range"](buf, range, result)
        return editor["go-to"](win, a["get-in"](range, {"start", 1}), a.inc(a["get-in"](range, {"start", 2})))
      end
      eval_str({["on-result"] = _1_, ["suppress-hud?"] = true, code = content, origin = "replace-form", range = range})
      return form
    end
  end
  v_0_ = replace_form0
  _0_0["replace-form"] = v_0_
  replace_form = v_0_
end
local root_form
do
  local v_0_
  local function root_form0()
    local form = extract.form({["root?"] = true})
    if form then
      local _let_0_ = form
      local content = _let_0_["content"]
      local range = _let_0_["range"]
      return eval_str({code = content, origin = "root-form", range = range})
    end
  end
  v_0_ = root_form0
  _0_0["root-form"] = v_0_
  root_form = v_0_
end
local marked_form
do
  local v_0_
  local function marked_form0(mark)
    local comment_prefix = client.get("comment-prefix")
    local mark0 = (mark or extract["prompt-char"]())
    local ok_3f, err = nil, nil
    local function _1_()
      return editor["go-to-mark"](mark0)
    end
    ok_3f, err = pcall(_1_)
    if ok_3f then
      current_form({origin = ("marked-form [" .. mark0 .. "]")})
      editor["go-back"]()
    else
      log.append({(comment_prefix .. "Couldn't eval form at mark: " .. mark0), (comment_prefix .. err)}, {["break?"] = true})
    end
    return mark0
  end
  v_0_ = marked_form0
  _0_0["marked-form"] = v_0_
  marked_form = v_0_
end
local function insert_result_comment(tag, input)
  local buf = nvim.win_get_buf(0)
  local comment_prefix = (config["get-in"]({"eval", "comment_prefix"}) or client.get("comment-prefix"))
  if input then
    local _let_0_ = input
    local content = _let_0_["content"]
    local range = _let_0_["range"]
    local function _1_(result)
      return buffer["append-prefixed-line"](buf, range["end"], comment_prefix, result)
    end
    eval_str({["on-result"] = _1_, ["suppress-hud?"] = true, code = content, origin = ("comment-" .. tag), range = range})
    return input
  end
end
local comment_current_form
do
  local v_0_
  local function comment_current_form0()
    return insert_result_comment("current-form", extract.form({}))
  end
  v_0_ = comment_current_form0
  _0_0["comment-current-form"] = v_0_
  comment_current_form = v_0_
end
local comment_root_form
do
  local v_0_
  local function comment_root_form0()
    return insert_result_comment("root-form", extract.form({["root?"] = true}))
  end
  v_0_ = comment_root_form0
  _0_0["comment-root-form"] = v_0_
  comment_root_form = v_0_
end
local comment_word
do
  local v_0_
  local function comment_word0()
    return insert_result_comment("word", extract.word())
  end
  v_0_ = comment_word0
  _0_0["comment-word"] = v_0_
  comment_word = v_0_
end
local word
do
  local v_0_
  local function word0()
    local _let_0_ = extract.word()
    local content = _let_0_["content"]
    local range = _let_0_["range"]
    if not a["empty?"](content) then
      return eval_str({code = content, origin = "word", range = range})
    end
  end
  v_0_ = word0
  _0_0["word"] = v_0_
  word = v_0_
end
local doc_word
do
  local v_0_
  local function doc_word0()
    local _let_0_ = extract.word()
    local content = _let_0_["content"]
    local range = _let_0_["range"]
    if not a["empty?"](content) then
      return doc_str({code = content, origin = "word", range = range})
    end
  end
  v_0_ = doc_word0
  _0_0["doc-word"] = v_0_
  doc_word = v_0_
end
local def_word
do
  local v_0_
  local function def_word0()
    local _let_0_ = extract.word()
    local content = _let_0_["content"]
    local range = _let_0_["range"]
    if not a["empty?"](content) then
      return def_str({code = content, origin = "word", range = range})
    end
  end
  v_0_ = def_word0
  _0_0["def-word"] = v_0_
  def_word = v_0_
end
local buf
do
  local v_0_
  local function buf0()
    local _let_0_ = extract.buf()
    local content = _let_0_["content"]
    local range = _let_0_["range"]
    return eval_str({code = content, origin = "buf", range = range})
  end
  v_0_ = buf0
  _0_0["buf"] = v_0_
  buf = v_0_
end
local command
do
  local v_0_
  local function command0(code)
    return eval_str({code = code, origin = "command"})
  end
  v_0_ = command0
  _0_0["command"] = v_0_
  command = v_0_
end
local range
do
  local v_0_
  local function range0(start, _end)
    local _let_0_ = extract.range(start, _end)
    local content = _let_0_["content"]
    local range1 = _let_0_["range"]
    return eval_str({code = content, origin = "range", range = range1})
  end
  v_0_ = range0
  _0_0["range"] = v_0_
  range = v_0_
end
local selection
do
  local v_0_
  local function selection0(kind)
    local _let_0_ = extract.selection({["visual?"] = not kind, kind = (kind or nvim.fn.visualmode())})
    local content = _let_0_["content"]
    local range0 = _let_0_["range"]
    return eval_str({code = content, origin = "selection", range = range0})
  end
  v_0_ = selection0
  _0_0["selection"] = v_0_
  selection = v_0_
end
local function wrap_completion_result(result)
  if a["string?"](result) then
    return {word = result}
  else
    return result
  end
end
local completions
do
  local v_0_
  local function completions0(prefix, cb)
    local function cb_wrap(results)
      local function _2_()
        local _1_0 = config["get-in"]({"completion", "fallback"})
        if _1_0 then
          return nvim.call_function(_1_0, {0, prefix})
        else
          return _1_0
        end
      end
      return cb(a.map(wrap_completion_result, (results or _2_())))
    end
    if ("function" == type(client.get("completions"))) then
      return client.call("completions", assoc_context({cb = cb_wrap, prefix = prefix}))
    else
      return cb_wrap()
    end
  end
  v_0_ = completions0
  _0_0["completions"] = v_0_
  completions = v_0_
end
local completions_promise
do
  local v_0_
  local function completions_promise0(prefix)
    local p = promise.new()
    completions(prefix, promise["deliver-fn"](p))
    return p
  end
  v_0_ = completions_promise0
  _0_0["completions-promise"] = v_0_
  completions_promise = v_0_
end
local completions_sync
do
  local v_0_
  local function completions_sync0(prefix)
    local p = completions_promise(prefix)
    promise.await(p)
    return promise.close(p)
  end
  v_0_ = completions_sync0
  _0_0["completions-sync"] = v_0_
  completions_sync = v_0_
end
return nil