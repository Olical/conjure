local _0_0 = nil
do
  local name_0_ = "conjure.eval"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.core"), require("conjure.buffer"), require("conjure.client"), require("conjure.config"), require("conjure.editor"), require("conjure.event"), require("conjure.extract"), require("conjure.fs"), require("conjure.inline"), require("conjure.log"), require("conjure.aniseed.nvim"), require("conjure.promise"), require("conjure.text"), require("conjure.uuid")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", buffer = "conjure.buffer", client = "conjure.client", config = "conjure.config", editor = "conjure.editor", event = "conjure.event", extract = "conjure.extract", fs = "conjure.fs", inline = "conjure.inline", log = "conjure.log", nvim = "conjure.aniseed.nvim", promise = "conjure.promise", text = "conjure.text", uuid = "conjure.uuid"}}
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
local uuid = _local_0_[14]
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
local preview = nil
do
  local v_0_ = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["preview"] = v_0_
  preview = v_0_
end
local display_request = nil
do
  local v_0_ = nil
  local function display_request0(opts)
    return log.append({opts.preview}, a.merge(opts, {["break?"] = true}))
  end
  v_0_ = display_request0
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["display-request"] = v_0_
  display_request = v_0_
end
local with_last_result_hook = nil
do
  local v_0_ = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["with-last-result-hook"] = v_0_
  with_last_result_hook = v_0_
end
local file = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["file"] = v_0_
  file = v_0_
end
local assoc_context = nil
do
  local v_0_ = nil
  local function assoc_context0(opts)
    opts.context = (nvim.b["conjure#context"] or extract.context())
    return opts
  end
  v_0_ = assoc_context0
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["assoc-context"] = v_0_
  assoc_context = v_0_
end
local client_exec_fn = nil
do
  local v_0_ = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["client-exec-fn"] = v_0_
  client_exec_fn = v_0_
end
local eval_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_str0(opts)
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["eval-str"] = v_0_
  eval_str = v_0_
end
local wrap_emit = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["wrap-emit"] = v_0_
  wrap_emit = v_0_
end
local doc_str = nil
do
  local v_0_ = wrap_emit("doc", client_exec_fn("doc", "doc-str"))
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["doc-str"] = v_0_
  doc_str = v_0_
end
local def_str = nil
do
  local v_0_ = wrap_emit("def", client_exec_fn("def", "def-str", {["suppress-hud?"] = true}))
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["def-str"] = v_0_
  def_str = v_0_
end
local current_form = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["current-form"] = v_0_
  current_form = v_0_
end
local replace_form = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["replace-form"] = v_0_
  replace_form = v_0_
end
local root_form = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["root-form"] = v_0_
  root_form = v_0_
end
local marked_form = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
        return editor["go-back"]()
      else
        return log.append({(comment_prefix .. "Couldn't eval form at mark: " .. mark0), (comment_prefix .. err)}, {["break?"] = true})
      end
    end
    v_0_0 = marked_form0
    _0_0["marked-form"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["marked-form"] = v_0_
  marked_form = v_0_
end
local comment_form = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function comment_form0(mark)
      local buf = nvim.win_get_buf(0)
      local form = extract.form({})
      local comment_prefix = client.get("comment-prefix")
      if form then
        local _let_0_ = form
        local content = _let_0_["content"]
        local range = _let_0_["range"]
        local function _2_(result)
          return buffer["append-prefixed-line"](buf, range["end"], comment_prefix, result)
        end
        eval_str({["on-result"] = _2_, ["suppress-hud?"] = true, code = content, origin = "comment-form", range = range})
        return form
      end
    end
    v_0_0 = comment_form0
    _0_0["comment-form"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["comment-form"] = v_0_
  comment_form = v_0_
end
local word = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["word"] = v_0_
  word = v_0_
end
local doc_word = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["doc-word"] = v_0_
  doc_word = v_0_
end
local def_word = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["def-word"] = v_0_
  def_word = v_0_
end
local buf = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["buf"] = v_0_
  buf = v_0_
end
local command = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function command0(code)
      return eval_str({code = code, origin = "command"})
    end
    v_0_0 = command0
    _0_0["command"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["command"] = v_0_
  command = v_0_
end
local range = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["range"] = v_0_
  range = v_0_
end
local selection = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["selection"] = v_0_
  selection = v_0_
end
local wrap_completion_result = nil
do
  local v_0_ = nil
  local function wrap_completion_result0(result)
    if a["string?"](result) then
      return {word = result}
    else
      return result
    end
  end
  v_0_ = wrap_completion_result0
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["wrap-completion-result"] = v_0_
  wrap_completion_result = v_0_
end
local completions = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["completions"] = v_0_
  completions = v_0_
end
local completions_promise = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function completions_promise0(prefix)
      local p = promise.new()
      completions(prefix, promise["deliver-fn"](p))
      return p
    end
    v_0_0 = completions_promise0
    _0_0["completions-promise"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["completions-promise"] = v_0_
  completions_promise = v_0_
end
local completions_sync = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function completions_sync0(prefix)
      local p = completions_promise(prefix)
      promise.await(p)
      return promise.close(p)
    end
    v_0_0 = completions_sync0
    _0_0["completions-sync"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = _0_0["aniseed/locals"]
  t_0_["completions-sync"] = v_0_
  completions_sync = v_0_
end
return nil