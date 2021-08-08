local _2afile_2a = "fnl/conjure/eval.fnl"
local _1_
do
  local name_4_auto = "conjure.eval"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.buffer"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.event"), autoload("conjure.extract"), autoload("conjure.fs"), autoload("conjure.inline"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.promise"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.timer"), autoload("conjure.uuid")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", buffer = "conjure.buffer", client = "conjure.client", config = "conjure.config", editor = "conjure.editor", event = "conjure.event", extract = "conjure.extract", fs = "conjure.fs", inline = "conjure.inline", log = "conjure.log", nvim = "conjure.aniseed.nvim", promise = "conjure.promise", str = "conjure.aniseed.string", text = "conjure.text", timer = "conjure.timer", uuid = "conjure.uuid"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local log = _local_4_[10]
local nvim = _local_4_[11]
local promise = _local_4_[12]
local str = _local_4_[13]
local text = _local_4_[14]
local timer = _local_4_[15]
local uuid = _local_4_[16]
local buffer = _local_4_[2]
local client = _local_4_[3]
local config = _local_4_[4]
local editor = _local_4_[5]
local event = _local_4_[6]
local extract = _local_4_[7]
local fs = _local_4_[8]
local inline = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.eval"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local preview
do
  local v_23_auto
  local function preview0(opts)
    local sample_limit = editor["percent-width"](config["get-in"]({"preview", "sample_limit"}))
    local _8_
    if (("file" == opts.origin) or ("buf" == opts.origin)) then
      _8_ = text["right-sample"](opts["file-path"], sample_limit)
    else
      _8_ = text["left-sample"](opts.code, sample_limit)
    end
    return (client.get("comment-prefix") .. opts.action .. " (" .. opts.origin .. "): " .. _8_)
  end
  v_23_auto = preview0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["preview"] = v_23_auto
  preview = v_23_auto
end
local display_request
do
  local v_23_auto
  local function display_request0(opts)
    return log.append({opts.preview}, a.merge(opts, {["break?"] = true}))
  end
  v_23_auto = display_request0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-request"] = v_23_auto
  display_request = v_23_auto
end
local highlight_range
do
  local v_23_auto
  local function highlight_range0(range)
    if (config["get-in"]({"highlight", "enabled"}) and vim.highlight and range) then
      local bufnr = (range.bufnr or nvim.buf.nr())
      local namespace = vim.api.nvim_create_namespace("conjure_highlight")
      local hl_start = {(range.start[1] - 1), range.start[2]}
      local hl_end = {((range["end"])[1] - 1), (range["end"])[2]}
      vim.highlight.range(bufnr, namespace, config["get-in"]({"highlight", "group"}), hl_start, hl_end, "v", true)
      local function _10_()
        local function _11_()
          return vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
        end
        return pcall(_11_)
      end
      return timer.defer(_10_, config["get-in"]({"highlight", "timeout"}))
    end
  end
  v_23_auto = highlight_range0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["highlight-range"] = v_23_auto
  highlight_range = v_23_auto
end
local with_last_result_hook
do
  local v_23_auto
  local function with_last_result_hook0(opts)
    local buf = nvim.win_get_buf(0)
    local line = a.dec(a.first(nvim.win_get_cursor(0)))
    local function _13_(f)
      local function _14_(result)
        nvim.fn.setreg(config["get-in"]({"eval", "result_register"}), string.gsub(result, "%z", ""))
        if config["get-in"]({"eval", "inline_results"}) then
          inline.display({buf = buf, line = line, text = ("=> " .. result)})
        end
        if f then
          return f(result)
        end
      end
      return _14_
    end
    return a.update(opts, "on-result", _13_)
  end
  v_23_auto = with_last_result_hook0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-last-result-hook"] = v_23_auto
  with_last_result_hook = v_23_auto
