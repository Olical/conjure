local _2afile_2a = "fnl/conjure/client/common-lisp/slynk.fnl"
local _2amodule_name_2a = "conjure.client.common-lisp.slynk"
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
local a, bridge, client, config, log, mapping, nvim, parser, remote, str, text, ts = autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.client.common-lisp.parser"), autoload("conjure.remote.slynk"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.tree-sitter")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["bridge"] = bridge
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["parser"] = parser
_2amodule_locals_2a["remote"] = remote
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ts"] = ts
local buf_suffix = ".lisp"
_2amodule_2a["buf-suffix"] = buf_suffix
local context_pattern = "%(%s*defpackage%s+(.-)[%s){]"
_2amodule_2a["context-pattern"] = context_pattern
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
_2amodule_2a["form-node?"] = form_node_3f
config.merge({client = {common_lisp = {slynk = {connection = {default_host = "127.0.0.1", default_port = "4005"}, mapping = {connect = "cc", disconnect = "cd"}}}}})
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
    return log.append({("; Slynk " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
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
local function send(msg, context, cb)
  local function _6_(conn)
    local eval_id = a.get(a.update(state(), "eval-id", a.inc), "eval-id")
    return remote.send(conn, str.join({"(:emacs-rex (slynk:eval-and-grab-output \"", parser["escape-string"](msg), "\") \"", (context or ":common-lisp-user"), "\" t ", eval_id, ")"}), cb)
  end
  return with_conn_or_warn(_6_)
end
_2amodule_locals_2a["send"] = send
local function connect(opts)
  local opts0 = (opts or {})
  local host = (opts0.host or config["get-in"]({"client", "common_lisp", "slynk", "connection", "default_host"}))
  local port = (opts0.port or config["get-in"]({"client", "common_lisp", "slynk", "connection", "default_port"}))
  if state("conn") then
    disconnect()
  else
  end
  local function _8_(err)
    display_conn_status(err)
    return disconnect()
  end
  local function _9_()
    return display_conn_status("connected")
  end
  local function _10_(err)
    if err then
      return display_conn_status(err)
    else
      return disconnect()
    end
  end
  a.assoc(state(), "conn", remote.connect({host = host, port = port, ["on-failure"] = _8_, ["on-success"] = _9_, ["on-error"] = _10_}))
  local function _12_(_)
  end
  return send(":ok", _12_)
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
local function display_stdout(msg)
  if ((nil ~= msg) and ("" ~= msg)) then
    return log.append(text["prefixed-lines"](msg, comment_prefix))
  else
    return nil
  end
end
_2amodule_locals_2a["display-stdout"] = display_stdout
local function eval_str(opts)
  try_ensure_conn()
  if not a["empty?"](opts.code) then
    local _15_
    if not a["empty?"](opts.context) then
      _15_ = opts.context
    else
      _15_ = nil
    end
    local function _17_(msg)
      local stdout, result = parser["parse-result"](msg)
      display_stdout(stdout)
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
    return send(opts.code, _15_, _17_)
  else
    return nil
  end
end
_2amodule_2a["eval-str"] = eval_str
local function doc_str(opts)
  try_ensure_conn()
  local function _22_(_241)
    return ("(describe #'" .. _241 .. ")")
  end
  return eval_str(a.update(opts, "code", _22_))
end
_2amodule_2a["doc-str"] = doc_str
local function eval_file(opts)
  try_ensure_conn()
  return eval_str(a.assoc(opts, "code", ("(load \"" .. opts["file-path"] .. "\")")))
end
_2amodule_2a["eval-file"] = eval_file
local function on_filetype()
  mapping.buf("n", "CommonLispDisconnect", config["get-in"]({"client", "common_lisp", "slynk", "mapping", "disconnect"}), "conjure.client.common-lisp.slynk", "disconnect")
  return mapping.buf("n", "CommonLispConnect", config["get-in"]({"client", "common_lisp", "slynk", "mapping", "connect"}), "conjure.client.common-lisp.slynk", "connect")
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