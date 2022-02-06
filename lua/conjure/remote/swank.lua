local _2afile_2a = "fnl/conjure/remote/swank.fnl"
local _2amodule_name_2a = "conjure.remote.swank"
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
local a, client, log, net, nvim, trn = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.net"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.transport.swank")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["net"] = net
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["trn"] = trn
local function send(conn, msg, cb)
  table.insert(conn.queue, 1, (cb or false))
  do end (conn.sock):write(trn.encode(msg))
  return nil
end
_2amodule_2a["send"] = send
local function connect(opts)
  local conn = {decode = trn.decode, queue = {}}
  local function handle_message(err, chunk)
    if (err or not chunk) then
      return opts["on-error"](err)
    else
      local function _1_(msg)
        local cb = table.remove(conn.queue)
        if cb then
          return cb(msg)
        else
          return nil
        end
      end
      return _1_(conn.decode(chunk))
    end
  end
  local function _4_(err)
    if err then
      return opts["on-failure"](err)
    else
      do end (conn.sock):read_start(client["schedule-wrap"](handle_message))
      return opts["on-success"]()
    end
  end
  conn = a.merge(conn, net.connect({host = opts.host, port = opts.port, cb = client["schedule-wrap"](_4_)}))
  return conn
end
_2amodule_2a["connect"] = connect
return _2amodule_2a