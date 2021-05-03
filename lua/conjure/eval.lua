local _2afile_2a = "fnl/conjure/eval.fnl"
local _0_0
do
  local name_0_ = "conjure.eval"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.buffer"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.event"), autoload("conjure.extract"), autoload("conjure.fs"), autoload("conjure.inline"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.promise"), autoload("conjure.text"), autoload("conjure.timer"), autoload("conjure.uuid")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", buffer = "conjure.buffer", client = "conjure.client", config = "conjure.config", editor = "conjure.editor", event = "conjure.event", extract = "conjure.extract", fs = "conjure.fs", inline = "conjure.inline", log = "conjure.log", nvim = "conjure.aniseed.nvim", promise = "conjure.promise", text = "conjure.text", timer = "conjure.timer", uuid = "conjure.uuid"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
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
do local _ = ({nil, _0_0, nil, {{}, nil, nil, nil}})[2] end
local preview
do
  local v_0_
  local function preview0(opts)
    local sample_limit = editor["percent-width"](config["get-in"]({"preview", "sample_limit"}))
    local function _2_()
      if (("file" == opts.origin) or ("buf" == opts.origin)) then
        return text["right-sample"](opts["file-path"], sample_limit)
      else
        return text["left-sample"](opts.code, sample_limit)
      end
    end
    return (client.get("comment-prefix") .. opts.action .. " (" .. opts.origin .. "): " .. _2_())
  end
  v_0_ = preview0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["preview"] = v_0_
  preview = v_0_
end
local display_request
do
  local v_0_
  local function display_request0(opts)
    return log.append({opts.preview}, a.merge(opts, {["break?"] = true}))
  end
  v_0_ = display_request0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["display-request"] = v_0_
  display_request = v_0_
end
local highlight_range
do
  local v_0_
  local function highlight_range0(range)
    if (config["get-in"]({"highlight", "enabled"}) and vim.highlight) then
      local bufnr = (range.bufnr or nvim.buf.nr())
      local namespace = vim.api.nvim_create_namespace("conjure_highlight")
      local hl_start = {(range.start[1] - 1), range.start[2]}
      local hl_end = {((range["end"])[1] - 1), (range["end"])[2]}
      vim.highlight.range(bufnr, namespace, config["get-in"]({"highlight", "group"}), hl_start, hl_end, "v", true)
      local function _2_()
        local function _3_()
          return vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
        end
        return pcall(_3_)
      end
      return timer.defer(_2_, config["get-in"]({"highlight", "timeout"}))
    end
  end
  v_0_ = highlight_range0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["highlight-range"] = v_0_
  highlight_range = v_0_
end
local with_last_result_hook
do
  local v_0_
  local function with_last_result_hook0(opts)
    local buf = nvim.win_get_buf(0)
    local line = a.dec(a.first(nvim.win_get_cursor(0)))
    local function _2_(f)
      local function _3_(result)
        nvim.fn.setreg(config["get-in"]({"eval", "result_register"}), result)
        if config["get-in"]({"eval", "inline_results"}) then
          inline.display({buf = buf, line = line, text = ("=> " .. result)})
        end
        if f then
          return f(result)
        end
      end
      return _3_
    end
    return a.update(opts, "on-result", _2_)
  end
  v_0_ = with_last_result_hook0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["with-last-result-hook"] = v_0_
  with_last_result_hook = v_0_
end
local file
do
  local v_0_
  do
    local v_0_0
    local function file0()
      event.emit("eval", "file")
      local opts = {["file-path"] = fs["localise-path"](extract["file-path"]()), action = "eval", origin = "file"}
      opts.preview = preview(opts)
      display_request(opts)
      return client.call("eval-file", with_last_result_hook(opts))
    end
    v_0_0 = file0
    _0_0["file"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["file"] = v_0_
  file = v_0_
end
local assoc_context
do
  local v_0_
  local function assoc_context0(opts)
    opts.context = (nvim.b["conjure#context"] or extract.context())
    return opts
  end
  v_0_ = assoc_context0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["assoc-context"] = v_0_
  assoc_context = v_0_
end
local client_exec_fn
do
  local v_0_
  local function client_exec_fn0(action, f_name, base_opts)
    local function _2_(opts)
      local opts0 = a.merge(opts, base_opts, {["file-path"] = extract["file-path"](), action = action})
      assoc_context(opts0)
      opts0.preview = preview(opts0)
      if not opts0["passive?"] then
        display_request(opts0)
      end
      return client.call(f_name, opts0)
    end
    return _2_
  end
  v_0_ = client_exec_fn0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["client-exec-fn"] = v_0_
  client_exec_fn = v_0_
end
local eval_str
do
  local v_0_
  do
    local v_0_0
    local function eval_str0(opts)
      highlight_range(opts.range)
      event.emit("eval", "str")
      local function _2_()
        if opts["passive?"] then
          return opts
        else
          return with_last_result_hook(opts)
        end
      end
      client_exec_fn("eval", "eval-str")(_2_())
      return nil
    end
    v_0_0 = eval_str0
    _0_0["eval-str"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["eval-str"] = v_0_
  eval_str = v_0_
end
local wrap_emit
do
  local v_0_
  do
    local v_0_0
    local function wrap_emit0(name, f)
      local function _2_(...)
        event.emit(name)
        return f(...)
      end
      return _2_
    end
    v_0_0 = wrap_emit0
    _0_0["wrap-emit"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["wrap-emit"] = v_0_
  wrap_emit = v_0_
end
local doc_str
do
  local v_0_ = wrap_emit("doc", client_exec_fn("doc", "doc-str"))
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["doc-str"] = v_0_
  doc_str = v_0_
end
local def_str
do
  local v_0_ = wrap_emit("def", client_exec_fn("def", "def-str", {["suppress-hud?"] = true}))
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["def-str"] = v_0_
  def_str = v_0_
end
local current_form
do
  local v_0_
  do
    local v_0_0
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
    v_0_0 = current_form0
    _0_0["current-form"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["current-form"] = v_0_
  current_form = v_0_
end
local replace_form
do
  local v_0_
  do
    local v_0_0
    local function replace_form0()
      local buf = nvim.win_get_buf(0)
      local win = nvim.tabpage_get_win(0)
      local form = extract.form({})
      if form then
        local _let_0_ = form
        local content = _let_0_["content"]
        local range = _let_0_["range"]
        local function _2_(result)
          buffer["replace-range"](buf, range, result)
          return editor["go-to"](win, a["get-in"](range, {"start", 1}), a.inc(a["get-in"](range, {"start", 2})))
        end
        eval_str({["on-result"] = _2_, ["suppress-hud?"] = true, code = content, origin = "replace-form", range = range})
        return form
      end
    end
    v_0_0 = replace_form0
    _0_0["replace-form"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["replace-form"] = v_0_
  replace_form = v_0_
end
local root_form
do
  local v_0_
  do
    local v_0_0
    local function root_form0()
      local form = extract.form({["root?"] = true})
      if form then
        local _let_0_ = form
        local content = _let_0_["content"]
        local range = _let_0_["range"]
        return eval_str({code = content, origin = "root-form", range = range})
      end
    end
    v_0_0 = root_form0
    _0_0["root-form"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["root-form"] = v_0_
  root_form = v_0_
end
local marked_form
do
  local v_0_
  do
    local v_0_0
    local function marked_form0(mark)
      local comment_prefix = client.get("comment-prefix")
      local mark0 = (mark or extract["prompt-char"]())
      local ok_3f, err = nil, nil
      local function _2_()
        return editor["go-to-mark"](mark0)
      end
      ok_3f, err = pcall(_2_)
      if ok_3f then
        current_form({origin = ("marked-form [" .. mark0 .. "]")})
        editor["go-back"]()
      else
        log.append({(comment_prefix .. "Couldn't eval form at mark: " .. mark0), (comment_prefix .. err)}, {["break?"] = true})
      end
      return mark0
    end
    v_0_0 = marked_form0
    _0_0["marked-form"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["marked-form"] = v_0_
  marked_form = v_0_
end
local insert_result_comment
do
  local v_0_
  local function insert_result_comment0(tag, input)
    local buf = nvim.win_get_buf(0)
    local comment_prefix = (config["get-in"]({"eval", "comment_prefix"}) or client.get("comment-prefix"))
    if input then
      local _let_0_ = input
      local content = _let_0_["content"]
      local range = _let_0_["range"]
      local function _2_(result)
        return buffer["append-prefixed-line"](buf, range["end"], comment_prefix, result)
      end
      eval_str({["on-result"] = _2_, ["suppress-hud?"] = true, code = content, origin = ("comment-" .. tag), range = range})
      return input
    end
  end
  v_0_ = insert_result_comment0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["insert-result-comment"] = v_0_
  insert_result_comment = v_0_
end
local comment_current_form
do
  local v_0_
  do
    local v_0_0
    local function comment_current_form0()
      return insert_result_comment("current-form", extract.form({}))
    end
    v_0_0 = comment_current_form0
    _0_0["comment-current-form"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["comment-current-form"] = v_0_
  comment_current_form = v_0_
end
local comment_root_form
do
  local v_0_
  do
    local v_0_0
    local function comment_root_form0()
      return insert_result_comment("root-form", extract.form({["root?"] = true}))
    end
    v_0_0 = comment_root_form0
    _0_0["comment-root-form"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["comment-root-form"] = v_0_
  comment_root_form = v_0_
end
local comment_word
do
  local v_0_
  do
    local v_0_0
    local function comment_word0()
      return insert_result_comment("word", extract.word())
    end
    v_0_0 = comment_word0
    _0_0["comment-word"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["comment-word"] = v_0_
  comment_word = v_0_
end
local word
do
  local v_0_
  do
    local v_0_0
    local function word0()
      local _let_0_ = extract.word()
      local content = _let_0_["content"]
      local range = _let_0_["range"]
      if not a["empty?"](content) then
        return eval_str({code = content, origin = "word", range = range})
      end
    end
    v_0_0 = word0
    _0_0["word"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["word"] = v_0_
  word = v_0_
end
local doc_word
do
  local v_0_
  do
    local v_0_0
    local function doc_word0()
      local _let_0_ = extract.word()
      local content = _let_0_["content"]
      local range = _let_0_["range"]
      if not a["empty?"](content) then
        return doc_str({code = content, origin = "word", range = range})
      end
    end
    v_0_0 = doc_word0
    _0_0["doc-word"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["doc-word"] = v_0_
  doc_word = v_0_
end
local def_word
do
  local v_0_
  do
    local v_0_0
    local function def_word0()
      local _let_0_ = extract.word()
      local content = _let_0_["content"]
      local range = _let_0_["range"]
      if not a["empty?"](content) then
        return def_str({code = content, origin = "word", range = range})
      end
    end
    v_0_0 = def_word0
    _0_0["def-word"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["def-word"] = v_0_
  def_word = v_0_
end
local buf
do
  local v_0_
  do
    local v_0_0
    local function buf0()
      local _let_0_ = extract.buf()
      local content = _let_0_["content"]
      local range = _let_0_["range"]
      return eval_str({code = content, origin = "buf", range = range})
    end
    v_0_0 = buf0
    _0_0["buf"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["buf"] = v_0_
  buf = v_0_
end
local command
do
  local v_0_
  do
    local v_0_0
    local function command0(code)
      return eval_str({code = code, origin = "command"})
    end
    v_0_0 = command0
    _0_0["command"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["command"] = v_0_
  command = v_0_
end
local range
do
  local v_0_
  do
    local v_0_0
    local function range0(start, _end)
      local _let_0_ = extract.range(start, _end)
      local content = _let_0_["content"]
      local range1 = _let_0_["range"]
      return eval_str({code = content, origin = "range", range = range1})
    end
    v_0_0 = range0
    _0_0["range"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["range"] = v_0_
  range = v_0_
end
local selection
do
  local v_0_
  do
    local v_0_0
    local function selection0(kind)
      local _let_0_ = extract.selection({["visual?"] = not kind, kind = (kind or nvim.fn.visualmode())})
      local content = _let_0_["content"]
      local range0 = _let_0_["range"]
      return eval_str({code = content, origin = "selection", range = range0})
    end
    v_0_0 = selection0
    _0_0["selection"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["selection"] = v_0_
  selection = v_0_
end
local wrap_completion_result
do
  local v_0_
  local function wrap_completion_result0(result)
    if a["string?"](result) then
      return {word = result}
    else
      return result
    end
  end
  v_0_ = wrap_completion_result0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["wrap-completion-result"] = v_0_
  wrap_completion_result = v_0_
end
local completions
do
  local v_0_
  do
    local v_0_0
    local function completions0(prefix, cb)
      local function cb_wrap(results)
        local function _3_()
          local _2_0 = config["get-in"]({"completion", "fallback"})
          if _2_0 then
            return nvim.call_function(_2_0, {0, prefix})
          else
            return _2_0
          end
        end
        return cb(a.map(wrap_completion_result, (results or _3_())))
      end
      if ("function" == type(client.get("completions"))) then
        return client.call("completions", assoc_context({cb = cb_wrap, prefix = prefix}))
      else
        return cb_wrap()
      end
    end
    v_0_0 = completions0
    _0_0["completions"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["completions"] = v_0_
  completions = v_0_
end
local completions_promise
do
  local v_0_
  do
    local v_0_0
    local function completions_promise0(prefix)
      local p = promise.new()
      completions(prefix, promise["deliver-fn"](p))
      return p
    end
    v_0_0 = completions_promise0
    _0_0["completions-promise"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["completions-promise"] = v_0_
  completions_promise = v_0_
end
local completions_sync
do
  local v_0_
  do
    local v_0_0
    local function completions_sync0(prefix)
      local p = completions_promise(prefix)
      promise.await(p)
      return promise.close(p)
    end
    v_0_0 = completions_sync0
    _0_0["completions-sync"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["completions-sync"] = v_0_
  completions_sync = v_0_
end
return nil