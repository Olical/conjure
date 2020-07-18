local _0_0 = nil
do
  local name_0_ = "conjure.client.janet.netrepl.server"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", log = "conjure.log", net = "conjure.net", trn = "conjure.client.janet.netrepl.transport", ui = "conjure.client.janet.netrepl.ui"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.log"), require("conjure.net"), require("conjure.client.janet.netrepl.transport"), require("conjure.client.janet.netrepl.ui")}
end
local _2_ = _1_(...)
local a = _2_[1]
local client = _2_[2]
local config = _2_[3]
local log = _2_[4]
local net = _2_[5]
local trn = _2_[6]
local ui = _2_[7]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
client["init-state"]({"janet", "netrepl"}, {conn = nil})
local state = nil
do
  local v_0_ = nil
  do
    local v_0_0 = client["state-fn"]("janet", "netrepl")
    _0_0["state"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["state"] = v_0_
  state = v_0_
end
local with_conn_or_warn = nil
do
  local v_0_ = nil
  local function with_conn_or_warn0(f, opts)
    local conn = state("conn")
    if conn then
      return f(conn)
    else
      return ui.display({"# No connection"})
    end
  end
  v_0_ = with_conn_or_warn0
  _0_0["aniseed/locals"]["with-conn-or-warn"] = v_0_
  with_conn_or_warn = v_0_
end
local display_conn_status = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function display_conn_status0(status)
      local function _3_(conn)
        return ui.display({("# " .. conn["raw-host"] .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
      end
      return with_conn_or_warn(_3_)
    end
    v_0_0 = display_conn_status0
    _0_0["display-conn-status"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["display-conn-status"] = v_0_
  display_conn_status = v_0_
end
local disconnect = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function disconnect0()
      local function _3_(conn)
        if not (conn.sock):is_closing() then
          do end (conn.sock):read_stop()
          do end (conn.sock):shutdown()
          do end (conn.sock):close()
        end
        display_conn_status("disconnected")
        return a.assoc(state(), "conn", nil)
      end
      return with_conn_or_warn(_3_)
    end
    v_0_0 = disconnect0
    _0_0["disconnect"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["disconnect"] = v_0_
  disconnect = v_0_
end
local dbg = nil
do
  local v_0_ = nil
  local function dbg0(...)
    return client["with-filetype"]("janet", log.dbg, ...)
  end
  v_0_ = dbg0
  _0_0["aniseed/locals"]["dbg"] = v_0_
  dbg = v_0_
end
local handle_message = nil
do
  local v_0_ = nil
  local function handle_message0(err, chunk)
    local conn = state("conn")
    if err then
      return display_conn_status(err)
    elseif not chunk then
      return disconnect()
    else
      local function _3_(msg)
        dbg("receive", msg)
        local cb = table.remove(state("conn", "queue"))
        if cb then
          return cb(msg)
        end
      end
      return a["run!"](_3_, conn.decode(chunk))
    end
  end
  v_0_ = handle_message0
  _0_0["aniseed/locals"]["handle-message"] = v_0_
  handle_message = v_0_
end
local send = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function send0(msg, cb)
      dbg("send", msg)
      local function _3_(conn)
        table.insert(state("conn", "queue"), 1, (cb or false))
        return (conn.sock):write(trn.encode(msg))
      end
      return with_conn_or_warn(_3_)
    end
    v_0_0 = send0
    _0_0["send"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["send"] = v_0_
  send = v_0_
end
local handle_connect_fn = nil
do
  local v_0_ = nil
  local function handle_connect_fn0(cb)
    local function _3_(err)
      local conn = state("conn")
      if err then
        display_conn_status(err)
        return disconnect()
      else
        do end (conn.sock):read_start(vim.schedule_wrap(handle_message))
        send("Conjure")
        return display_conn_status("connected")
      end
    end
    return vim.schedule_wrap(_3_)
  end
  v_0_ = handle_connect_fn0
  _0_0["aniseed/locals"]["handle-connect-fn"] = v_0_
  handle_connect_fn = v_0_
end
local connect = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connect0(opts)
      local opts0 = (opts or {})
      local host = (opts0.host or config["get-in"]({"client", "janet", "netrepl", "connection", "default_host"}))
      local port = (opts0.port or config["get-in"]({"client", "janet", "netrepl", "connection", "default_port"}))
      local resolved_host = net.resolve(host)
      local conn = {["raw-host"] = host, decode = trn.decoder(), host = resolved_host, port = port, queue = {}, sock = vim.loop.new_tcp()}
      if state("conn") then
        disconnect()
      end
      a.assoc(state(), "conn", conn)
      return (conn.sock):connect(resolved_host, port, handle_connect_fn())
    end
    v_0_0 = connect0
    _0_0["connect"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connect"] = v_0_
  connect = v_0_
end
return nil