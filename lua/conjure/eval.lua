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
local function _2_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", buffer = "conjure.buffer", client = "conjure.client", config = "conjure.config", editor = "conjure.editor", extract = "conjure.extract", fs = "conjure.fs", log = "conjure.log", nvim = "conjure.aniseed.nvim", promise = "conjure.promise", text = "conjure.text", uuid = "conjure.uuid"}}
  return {require("conjure.aniseed.core"), require("conjure.buffer"), require("conjure.client"), require("conjure.config"), require("conjure.editor"), require("conjure.extract"), require("conjure.fs"), require("conjure.log"), require("conjure.aniseed.nvim"), require("conjure.promise"), require("conjure.text"), require("conjure.uuid")}
end
local _1_ = _2_(...)
local a = _1_[1]
local promise = _1_[10]
local text = _1_[11]
local uuid = _1_[12]
local buffer = _1_[2]
local client = _1_[3]
local config = _1_[4]
local editor = _1_[5]
local extract = _1_[6]
local fs = _1_[7]
local log = _1_[8]
local nvim = _1_[9]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local preview = nil
do
  local v_0_ = nil
  local function preview0(opts)
    local sample_limit = editor["percent-width"](config["get-in"]({"preview", "sample_limit"}))
    local function _3_()
      if (("file" == opts.origin) or ("buf" == opts.origin)) then
        return text["right-sample"](opts["file-path"], sample_limit)
      else
        return text["left-sample"](opts.code, sample_limit)
      end
    end
    return (client.get("comment-prefix") .. opts.action .. " (" .. opts.origin .. "): " .. _3_())
  end
  v_0_ = preview0
  _0_0["aniseed/locals"]["preview"] = v_0_
  preview = v_0_
end
local display_request = nil
do
  local v_0_ = nil
  local function display_request0(opts)
    return log.append({opts.preview}, a.merge(opts, {["break?"] = true}))
  end
  v_0_ = display_request0
  _0_0["aniseed/locals"]["display-request"] = v_0_
  display_request = v_0_
end
local with_last_result_hook = nil
do
  local v_0_ = nil
  local function with_last_result_hook0(opts)
    local function _3_(f)
      local function _4_(result)
        nvim.fn.setreg(config["get-in"]({"eval", "result_register"}), result)
        if f then
          return f(result)
        end
      end
      return _4_
    end
    return a.update(opts, "on-result", _3_)
  end
  v_0_ = with_last_result_hook0
  _0_0["aniseed/locals"]["with-last-result-hook"] = v_0_
  with_last_result_hook = v_0_
