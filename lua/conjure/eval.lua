local _0_0 = nil
do
  local name_23_0_ = "conjure.eval"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", editor = "conjure.editor", extract = "conjure.extract", log = "conjure.log", nvim = "conjure.aniseed.nvim", promise = "conjure.promise", text = "conjure.text", uuid = "conjure.uuid"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.editor"), require("conjure.extract"), require("conjure.log"), require("conjure.aniseed.nvim"), require("conjure.promise"), require("conjure.text"), require("conjure.uuid")}
end
local _2_ = _1_(...)
local a = _2_[1]
local client = _2_[2]
local config = _2_[3]
local editor = _2_[4]
local extract = _2_[5]
local log = _2_[6]
local nvim = _2_[7]
local promise = _2_[8]
local text = _2_[9]
local uuid = _2_[10]
do local _ = ({nil, _0_0, nil})[2] end
local preview = nil
do
  local v_23_0_ = nil
  local function preview0(opts)
    local sample_limit = editor["percent-width"](config.preview["sample-limit"])
    local function _3_()
      if (("file" == opts.origin) or ("buf" == opts.origin)) then
        return text["right-sample"](opts["file-path"], sample_limit)
      else
        return text["left-sample"](opts.code, sample_limit)
      end
    end
    return (client.get("comment-prefix") .. opts.action .. " (" .. opts.origin .. "): " .. _3_())
  end
  v_23_0_ = preview0
  _0_0["aniseed/locals"]["preview"] = v_23_0_
  preview = v_23_0_
end
local display_request = nil
do
  local v_23_0_ = nil
  local function display_request0(opts)
    return log.append({opts.preview}, {["break?"] = true})
  end
  v_23_0_ = display_request0
  _0_0["aniseed/locals"]["display-request"] = v_23_0_
  display_request = v_23_0_
