local _2afile_2a = "fnl/conjure/client/common-lisp/swank.fnl"
local _2amodule_name_2a = "conjure.client.common-lisp.swank"
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
local a, bridge, client, config, log, mapping, nvim, remote, str, text, ts, utils = autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.swank"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter"), autoload("conjure.client.common-lisp.utils")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["bridge"] = bridge
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["remote"] = remote
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ts"] = ts
_2amodule_locals_2a["utils"] = utils
local buf_suffix = ".lisp"
_2amodule_2a["buf-suffix"] = buf_suffix
local context_pattern = "%(%s*defpackage%s+(.-)[%s){]"
_2amodule_2a["context-pattern"] = context_pattern
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
_2amodule_2a["form-node?"] = form_node_3f
config.merge({client = {common_lisp = {swank = {connection = {default_host = "127.0.0.1", default_port = "4005"}, mapping = {connect = "cc", disconnect = "cd"}}}}})
local state
local function _1_()
  return {conn = nil, ["eval-id"] = 0}
end
state = ((_2amodule_2a).state or client["new-state"](_1_))
do end (_2amodule_locals_2a)["state"] = state
local function with_conn_or_warn(f, opts)
  local conn = state("conn")
  if conn then
    return f(conn)
  else
    return log.append("; No connection")
  end
end
_2amodule_locals_2a["with-conn-or-warn"] = with_conn_or_warn
local function connected_3f()
  if state("conn") then
    return true
  else
    return false
  end
end
_2amodule_locals_2a["connected?"] = connected_3f
local function display_conn_status(status)
  local function _4_(conn)
    return log.append({("; " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
  end
  return with_conn_or_warn(_4_)
end
_2amodule_locals_2a["display-conn-status"] = display_conn_status
local function disconnect()
  local function _5_(conn)
    conn.destroy()
    display_conn_status("disconnected")
    return a.assoc(state(), "conn", nil)
  end
  return with_conn_or_warn(_5_)
end
_2amodule_2a["disconnect"] = disconnect
local function eval_str(opts)
  __fnl_global__try_2densure_2dconn()
  if not a["empty?"](opts.code) then
    local _6_
    if not a["empty?"](opts.context) then
      _6_ = opts.context
    else
      _6_ = nil
    end
    local function _8_(msg)
      local stdout, result = utils["parse-result"](msg)
      utils["display-stdout"](stdout)
      if (nil ~= result) then
        if opts["on-result"] then
          opts["on-result"](result)
        else
        end
        if not opts["passive?"] then
          return log.append(text["split-lines"](result))
        else
          return nil
        end
      else
        return nil
      end
    end
    return send(opts.code, _6_, _8_)
  else
    return nil
  end
end
_2amodule_2a["eval-str"] = eval_str
local function send(msg, context, cb)
  local function _13_(conn)
    local eval_id = a.get(a.update(state(), "eval-id", a.inc), "eval-id")
    return remote.send(conn, str.join({"(:emacs-rex (swank:eval-and-grab-output \"", utils["escape-string"](msg), "\") \"", (context or ":common-lisp-user"), "\" t ", eval_id, ")"}), cb)
  end
  return with_conn_or_warn(_13_)
end
_2amodule_locals_2a["send"] = send
local function connect(opts)
  local opts0 = (opts or {})
  local host = (opts0.host or config["get-in"]({"client", "common_lisp", "swank", "connection", "default_host"}))
  local port = (opts0.port or config["get-in"]({"client", "common_lisp", "swank", "connection", "default_port"}))
  if state("conn") then
    disconnect()
  else
  end
  local function _15_(err)
    display_conn_status(err)
    return disconnect()
  end
  local function _16_()
    return display_conn_status("connected")
  end
  local function _17_(err)
    if err then
      return display_conn_status(err)
    else
      return disconnect()
    end
  end
  a.assoc(state(), "conn", remote.connect({host = host, port = port, ["on-failure"] = _15_, ["on-success"] = _16_, ["on-error"] = _17_}))
  local function _19_(_)
  end
  return send(":ok", _19_)
end
_2amodule_2a["connect"] = connect
local function try_ensure_conn()
  if not connected_3f() then
    return connect({["silent?"] = true})
  else
    return nil
  end
end
_2amodule_locals_2a["try-ensure-conn"] = try_ensure_conn
local function doc_str(opts)
  try_ensure_conn()
  local function _21_(_241)
    return ("(describe #'" .. _241 .. ")")
  end
  return eval_str(a.update(opts, "code", _21_))
end
_2amodule_2a["doc-str"] = doc_str
local function eval_file(opts)
  try_ensure_conn()
  return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
_2amodule_2a["eval-file"] = eval_file
local function on_filetype()
  mapping.buf("n", "CommonLispDisconnect", config["get-in"]({"client", "common_lisp", "swank", "mapping", "disconnect"}), "conjure.client.common-lisp.swank", "disconnect")
  return mapping.buf("n", "CommonLispConnect", config["get-in"]({"client", "common_lisp", "swank", "mapping", "connect"}), "conjure.client.common-lisp.swank", "connect")
end
_2amodule_2a["on-filetype"] = on_filetype
local function on_load()
  return connect({})
end
_2amodule_2a["on-load"] = on_load
local function on_exit()
  return disconnect()
end
_2amodule_2a["on-exit"] = on_exit
return _2amodule_2a