end
local file
do
  local v_23_auto
  do
    local v_25_auto
    local function file0()
      event.emit("eval", "file")
      local opts = {["file-path"] = fs["localise-path"](extract["file-path"]()), action = "eval", origin = "file"}
      opts.preview = preview(opts)
      display_request(opts)
      return client.call("eval-file", with_last_result_hook(opts))
    end
    v_25_auto = file0
    _1_["file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["file"] = v_23_auto
  file = v_23_auto
end
local assoc_context
do
  local v_23_auto
  local function assoc_context0(opts)
    opts.context = (nvim.b["conjure#context"] or extract.context())
    return opts
  end
  v_23_auto = assoc_context0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["assoc-context"] = v_23_auto
  assoc_context = v_23_auto
end
local client_exec_fn
do
  local v_23_auto
  local function client_exec_fn0(action, f_name, base_opts)
    local function _17_(opts)
      local opts0 = a.merge(opts, base_opts, {["file-path"] = extract["file-path"](), action = action})
      assoc_context(opts0)
      opts0.preview = preview(opts0)
      if not opts0["passive?"] then
        display_request(opts0)
      end
      return client.call(f_name, opts0)
    end
    return _17_
  end
  v_23_auto = client_exec_fn0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["client-exec-fn"] = v_23_auto
  client_exec_fn = v_23_auto
end
local apply_gsubs
do
  local v_23_auto
  local function apply_gsubs0(code)
    if code then
      local function _22_(code0, _19_)
        local _arg_20_ = _19_
        local name = _arg_20_[1]
        local _arg_21_ = _arg_20_[2]
        local pat = _arg_21_[1]
        local rep = _arg_21_[2]
        local ok_3f, val_or_err = pcall(string.gsub, code0, pat, rep)
        if ok_3f then
          return val_or_err
        else
          nvim.err_writeln(str.join({"Error from g:conjure#eval#gsubs: ", name, " - ", val_or_err}))
          return code0
        end
      end
      return a.reduce(_22_, code, a["kv-pairs"](nvim.g["conjure#eval#gsubs"]))
    end
  end
  v_23_auto = apply_gsubs0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["apply-gsubs"] = v_23_auto
  apply_gsubs = v_23_auto
end
local eval_str
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_str0(opts)
      highlight_range(opts.range)
      event.emit("eval", "str")
      a.update(opts, "code", apply_gsubs)
      local function _25_()
        if opts["passive?"] then
          return opts
        else
          return with_last_result_hook(opts)
        end
      end
      client_exec_fn("eval", "eval-str")(_25_())
      return nil
    end
    v_25_auto = eval_str0
    _1_["eval-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-str"] = v_23_auto
  eval_str = v_23_auto
end
local wrap_emit
do
  local v_23_auto
  do
    local v_25_auto
    local function wrap_emit0(name, f)
      local function _26_(...)
        event.emit(name)
        return f(...)
      end
      return _26_
    end
    v_25_auto = wrap_emit0
    _1_["wrap-emit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["wrap-emit"] = v_23_auto
  wrap_emit = v_23_auto
end
local doc_str
do
  local v_23_auto = wrap_emit("doc", client_exec_fn("doc", "doc-str"))
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["doc-str"] = v_23_auto
  doc_str = v_23_auto
end
local def_str
do
  local v_23_auto = wrap_emit("def", client_exec_fn("def", "def-str", {["suppress-hud?"] = true}))
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["def-str"] = v_23_auto
  def_str = v_23_auto
end
local current_form
do
  local v_23_auto
  do
    local v_25_auto
    local function current_form0(extra_opts)
      local form = extract.form({})
      if form then
        local _let_27_ = form
        local content = _let_27_["content"]
        local range = _let_27_["range"]
        eval_str(a.merge({code = content, origin = "current-form", range = range}, extra_opts))
        return form
      end
    end
    v_25_auto = current_form0
    _1_["current-form"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["current-form"] = v_23_auto
  current_form = v_23_auto
end
local replace_form
do
  local v_23_auto
  do
    local v_25_auto
    local function replace_form0()
      local buf = nvim.win_get_buf(0)
      local win = nvim.tabpage_get_win(0)
      local form = extract.form({})
      if form then
        local _let_29_ = form
        local content = _let_29_["content"]
        local range = _let_29_["range"]
        local function _30_(result)
          buffer["replace-range"](buf, range, result)
          return editor["go-to"](win, a["get-in"](range, {"start", 1}), a.inc(a["get-in"](range, {"start", 2})))
        end
        eval_str({["on-result"] = _30_, ["suppress-hud?"] = true, code = content, origin = "replace-form", range = range})
        return form
      end
    end
    v_25_auto = replace_form0
    _1_["replace-form"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["replace-form"] = v_23_auto
  replace_form = v_23_auto
end
local root_form
do
  local v_23_auto
  do
    local v_25_auto
    local function root_form0()
      local form = extract.form({["root?"] = true})
      if form then
        local _let_32_ = form
        local content = _let_32_["content"]
        local range = _let_32_["range"]
        return eval_str({code = content, origin = "root-form", range = range})
      end
    end
    v_25_auto = root_form0
    _1_["root-form"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["root-form"] = v_23_auto
  root_form = v_23_auto
end
local marked_form
do
  local v_23_auto
  do
    local v_25_auto
    local function marked_form0(mark)
      local comment_prefix = client.get("comment-prefix")
      local mark0 = (mark or extract["prompt-char"]())
      local ok_3f, err = nil, nil
      local function _34_()
        return editor["go-to-mark"](mark0)
      end
      ok_3f, err = pcall(_34_)
      if ok_3f then
        current_form({origin = ("marked-form [" .. mark0 .. "]")})
        editor["go-back"]()
      else
        log.append({(comment_prefix .. "Couldn't eval form at mark: " .. mark0), (comment_prefix .. err)}, {["break?"] = true})
      end
      return mark0
    end
    v_25_auto = marked_form0
    _1_["marked-form"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["marked-form"] = v_23_auto
  marked_form = v_23_auto
end
local insert_result_comment
do
  local v_23_auto
  local function insert_result_comment0(tag, input)
    local buf = nvim.win_get_buf(0)
    local comment_prefix = (config["get-in"]({"eval", "comment_prefix"}) or client.get("comment-prefix"))
    if input then
      local _let_36_ = input
      local content = _let_36_["content"]
      local range = _let_36_["range"]
      local function _37_(result)
        return buffer["append-prefixed-line"](buf, range["end"], comment_prefix, result)
      end
      eval_str({["on-result"] = _37_, ["suppress-hud?"] = true, code = content, origin = ("comment-" .. tag), range = range})
      return input
    end
  end
  v_23_auto = insert_result_comment0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["insert-result-comment"] = v_23_auto
  insert_result_comment = v_23_auto
end
local comment_current_form
do
  local v_23_auto
  do
    local v_25_auto
    local function comment_current_form0()
      return insert_result_comment("current-form", extract.form({}))
    end
    v_25_auto = comment_current_form0
    _1_["comment-current-form"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["comment-current-form"] = v_23_auto
  comment_current_form = v_23_auto
end
local comment_root_form
do
  local v_23_auto
  do
    local v_25_auto
    local function comment_root_form0()
      return insert_result_comment("root-form", extract.form({["root?"] = true}))
    end
    v_25_auto = comment_root_form0
    _1_["comment-root-form"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["comment-root-form"] = v_23_auto
  comment_root_form = v_23_auto
end
local comment_word
do
  local v_23_auto
  do
    local v_25_auto
    local function comment_word0()
      return insert_result_comment("word", extract.word())
    end
    v_25_auto = comment_word0
    _1_["comment-word"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["comment-word"] = v_23_auto
  comment_word = v_23_auto
end
local word
do
  local v_23_auto
  do
    local v_25_auto
    local function word0()
      local _let_39_ = extract.word()
      local content = _let_39_["content"]
      local range = _let_39_["range"]
      if not a["empty?"](content) then
        return eval_str({code = content, origin = "word", range = range})
      end
    end
    v_25_auto = word0
    _1_["word"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["word"] = v_23_auto
  word = v_23_auto
end
local doc_word
do
  local v_23_auto
  do
    local v_25_auto
    local function doc_word0()
      local _let_41_ = extract.word()
      local content = _let_41_["content"]
      local range = _let_41_["range"]
      if not a["empty?"](content) then
        return doc_str({code = content, origin = "word", range = range})
      end
    end
    v_25_auto = doc_word0
    _1_["doc-word"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["doc-word"] = v_23_auto
  doc_word = v_23_auto
end
local def_word
do
  local v_23_auto
  do
    local v_25_auto
    local function def_word0()
      local _let_43_ = extract.word()
      local content = _let_43_["content"]
      local range = _let_43_["range"]
      if not a["empty?"](content) then
        return def_str({code = content, origin = "word", range = range})
      end
    end
    v_25_auto = def_word0
    _1_["def-word"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["def-word"] = v_23_auto
  def_word = v_23_auto
end
local buf
do
  local v_23_auto
  do
    local v_25_auto
    local function buf0()
      local _let_45_ = extract.buf()
      local content = _let_45_["content"]
      local range = _let_45_["range"]
      return eval_str({code = content, origin = "buf", range = range})
    end
    v_25_auto = buf0
    _1_["buf"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf"] = v_23_auto
  buf = v_23_auto
end
local command
do
  local v_23_auto
  do
    local v_25_auto
    local function command0(code)
      return eval_str({code = code, origin = "command"})
    end
    v_25_auto = command0
    _1_["command"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["command"] = v_23_auto
  command = v_23_auto
end
local range
do
  local v_23_auto
  do
    local v_25_auto
    local function range0(start, _end)
      local _let_46_ = extract.range(start, _end)
      local content = _let_46_["content"]
      local range1 = _let_46_["range"]
      return eval_str({code = content, origin = "range", range = range1})
    end
    v_25_auto = range0
    _1_["range"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["range"] = v_23_auto
  range = v_23_auto
end
local selection
do
  local v_23_auto
  do
    local v_25_auto
    local function selection0(kind)
      local _let_47_ = extract.selection({["visual?"] = not kind, kind = (kind or nvim.fn.visualmode())})
      local content = _let_47_["content"]
      local range0 = _let_47_["range"]
      return eval_str({code = content, origin = "selection", range = range0})
    end
    v_25_auto = selection0
    _1_["selection"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["selection"] = v_23_auto
  selection = v_23_auto
end
local wrap_completion_result
do
  local v_23_auto
  local function wrap_completion_result0(result)
    if a["string?"](result) then
      return {word = result}
    else
      return result
    end
  end
  v_23_auto = wrap_completion_result0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["wrap-completion-result"] = v_23_auto
  wrap_completion_result = v_23_auto
end
local completions
do
  local v_23_auto
  do
    local v_25_auto
    local function completions0(prefix, cb)
      local function cb_wrap(results)
        local function _50_()
          local _49_ = config["get-in"]({"completion", "fallback"})
          if _49_ then
            return nvim.call_function(_49_, {0, prefix})
          else
            return _49_
          end
        end
        return cb(a.map(wrap_completion_result, (results or _50_())))
      end
      if ("function" == type(client.get("completions"))) then
        return client.call("completions", assoc_context({cb = cb_wrap, prefix = prefix}))
      else
        return cb_wrap()
      end
    end
    v_25_auto = completions0
    _1_["completions"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["completions"] = v_23_auto
  completions = v_23_auto
end
local completions_promise
do
  local v_23_auto
  do
    local v_25_auto
    local function completions_promise0(prefix)
      local p = promise.new()
      completions(prefix, promise["deliver-fn"](p))
      return p
    end
    v_25_auto = completions_promise0
    _1_["completions-promise"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["completions-promise"] = v_23_auto
  completions_promise = v_23_auto
end
local completions_sync
do
  local v_23_auto
  do
    local v_25_auto
    local function completions_sync0(prefix)
      local p = completions_promise(prefix)
      promise.await(p)
      return promise.close(p)
    end
    v_25_auto = completions_sync0
    _1_["completions-sync"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["completions-sync"] = v_23_auto
  completions_sync = v_23_auto
end
return nil