end
local file = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function file0()
      local opts = {["file-path"] = extract["file-path"](), action = "eval", origin = "file"}
      opts.preview = preview(opts)
      display_request(opts)
      return client.call("eval-file", opts)
    end
    v_23_0_0 = file0
    _0_0["file"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["file"] = v_23_0_
  file = v_23_0_
end
local assoc_context = nil
do
  local v_23_0_ = nil
  local function assoc_context0(opts)
    opts.context = (nvim.b.conjure_context or extract.context())
    return opts
  end
  v_23_0_ = assoc_context0
  _0_0["aniseed/locals"]["assoc-context"] = v_23_0_
  assoc_context = v_23_0_
end
local client_exec_fn = nil
do
  local v_23_0_ = nil
  local function client_exec_fn0(action, f_name)
    local function _3_(opts)
      opts.action = action
      assoc_context(opts)
      opts["file-path"] = extract["file-path"]()
      opts.preview = preview(opts)
      display_request(opts)
      return client.call(f_name, opts)
    end
    return _3_
  end
  v_23_0_ = client_exec_fn0
  _0_0["aniseed/locals"]["client-exec-fn"] = v_23_0_
  client_exec_fn = v_23_0_
end
local eval_str = nil
do
  local v_23_0_ = client_exec_fn("eval", "eval-str")
  _0_0["aniseed/locals"]["eval-str"] = v_23_0_
  eval_str = v_23_0_
end
local doc_str = nil
do
  local v_23_0_ = client_exec_fn("doc", "doc-str")
  _0_0["aniseed/locals"]["doc-str"] = v_23_0_
  doc_str = v_23_0_
end
local def_str = nil
do
  local v_23_0_ = client_exec_fn("def", "def-str")
  _0_0["aniseed/locals"]["def-str"] = v_23_0_
  def_str = v_23_0_
end
local current_form = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function current_form0(extra_opts)
      local form = extract.form({})
      if form then
        local _3_ = form
        local range = _3_["range"]
        local content = _3_["content"]
        return eval_str(a.merge({code = content, origin = "current-form", range = range}, extra_opts))
      end
    end
    v_23_0_0 = current_form0
    _0_0["current-form"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["current-form"] = v_23_0_
  current_form = v_23_0_
end
local root_form = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function root_form0()
      local form = extract.form({["root?"] = true})
      if form then
        local _3_ = form
        local range = _3_["range"]
        local content = _3_["content"]
        return eval_str({code = content, origin = "root-form", range = range})
      end
    end
    v_23_0_0 = root_form0
    _0_0["root-form"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["root-form"] = v_23_0_
  root_form = v_23_0_
end
local marked_form = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
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
    v_23_0_0 = marked_form0
    _0_0["marked-form"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["marked-form"] = v_23_0_
  marked_form = v_23_0_
end
local word = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function word0()
      local _3_ = extract.word()
      local range = _3_["range"]
      local content = _3_["content"]
      if not a["empty?"](content) then
        return eval_str({code = content, origin = "word", range = range})
      end
    end
    v_23_0_0 = word0
    _0_0["word"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["word"] = v_23_0_
  word = v_23_0_
end
local doc_word = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function doc_word0()
      local _3_ = extract.word()
      local range = _3_["range"]
      local content = _3_["content"]
      if not a["empty?"](content) then
        return doc_str({code = content, origin = "word", range = range})
      end
    end
    v_23_0_0 = doc_word0
    _0_0["doc-word"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["doc-word"] = v_23_0_
  doc_word = v_23_0_
end
local def_word = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function def_word0()
      local _3_ = extract.word()
      local range = _3_["range"]
      local content = _3_["content"]
      if not a["empty?"](content) then
        return def_str({code = content, origin = "word", range = range})
      end
    end
    v_23_0_0 = def_word0
    _0_0["def-word"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["def-word"] = v_23_0_
  def_word = v_23_0_
end
local buf = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function buf0()
      local _3_ = extract.buf()
      local range = _3_["range"]
      local content = _3_["content"]
      return eval_str({code = content, origin = "buf", range = range})
    end
    v_23_0_0 = buf0
    _0_0["buf"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["buf"] = v_23_0_
  buf = v_23_0_
end
local command = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function command0(code)
      return eval_str({code = code, origin = "command"})
    end
    v_23_0_0 = command0
    _0_0["command"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["command"] = v_23_0_
  command = v_23_0_
end
local range = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function range0(start, _end)
      local _3_ = extract.range(start, _end)
      local range1 = _3_["range"]
      local content = _3_["content"]
      return eval_str({code = content, origin = "range", range = range1})
    end
    v_23_0_0 = range0
    _0_0["range"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["range"] = v_23_0_
  range = v_23_0_
end
local selection = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function selection0(kind)
      local _3_ = extract.selection({["visual?"] = not kind, kind = (kind or nvim.fn.visualmode())})
      local range0 = _3_["range"]
      local content = _3_["content"]
      return eval_str({code = content, origin = "selection", range = range0})
    end
    v_23_0_0 = selection0
    _0_0["selection"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["selection"] = v_23_0_
  selection = v_23_0_
end
local completions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function completions0(prefix, cb)
      if ("function" == type(client.get("completions"))) then
        return client.call("completions", assoc_context({cb = cb, prefix = prefix}))
      else
        return cb(nil)
      end
    end
    v_23_0_0 = completions0
    _0_0["completions"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["completions"] = v_23_0_
  completions = v_23_0_
end
local completions_promise = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function completions_promise0(prefix)
      local p = promise.new()
      completions(prefix, promise["deliver-fn"](p))
      return p
    end
    v_23_0_0 = completions_promise0
    _0_0["completions-promise"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["completions-promise"] = v_23_0_
  completions_promise = v_23_0_
end
local completions_sync = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function completions_sync0(prefix)
      local p = completions_promise(prefix)
      promise.await(p)
      return promise.close(p)
    end
    v_23_0_0 = completions_sync0
    _0_0["completions-sync"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["completions-sync"] = v_23_0_
  completions_sync = v_23_0_
end
return nil