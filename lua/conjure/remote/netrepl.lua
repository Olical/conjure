local _2afile_2a = "fnl/conjure/remote/netrepl.fnl"
local _1_
do
  local name_4_auto = "conjure.remote.netrepl"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.net"), autoload("conjure.remote.transport.netrepl")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", net = "conjure.net", trn = "conjure.remote.transport.netrepl"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local client = _local_4_[2]
local log = _local_4_[3]
local net = _local_4_[4]
local trn = _local_4_[5]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.remote.netrepl"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local send
do
  local v_23_auto
  do
    local v_25_auto
    local function send0(conn, msg, cb)
      log.dbg("send", msg)
      table.insert(conn.queue, 1, (cb or false))
      do end (conn.sock):write(trn.encode(msg))
      return nil
    end
    v_25_auto = send0
    _1_["send"] = v_25_auto
    v_23_auto = v_25_auto
  end
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
      local conn = {decode = trn.decoder(), queue = {}}
      local function handle_message(err, chunk)
        if (err or not chunk) then
          return opts["on-error"](err)
        else
          local function _8_(msg)
            log.dbg("receive", msg)
            local cb = table.remove(conn.queue)
            if cb then
              return cb(msg)
            end
          end
          return a["run!"](_8_, conn.decode(chunk))
        end
      end
      local function _11_(err)
        if err then
          return opts["on-failure"](err)
        else
          do end (conn.sock):read_start(client["schedule-wrap"](handle_message))
          return opts["on-success"]()
        end
      end
      conn = a.merge(conn, net.connect({cb = client["schedule-wrap"](_11_), host = opts.host, port = opts.port}))
      send(conn, (opts.name or "Conjure"))
      return conn
    end
    v_25_auto = connect0
    _1_["connect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect"] = v_23_auto
  connect = v_23_auto
end
return nil