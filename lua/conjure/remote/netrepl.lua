local _2afile_2a = "fnl/conjure/remote/netrepl.fnl"
local _2amodule_name_2a = "conjure.remote.netrepl"
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
local a, client, log, net, trn = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.net"), autoload("conjure.remote.transport.netrepl")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["net"] = net
_2amodule_locals_2a["trn"] = trn
local function send(conn, msg, cb, prompt_3f)
  log.dbg("send", msg)
  table.insert(conn.queue, 1, (cb or false))
  if prompt_3f then
    table.insert(conn.queue, 1, false)
  else
  end
  do end (conn.sock):write(trn.encode(msg))
  return nil
end
_2amodule_2a["send"] = send
local function connect(opts)
  local conn = {decode = trn.decoder(), queue = {}}
  local function handle_message(err, chunk)
    if (err or not chunk) then
      return opts["on-error"](err)
    else
      local function _2_(msg)
        log.dbg("receive", msg)
        local cb = table.remove(conn.queue)
        if cb then
          return cb(msg)
        else
          return nil
        end
      end
      return a["run!"](_2_, conn.decode(chunk))
    end
  end
  local function _5_(err)
    if err then
      return opts["on-failure"](err)
    else
      do end (conn.sock):read_start(client["schedule-wrap"](handle_message))
      return opts["on-success"]()
    end
  end
  conn = a.merge(conn, net.connect({host = opts.host, port = opts.port, cb = client["schedule-wrap"](_5_)}))
  send(conn, (opts.name or "Conjure"))
  return conn
end
_2amodule_2a["connect"] = connect
return _2amodule_2a