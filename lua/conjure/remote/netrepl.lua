-- [nfnl] Compiled from fnl/conjure/remote/netrepl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local net = autoload("conjure.net")
local trn = autoload("conjure.remote.transport.netrepl")
local function send(conn, msg, cb, prompt_3f)
  log.dbg("send", msg)
  table.insert(conn.queue, 1, (cb or false))
  if prompt_3f then
    table.insert(conn.queue, 1, false)
  else
  end
  conn.sock:write(trn.encode(msg))
  return nil
end
local function connect(opts)
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
        else
          return nil
        end
      end
      return a["run!"](_3_, conn.decode(chunk))
    end
  end
  local function _6_(err)
    if err then
      return opts["on-failure"](err)
    else
      send(conn, (opts.name or "Conjure"))
      conn.sock:read_start(client["schedule-wrap"](handle_message))
      return opts["on-success"]()
    end
  end
  conn = a.merge(conn, net.connect({host = opts.host, port = opts.port, cb = client["schedule-wrap"](_6_)}))
  return conn
end
return {connect = connect, send = send}
