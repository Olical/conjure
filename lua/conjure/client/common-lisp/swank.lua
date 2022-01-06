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
local a, bridge, client, config, log, mapping, nvim, remote, text = autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.swank"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["bridge"] = bridge
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["remote"] = remote
_2amodule_locals_2a["text"] = text
local buf_suffix = ".lisp"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
config.merge({client = {["common-lisp"] = {swank = {connection = {default_host = "127.0.0.1", default_port = "4005"}, mapping = {connect = "cc", disconnect = "cd"}}}}})
local state
local function _1_()
  return {conn = nil}
end
state = (state or client["new-state"](_1_))
do end (_2amodule_locals_2a)["state"] = state
local function with_conn_or_warn(f, opts)
  local conn = state("conn")
  if conn then
    return f(conn)
  else
    return log.append(("; No connection")())
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
local function escape_string(_in)
  local function replace(_in0, pat, rep)
    local s, c = string.gsub(_in0, pat, rep)
    return s
  end
  return replace(replace(_in, "\\", "\\\\"), "\"", "\\\"")
end
_2amodule_locals_2a["escape-string"] = escape_string
local function send(msg, cb)
  local function _6_(conn)
    return remote.send(conn, ("(:emacs-rex (swank:eval-and-grab-output \"" .. escape_string(msg) .. "\") \"cl-user\" t 1)"), cb)
  end
  return with_conn_or_warn(_6_)
end
_2amodule_locals_2a["send"] = send
local function connect(opts)
  local opts0 = (opts or {})
  local host = (opts0.host or config["get-in"]({"client", "common-lisp", "swank", "connection", "default_host"}))
  local port = (opts0.port or config["get-in"]({"client", "common-lisp", "swank", "connection", "default_port"}))
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
  return a.assoc(state(), "conn", remote.connect({host = host, port = port, ["on-failure"] = _8_, ["on-success"] = _9_, ["on-error"] = _10_}))
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
  local function _13_(msg)
    return log.append({"callback result ", msg})
  end
  return send(opts.code, _13_)
end
_2amodule_2a["eval-str"] = eval_str
local function on_filetype()
  mapping.buf("n", "CommonLispDisconnect", config["get-in"]({"client", "common-lisp", "swank", "mapping", "disconnect"}), "conjure.client.common-lisp", "disconnect")
  return mapping.buf("n", "CommonLispConnect", config["get-in"]({"client", "common-lisp", "swank", "mapping", "connect"}), "conjure.client.common-lisp", "connect")
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