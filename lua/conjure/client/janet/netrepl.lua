local _2afile_2a = "fnl/conjure/client/janet/netrepl.fnl"
local _2amodule_name_2a = "conjure.client.janet.netrepl"
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
local a, bridge, client, config, log, mapping, nvim, remote, text, ts = autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.netrepl"), autoload("conjure.text"), autoload("conjure.tree-sitter")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["bridge"] = bridge
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["remote"] = remote
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ts"] = ts
local buf_suffix = ".janet"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "# "
_2amodule_2a["comment-prefix"] = comment_prefix
local form_node_3f = ts["node-surrounded-by-form-pair-chars?"]
_2amodule_2a["form-node?"] = form_node_3f
local comment_node_3f = ts["lisp-comment-node?"]
_2amodule_2a["comment-node?"] = comment_node_3f
config.merge({client = {janet = {netrepl = {connection = {default_host = "127.0.0.1", default_port = "9365"}, mapping = {connect = "cc", disconnect = "cd"}}}}})
local state
local function _1_()
  return {conn = nil}
end
state = ((_2amodule_2a).state or client["new-state"](_1_))
do end (_2amodule_locals_2a)["state"] = state
local function with_conn_or_warn(f, opts)
  local conn = state("conn")
  if conn then
    return f(conn)
  else
    return log.append({"# No connection"})
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
    return log.append({("# " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
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
local function send(opts)
  local _let_6_ = opts
  local msg = _let_6_["msg"]
  local cb = _let_6_["cb"]
  local row = _let_6_["row"]
  local col = _let_6_["col"]
  local file_path = _let_6_["file-path"]
  local function _7_(conn)
    remote.send(conn, ("\255(parser/where (dyn :parser) " .. row .. " " .. col .. ")"))
    remote.send(conn, ("\254source \"" .. file_path .. "\""), nil, true)
    return remote.send(conn, msg, cb, true)
  end
  return with_conn_or_warn(_7_)
end
_2amodule_locals_2a["send"] = send
local function connect(opts)
  local opts0 = (opts or {})
  local host = (opts0.host or config["get-in"]({"client", "janet", "netrepl", "connection", "default_host"}))
  local port = (opts0.port or config["get-in"]({"client", "janet", "netrepl", "connection", "default_port"}))
  if state("conn") then
    disconnect()
  else
  end
  local function _9_(err)
    display_conn_status(err)
    return disconnect()
  end
  local function _10_()
    return display_conn_status("connected")
  end
  local function _11_(err)
    if err then
      return display_conn_status(err)
    else
      return disconnect()
    end
  end
  return a.assoc(state(), "conn", remote.connect({host = host, port = port, ["on-failure"] = _9_, ["on-success"] = _10_, ["on-error"] = _11_}))
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
local function eval_str(opts)
  try_ensure_conn()
  local function _14_(msg)
    local clean = text["trim-last-newline"](msg)
    if opts["on-result"] then
      opts["on-result"](text["strip-ansi-escape-sequences"](clean))
    else
    end
    if not opts["passive?"] then
      return log.append(text["split-lines"](clean))
    else
      return nil
    end
  end
  return send({msg = (opts.code .. "\n"), cb = _14_, row = a["get-in"](opts.range, {"start", 1}, 1), col = a["get-in"](opts.range, {"start", 2}, 1), ["file-path"] = opts["file-path"]})
end
_2amodule_2a["eval-str"] = eval_str
local function doc_str(opts)
  try_ensure_conn()
  local function _17_(_241)
    return ("(doc " .. _241 .. ")")
  end
  return eval_str(a.update(opts, "code", _17_))
end
_2amodule_2a["doc-str"] = doc_str
local function eval_file(opts)
  try_ensure_conn()
  return eval_str(a.assoc(opts, "code", ("(do (dofile \"" .. opts["file-path"] .. "\" :env (fiber/getenv (fiber/current))) nil)")))
end
_2amodule_2a["eval-file"] = eval_file
local function on_filetype()
  mapping.buf("JanetDisconnect", config["get-in"]({"client", "janet", "netrepl", "mapping", "disconnect"}), disconnect, {desc = "Disconnect from the REPL"})
  local function _18_()
    return connect()
  end
  return mapping.buf("JanetConnect", config["get-in"]({"client", "janet", "netrepl", "mapping", "connect"}), _18_, {desc = "Connect to a REPL"})
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