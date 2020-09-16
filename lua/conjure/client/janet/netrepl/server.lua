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
local function _2_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", log = "conjure.log", net = "conjure.net", trn = "conjure.client.janet.netrepl.transport"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.log"), require("conjure.net"), require("conjure.client.janet.netrepl.transport")}
end
local _1_ = _2_(...)
local a = _1_[1]
local client = _1_[2]
local config = _1_[3]
local log = _1_[4]
local net = _1_[5]
local trn = _1_[6]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local state = nil
do
  local v_0_ = nil
  local function _3_()
    return {conn = nil}
  end
  v_0_ = (_0_0["aniseed/locals"].state or client["new-state"](_3_))
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
      return log.append({"# No connection"})
    end
  end
  v_0_ = with_conn_or_warn0
  _0_0["aniseed/locals"]["with-conn-or-warn"] = v_0_
  with_conn_or_warn = v_0_
end
local connected_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connected_3f0()
      if state("conn") then
        return true
      else
        return false
      end
    end
    v_0_0 = connected_3f0
    _0_0["connected?"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connected?"] = v_0_
  connected_3f = v_0_
end
local display_conn_status = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function display_conn_status0(status)
      local function _3_(conn)
        return log.append({("# " .. conn.host .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
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
        conn.destroy()
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
        log.dbg("receive", msg)
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
      log.dbg("send", msg)
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
        do end (conn.sock):read_start(client["schedule-wrap"](handle_message))
        return display_conn_status("connected")
      end
    end
    return client["schedule-wrap"](_3_)
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
      if state("conn") then
        disconnect()
      end
      a.assoc(state(), "conn", a.merge(net.connect({cb = handle_connect_fn(), host = host, port = port}), {decode = trn.decoder(), queue = {}}))
      return send("Conjure")
    end
    v_0_0 = connect0
    _0_0["connect"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connect"] = v_0_
  connect = v_0_
end
return nil