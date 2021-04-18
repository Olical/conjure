local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.janet.netrepl"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.bridge"), require("conjure.client"), require("conjure.config"), require("conjure.log"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.remote.netrepl"), require("conjure.text")}
local a = _local_0_[1]
local bridge = _local_0_[2]
local client = _local_0_[3]
local config = _local_0_[4]
local log = _local_0_[5]
local mapping = _local_0_[6]
local nvim = _local_0_[7]
local remote = _local_0_[8]
local text = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.janet.netrepl"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local buf_suffix
do
  local v_0_ = ".janet"
  _0_0["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local comment_prefix
do
  local v_0_ = "# "
  _0_0["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
config.merge({client = {janet = {netrepl = {connection = {default_host = "127.0.0.1", default_port = "9365"}, mapping = {connect = "cc", disconnect = "cd"}}}}})
local state
local function _1_()
  return {conn = nil}
end
state = client["new-state"](_1_)
local function with_conn_or_warn(f, opts)
  local conn = state("conn")
  if conn then
    return f(conn)
  else
    return log.append({"# No connection"})
  end
end
local function connected_3f()
  if state("conn") then
    return true
  else
    return false
  end
end
local function display_conn_status(status)
  local function _2_(conn)
    return log.append({("# " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
  end
  return with_conn_or_warn(_2_)
end
local disconnect
do
  local v_0_
  local function disconnect0()
    local function _2_(conn)
      conn.destroy()
      display_conn_status("disconnected")
      return a.assoc(state(), "conn", nil)
    end
    return with_conn_or_warn(_2_)
  end
  v_0_ = disconnect0
  _0_0["disconnect"] = v_0_
  disconnect = v_0_
end
local function send(msg, cb)
  local function _2_(conn)
    return remote.send(conn, msg, cb)
  end
  return with_conn_or_warn(_2_)
end
local connect
do
  local v_0_
  local function connect0(opts)
    local opts0 = (opts or {})
    local host = (opts0.host or config["get-in"]({"client", "janet", "netrepl", "connection", "default_host"}))
    local port = (opts0.port or config["get-in"]({"client", "janet", "netrepl", "connection", "default_port"}))
    if state("conn") then
      disconnect()
    end
    local function _3_(err)
      if err then
        return display_conn_status(err)
      else
        return disconnect()
      end
    end
    local function _4_(err)
      display_conn_status(err)
      return disconnect()
    end
    local function _5_()
      return display_conn_status("connected")
    end
    return a.assoc(state(), "conn", remote.connect({["on-error"] = _3_, ["on-failure"] = _4_, ["on-success"] = _5_, host = host, port = port}))
  end
  v_0_ = connect0
  _0_0["connect"] = v_0_
  connect = v_0_
end
local function try_ensure_conn()
  if not connected_3f() then
    return connect({["silent?"] = true})
  end
end
local eval_str
do
  local v_0_
  local function eval_str0(opts)
    try_ensure_conn()
    local function _2_(msg)
      local clean = text["trim-last-newline"](msg)
      if opts["on-result"] then
        opts["on-result"](text["strip-ansi-escape-sequences"](clean))
      end
      if not opts["passive?"] then
        return log.append(text["split-lines"](clean))
      end
    end
    return send((opts.code .. "\n"), _2_)
  end
  v_0_ = eval_str0
  _0_0["eval-str"] = v_0_
  eval_str = v_0_
end
local doc_str
do
  local v_0_
  local function doc_str0(opts)
    try_ensure_conn()
    local function _2_(_241)
      return ("(doc " .. _241 .. ")")
    end
    return eval_str(a.update(opts, "code", _2_))
  end
  v_0_ = doc_str0
  _0_0["doc-str"] = v_0_
  doc_str = v_0_
end
local eval_file
do
  local v_0_
  local function eval_file0(opts)
    try_ensure_conn()
    return eval_str(a.assoc(opts, "code", ("(do (dofile \"" .. opts["file-path"] .. "\" :env (fiber/getenv (fiber/current))) nil)")))
  end
  v_0_ = eval_file0
  _0_0["eval-file"] = v_0_
  eval_file = v_0_
end
local on_filetype
do
  local v_0_
  local function on_filetype0()
    mapping.buf("n", "JanetDisconnect", config["get-in"]({"client", "janet", "netrepl", "mapping", "disconnect"}), "conjure.client.janet.netrepl", "disconnect")
    return mapping.buf("n", "JanetConnect", config["get-in"]({"client", "janet", "netrepl", "mapping", "connect"}), "conjure.client.janet.netrepl", "connect")
  end
  v_0_ = on_filetype0
  _0_0["on-filetype"] = v_0_
  on_filetype = v_0_
end
local on_load
do
  local v_0_
  local function on_load0()
    return connect({})
  end
  v_0_ = on_load0
  _0_0["on-load"] = v_0_
  on_load = v_0_
end
local on_exit
do
  local v_0_
  local function on_exit0()
    return disconnect()
  end
  v_0_ = on_exit0
  _0_0["on-exit"] = v_0_
  on_exit = v_0_
end
return nil