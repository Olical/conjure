local _0_0 = nil
do
  local name_0_ = "conjure.client.janet.netrepl"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", bridge = "conjure.bridge", config = "conjure.config", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", server = "conjure.client.janet.netrepl.server", text = "conjure.text", ui = "conjure.client.janet.netrepl.ui"}}
  return {require("conjure.aniseed.core"), require("conjure.bridge"), require("conjure.config"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.client.janet.netrepl.server"), require("conjure.text"), require("conjure.client.janet.netrepl.ui")}
end
local _2_ = _1_(...)
local a = _2_[1]
local bridge = _2_[2]
local config = _2_[3]
local mapping = _2_[4]
local nvim = _2_[5]
local server = _2_[6]
local text = _2_[7]
local ui = _2_[8]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local buf_suffix = nil
do
  local v_0_ = nil
  do
    local v_0_0 = ".janet"
    _0_0["buf-suffix"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local comment_prefix = nil
do
  local v_0_ = nil
  do
    local v_0_0 = "# "
    _0_0["comment-prefix"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
config.merge({client = {janet = {netrepl = {connection = {default_host = "127.0.0.1", default_port = "9365"}, mapping = {connect = "cc", disconnect = "cd"}}}}})
local eval_str = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_str0(opts)
      local function _3_(msg)
        local clean = text["trim-last-newline"](msg)
        if opts["on-result"] then
          opts["on-result"](text["strip-ansi-escape-sequences"](clean))
        end
        if not opts["passive?"] then
          return ui.display(text["split-lines"](clean))
        end
      end
      return server.send((opts.code .. "\n"), _3_)
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
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function doc_str0(opts)
      local function _3_(_241)
        return ("(doc " .. _241 .. ")")
      end
      return eval_str(a.update(opts, "code", _3_))
    end
    v_0_0 = doc_str0
    _0_0["doc-str"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_0_
  doc_str = v_0_
end
local eval_file = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function eval_file0(opts)
      return eval_str(a.assoc(opts, "code", ("(do (dofile \"" .. opts["file-path"] .. "\" :env (fiber/getenv (fiber/current))) nil)")))
    end
    v_0_0 = eval_file0
    _0_0["eval-file"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["eval-file"] = v_0_
  eval_file = v_0_
end
local on_filetype = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function on_filetype0()
      mapping.buf("n", config["get-in"]({"client", "janet", "netrepl", "mapping", "disconnect"}), "conjure.client.janet.netrepl.server", "disconnect")
      mapping.buf("n", config["get-in"]({"client", "janet", "netrepl", "mapping", "connect"}), "conjure.client.janet.netrepl.server", "connect")
      return nvim.ex.command_("-nargs=* -buffer ConjureConnect", bridge["viml->lua"]("conjure.client.janet.netrepl.server", "connect", {args = "<f-args>"}))
    end
    v_0_0 = on_filetype0
    _0_0["on-filetype"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_0_
  on_filetype = v_0_
end
local on_load = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function on_load0()
      nvim.ex.augroup("conjure_janet_netrepl_cleanup")
      nvim.ex.autocmd_()
      nvim.ex.autocmd("VimLeavePre *", bridge["viml->lua"]("conjure.client.janet.netrepl.server", "disconnect", {}))
      nvim.ex.augroup("END")
      return server.connect()
    end
    v_0_0 = on_load0
    _0_0["on-load"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["on-load"] = v_0_
  on_load = v_0_
end
return nil