local _0_0 = nil
do
  local name_0_ = "conjure.remote.netrepl"
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
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.log"), require("conjure.net"), require("conjure.remote.transport.netrepl")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", net = "conjure.net", trn = "conjure.remote.transport.netrepl"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local client = _1_[2]
local log = _1_[3]
local net = _1_[4]
local trn = _1_[5]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.netrepl"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local send = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function send0(conn, msg, cb)
      log.dbg("send", msg)
      table.insert(conn.queue, 1, (cb or false))
      do end (conn.sock):write(trn.encode(msg))
      return nil
    end
    v_0_0 = send0
    _0_0["send"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["send"] = v_0_
  send = v_0_
end
local connect = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function connect0(opts)
      local conn = {decode = trn.decoder(), queue = {}}
      local function handle_message(err, chunk)
        if (err or not chunk) then
          return opts["on-error"](err)
        else
          local function _3_(msg)
            log.dbg("receive", msg)
            local cb = table.remove(conn.queue)
            if cb then
              return cb(msg)
            end
          end
          return a["run!"](_3_, conn.decode(chunk))
        end
      end
      local function _3_(err)
        if err then
          return opts["on-failure"](err)
        else
          do end (conn.sock):read_start(client["schedule-wrap"](handle_message))
          return opts["on-success"]()
        end
      end
      conn = a.merge(conn, net.connect({cb = client["schedule-wrap"](_3_), host = opts.host, port = opts.port}))
      send(conn, (opts.name or "Conjure"))
      return conn
    end
    v_0_0 = connect0
    _0_0["connect"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["connect"] = v_0_
  connect = v_0_
end
return nil