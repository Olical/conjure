local _2afile_2a = "fnl/conjure/client/guile/nrepl.fnl"
local _2amodule_name_2a = "conjure.client.guile.nrepl"
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
local a, client, config, eval, mapping, nvim, str, text, ts, util = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.eval"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter"), autoload("conjure.util")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["eval"] = eval
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ts"] = ts
_2amodule_locals_2a["util"] = util
config.merge({client = {guile = {nrepl = {default_host = "localhost", port_files = {".nrepl-port"}}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {guile = {nrepl = {mapping = {disconnect = "cd", connect_port_file = "cf", interrupt = "ei"}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "guile", "nrepl"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local state
local function _2_()
  return {repl = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_2_))
do end (_2amodule_locals_2a)["state"] = state
local buf_suffix = ".scm"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
local context_pattern = "%(define%-module%s+(%([%g%s]-%))"
_2amodule_2a["context-pattern"] = context_pattern
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
_2amodule_2a["form-node?"] = form_node_3f
local comment_node_3f = ts["lisp-comment-node?"]
_2amodule_2a["comment-node?"] = comment_node_3f
local function symbol_node_3f(node)
  return string.find(node:type(), "kwd")
end
_2amodule_2a["symbol-node?"] = symbol_node_3f
local function context(header)
  local _3_ = header
  if (nil ~= _3_) then
    local _4_ = parse["strip-shebang"](_3_)
    if (nil ~= _4_) then
      local _5_ = parse["strip-meta"](_4_)
      if (nil ~= _5_) then
        local _6_ = parse["strip-comments"](_5_)
        if (nil ~= _6_) then
          local _7_ = string.match(_6_, "%(%s*ns%s+([^)]*)")
          if (nil ~= _7_) then
            local _8_ = str.split(_7_, "%s+")
            if (nil ~= _8_) then
              return a.first(_8_)
            else
              return _8_
            end
          else
            return _7_
          end
        else
          return _6_
        end
      else
        return _5_
      end
    else
      return _4_
    end
  else
    return _3_
  end
end
_2amodule_2a["context"] = context
local function eval_file(opts)
  return eval_file(opts)
end
_2amodule_2a["eval-file"] = eval_file
local function eval_str(opts)
  return eval_str(opts)
end
_2amodule_2a["eval-str"] = eval_str
local function doc_str(opts)
  return doc_str(opts)
end
_2amodule_2a["doc-str"] = doc_str
local function def_str(opts)
  return def_str(opts)
end
_2amodule_2a["def-str"] = def_str
local function connect(opts)
  return __fnl_global__connect_2dhost_2dport(opts)
end
_2amodule_2a["connect"] = connect
local function on_filetype()
  mapping.buf("GuileDisconnect", cfg({"mapping", "disconnect"}), util["wrap-require-fn-call"]("conjure.client.guile.nrepl", "disconnect"), {desc = "Disconnect from the current nREPL"})
  mapping.buf("GuileConnectPortFile", cfg({"mapping", "connect_port_file"}), util["wrap-require-fn-call"]("conjure.client.guile.nrepl", "connect-port-file"), {desc = "Connect to port specified in .nrepl-port"})
  return mapping.buf("GuileInterrupt", cfg({"mapping", "interrupt"}), util["wrap-require-fn-call"]("conjure.client.guile.nrepl", "interrupt"), {desc = "Interrupt the current evaluation"})
end
_2amodule_2a["on-filetype"] = on_filetype
local function on_load()
  return __fnl_global__connect_2dport_2dfile()
end
_2amodule_2a["on-load"] = on_load
local function on_exit()
  return disconnect()
end
_2amodule_2a["on-exit"] = on_exit
return _2amodule_2a