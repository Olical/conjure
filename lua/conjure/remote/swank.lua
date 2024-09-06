-- [nfnl] Compiled from fnl/conjure/remote/swank.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local net = autoload("conjure.net")
local trn = autoload("conjure.remote.transport.swank")
local function send(conn, msg, cb)
  table.insert(conn.queue, 1, (cb or false))
  conn.sock:write(trn.encode(msg))
  return nil
end
local function connect(opts)
  local conn = {decode = trn.decode, queue = {}}
  local function handle_message(err, chunk)
    if (err or not chunk) then
      return opts["on-error"](err)
    else
      local function _2_(msg)
        local cb = table.remove(conn.queue)
        if cb then
          return cb(msg)
        else
          return nil
        end
      end
      return _2_(conn.decode(chunk))
    end
  end
  local function _5_(err)
    if err then
      return opts["on-failure"](err)
    else
      conn.sock:read_start(client["schedule-wrap"](handle_message))
      return opts["on-success"]()
    end
  end
  conn = a.merge(conn, net.connect({host = opts.host, port = opts.port, cb = client["schedule-wrap"](_5_)}))
  return conn
end
return {send = send, connect = connect}