end
local file = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function file0()
      local opts = {["file-path"] = fs["resolve-relative"](extract["file-path"]()), action = "eval", origin = "file"}
      opts.preview = preview(opts)
      display_request(opts)
      return client.call("eval-file", with_last_result_hook(opts))
    end
    v_0_0 = file0
    _0_0["file"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["file"] = v_0_
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
  _0_0["aniseed/locals"]["assoc-context"] = v_0_
  assoc_context = v_0_
end
local client_exec_fn = nil
do
  local v_0_ = nil
  local function client_exec_fn0(action, f_name, base_opts)
    local function _3_(opts)
      local opts0 = a.merge(opts, base_opts, {["file-path"] = extract["file-path"](), action = action})
      assoc_context(opts0)
      opts0.preview = preview(opts0)
      if not opts0["passive?"] then
        display_request(opts0)
      end
      return client.call(f_name, opts0)
    end
    return _3_
  end
  v_0_ = client_exec_fn0
  _0_0["aniseed/locals"]["client-exec-fn"] = v_0_
  client_exec_fn = v_0_
end
local eval_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_str0(opts)
      local function _3_()
        if opts["passive?"] then
          return opts
        else
          return with_last_result_hook(opts)
        end
      end
      client_exec_fn("eval", "eval-str")(_3_())
      return nil
    end
    v_0_0 = eval_str0
    _0_0["eval-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval-str"] = v_0_
  eval_str = v_0_
end
local doc_str = nil
do
  local v_0_ = client_exec_fn("doc", "doc-str")
  _0_0["aniseed/locals"]["doc-str"] = v_0_
  doc_str = v_0_
end
local def_str = nil
do
  local v_0_ = client_exec_fn("def", "def-str", {["suppress-hud?"] = true})
  _0_0["aniseed/locals"]["def-str"] = v_0_
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
        local _3_ = form
        local content = _3_["content"]
        local range = _3_["range"]
        eval_str(a.merge({code = content, origin = "current-form", range = range}, extra_opts))
        return form
      end
    end
    v_0_0 = current_form0
    _0_0["current-form"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["current-form"] = v_0_
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
        local _3_ = form
        local content = _3_["content"]
        local range = _3_["range"]
        local function _4_(result)
          buffer["replace-range"](buf, range, result)
          return editor["go-to"](win, a["get-in"](range, {"start", 1}), a.inc(a["get-in"](range, {"start", 2})))
        end
        eval_str({["on-result"] = _4_, ["suppress-hud?"] = true, code = content, origin = "replace-form", range = range})
        return form
      end
    end
    v_0_0 = replace_form0
    _0_0["replace-form"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["replace-form"] = v_0_
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
        local _3_ = form
        local content = _3_["content"]
        local range = _3_["range"]
        return eval_str({code = content, origin = "root-form", range = range})
      end
    end
    v_0_0 = root_form0
    _0_0["root-form"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["root-form"] = v_0_
  root_form = v_0_
end
local marked_form = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function marked_form0()
      local mark = extract["prompt-char"]()
      local comment_prefix = client.get("comment-prefix")
      local ok_3f, err = nil, nil
      local function _3_()
        return editor["go-to-mark"](mark)
      end
      ok_3f, err = pcall(_3_)
      if ok_3f then
        current_form({origin = ("marked-form [" .. mark .. "]")})
        return editor["go-back"]()
      else
        return log.append({(comment_prefix .. "Couldn't eval form at mark: " .. mark), (comment_prefix .. err)}, {["break?"] = true})
      end
    end
    v_0_0 = marked_form0
    _0_0["marked-form"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["marked-form"] = v_0_
  marked_form = v_0_
end
local word = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function word0()
      local _3_ = extract.word()
      local content = _3_["content"]
      local range = _3_["range"]
      if not a["empty?"](content) then
        return eval_str({code = content, origin = "word", range = range})
      end
    end
    v_0_0 = word0
    _0_0["word"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["word"] = v_0_
  word = v_0_
end
local doc_word = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function doc_word0()
      local _3_ = extract.word()
      local content = _3_["content"]
      local range = _3_["range"]
      if not a["empty?"](content) then
        return doc_str({code = content, origin = "word", range = range})
      end
    end
    v_0_0 = doc_word0
    _0_0["doc-word"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc-word"] = v_0_
  doc_word = v_0_
end
local def_word = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function def_word0()
      local _3_ = extract.word()
      local content = _3_["content"]
      local range = _3_["range"]
      if not a["empty?"](content) then
        return def_str({code = content, origin = "word", range = range})
      end
    end
    v_0_0 = def_word0
    _0_0["def-word"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["def-word"] = v_0_
  def_word = v_0_
end
local buf = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function buf0()
      local _3_ = extract.buf()
      local content = _3_["content"]
      local range = _3_["range"]
      return eval_str({code = content, origin = "buf", range = range})
    end
    v_0_0 = buf0
    _0_0["buf"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["buf"] = v_0_
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
  _0_0["aniseed/locals"]["command"] = v_0_
  command = v_0_
end
local range = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function range0(start, _end)
      local _3_ = extract.range(start, _end)
      local content = _3_["content"]
      local range1 = _3_["range"]
      return eval_str({code = content, origin = "range", range = range1})
    end
    v_0_0 = range0
    _0_0["range"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["range"] = v_0_
  range = v_0_
end
local selection = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function selection0(kind)
      local _3_ = extract.selection({["visual?"] = not kind, kind = (kind or nvim.fn.visualmode())})
      local content = _3_["content"]
      local range0 = _3_["range"]
      return eval_str({code = content, origin = "selection", range = range0})
    end
    v_0_0 = selection0
    _0_0["selection"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["selection"] = v_0_
  selection = v_0_
end
local completions = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function completions0(prefix, cb)
      local function cb_wrap(results)
        local function _4_()
          local _3_0 = config["get-in"]({"completion", "fallback"})
          if _3_0 then
            return nvim.call_function(_3_0, {0, prefix})
          else
            return _3_0
          end
        end
        return cb((results or _4_()))
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
  _0_0["aniseed/locals"]["completions"] = v_0_
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
  _0_0["aniseed/locals"]["completions-promise"] = v_0_
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
  _0_0["aniseed/locals"]["completions-sync"] = v_0_
  completions_sync = v_0_
end
return nil