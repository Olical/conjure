local _2afile_2a = "fnl/conjure/client/janet/netrepl.fnl"
local _1_
do
  local name_4_auto = "conjure.client.janet.netrepl"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.netrepl"), autoload("conjure.text")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", bridge = "conjure.bridge", client = "conjure.client", config = "conjure.config", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", remote = "conjure.remote.netrepl", text = "conjure.text"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local bridge = _local_4_[2]
local client = _local_4_[3]
local config = _local_4_[4]
local log = _local_4_[5]
local mapping = _local_4_[6]
local nvim = _local_4_[7]
local remote = _local_4_[8]
local text = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client.janet.netrepl"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local buf_suffix
do
  local v_23_auto
  do
    local v_25_auto = ".janet"
    _1_["buf-suffix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf-suffix"] = v_23_auto
  buf_suffix = v_23_auto
end
local comment_prefix
do
  local v_23_auto
  do
    local v_25_auto = "# "
    _1_["comment-prefix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["comment-prefix"] = v_23_auto
  comment_prefix = v_23_auto
end
config.merge({client = {janet = {netrepl = {connection = {default_host = "127.0.0.1", default_port = "9365"}, mapping = {connect = "cc", disconnect = "cd"}}}}})
local state
do
  local v_23_auto
  local function _8_()
    return {conn = nil}
  end
  v_23_auto = ((_1_)["aniseed/locals"].state or client["new-state"](_8_))
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state"] = v_23_auto
  state = v_23_auto
end
local with_conn_or_warn
do
  local v_23_auto
  local function with_conn_or_warn0(f, opts)
    local conn = state("conn")
    if conn then
      return f(conn)
    else
      return log.append({"# No connection"})
    end
  end
  v_23_auto = with_conn_or_warn0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-conn-or-warn"] = v_23_auto
  with_conn_or_warn = v_23_auto
end
local connected_3f
do
  local v_23_auto
  local function connected_3f0()
    if state("conn") then
      return true
    else
      return false
    end
  end
  v_23_auto = connected_3f0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connected?"] = v_23_auto
  connected_3f = v_23_auto
end
local display_conn_status
do
  local v_23_auto
  local function display_conn_status0(status)
    local function _11_(conn)
      return log.append({("# " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
    end
    return with_conn_or_warn(_11_)
  end
  v_23_auto = display_conn_status0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-conn-status"] = v_23_auto
  display_conn_status = v_23_auto
end
local disconnect
do
  local v_23_auto
  do
    local v_25_auto
    local function disconnect0()
      local function _12_(conn)
        conn.destroy()
        display_conn_status("disconnected")
        return a.assoc(state(), "conn", nil)
      end
      return with_conn_or_warn(_12_)
    end
    v_25_auto = disconnect0
    _1_["disconnect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["disconnect"] = v_23_auto
  disconnect = v_23_auto
end
local send
do
  local v_23_auto
  local function send0(msg, cb)
    local function _13_(conn)
      return remote.send(conn, msg, cb)
    end
    return with_conn_or_warn(_13_)
  end
  v_23_auto = send0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["send"] = v_23_auto
  send = v_23_auto
end
local connect
do
  local v_23_auto
  do
    local v_25_auto
    local function connect0(opts)
      local opts0 = (opts or {})
      local host = (opts0.host or config["get-in"]({"client", "janet", "netrepl", "connection", "default_host"}))
      local port = (opts0.port or config["get-in"]({"client", "janet", "netrepl", "connection", "default_port"}))
      if state("conn") then
        disconnect()
      end
      local function _15_(err)
        if err then
          return display_conn_status(err)
        else
          return disconnect()
        end
      end
      local function _17_(err)
        display_conn_status(err)
        return disconnect()
      end
      local function _18_()
        return display_conn_status("connected")
      end
      return a.assoc(state(), "conn", remote.connect({["on-error"] = _15_, ["on-failure"] = _17_, ["on-success"] = _18_, host = host, port = port}))
    end
    v_25_auto = connect0
    _1_["connect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect"] = v_23_auto
  connect = v_23_auto
end
local try_ensure_conn
do
  local v_23_auto
  local function try_ensure_conn0()
    if not connected_3f() then
      return connect({["silent?"] = true})
    end
  end
  v_23_auto = try_ensure_conn0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["try-ensure-conn"] = v_23_auto
  try_ensure_conn = v_23_auto
end
local eval_str
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_str0(opts)
      try_ensure_conn()
      local function _20_(msg)
        local clean = text["trim-last-newline"](msg)
        if opts["on-result"] then
          opts["on-result"](text["strip-ansi-escape-sequences"](clean))
        end
        if not opts["passive?"] then
          return log.append(text["split-lines"](clean))
        end
      end
      return send((opts.code .. "\n"), _20_)
    end
    v_25_auto = eval_str0
    _1_["eval-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-str"] = v_23_auto
  eval_str = v_23_auto
end
local doc_str
do
  local v_23_auto
  do
    local v_25_auto
    local function doc_str0(opts)
      try_ensure_conn()
      local function _23_(_241)
        return ("(doc " .. _241 .. ")")
      end
      return eval_str(a.update(opts, "code", _23_))
    end
    v_25_auto = doc_str0
    _1_["doc-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["doc-str"] = v_23_auto
  doc_str = v_23_auto
end
local eval_file
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_file0(opts)
      try_ensure_conn()
      return eval_str(a.assoc(opts, "code", ("(do (dofile \"" .. opts["file-path"] .. "\" :env (fiber/getenv (fiber/current))) nil)")))
    end
    v_25_auto = eval_file0
    _1_["eval-file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-file"] = v_23_auto
  eval_file = v_23_auto
end
local on_filetype
do
  local v_23_auto
  do
    local v_25_auto
    local function on_filetype0()
      mapping.buf("n", "JanetDisconnect", config["get-in"]({"client", "janet", "netrepl", "mapping", "disconnect"}), "conjure.client.janet.netrepl", "disconnect")
      return mapping.buf("n", "JanetConnect", config["get-in"]({"client", "janet", "netrepl", "mapping", "connect"}), "conjure.client.janet.netrepl", "connect")
    end
    v_25_auto = on_filetype0
    _1_["on-filetype"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-filetype"] = v_23_auto
  on_filetype = v_23_auto
end
local on_load
do
  local v_23_auto
  do
    local v_25_auto
    local function on_load0()
      return connect({})
    end
    v_25_auto = on_load0
    _1_["on-load"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-load"] = v_23_auto
  on_load = v_23_auto
end
local on_exit
do
  local v_23_auto
  do
    local v_25_auto
    local function on_exit0()
      return disconnect()
    end
    v_25_auto = on_exit0
    _1_["on-exit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-exit"] = v_23_auto
  on_exit = v_23_auto
end
return nil