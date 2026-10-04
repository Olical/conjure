-- [nfnl] fnl/conjure/remote/swank.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local net = autoload("conjure.net")
local trn = autoload("conjure.remote.transport.swank")
local M = define("conjure.remote.swank")
M["message-id"] = function(msg)
  return string.match(msg, "^%((:[%w-]+) .* (%d+)%)%s*$")
end
M["split-messages"] = function(buf)
  local rest = buf
  local done_3f = false
  local msgs = {}
  while not done_3f do
    local len = tonumber(string.sub(rest, 1, 6), 16)
    if (len and (#rest >= (6 + len))) then
      table.insert(msgs, string.sub(rest, 7, (6 + len)))
      rest = string.sub(rest, (7 + len))
    else
      done_3f = true
    end
  end
  return msgs, rest
end
M.send = function(conn, msg, cb)
  do
    local _, id = M["message-id"](msg)
    if (id and cb) then
      conn.callbacks[id] = cb
    else
    end
  end
  conn.sock:write(trn.encode(msg))
  return nil
end
M.connect = function(opts)
  local conn = {callbacks = {}, buf = ""}
  local function dispatch(msg)
    local kind, id = M["message-id"](msg)
    local cb = ((":return" == kind) and conn.callbacks[id])
    if cb then
      conn.callbacks[id] = nil
      return cb(msg)
    else
      if ((":return" ~= kind) and opts["on-event"]) then
        return opts["on-event"](msg)
      else
        return nil
      end
    end
  end
  local function handle_message(err, chunk)
    if (err or not chunk) then
      return opts["on-error"](err)
    else
      local msgs, rest = M["split-messages"]((conn.buf .. chunk))
      conn.buf = rest
      for _, msg in ipairs(msgs) do
        dispatch(msg)
      end
      return nil
    end
  end
  local function _7_(err)
    if err then
      return opts["on-failure"](err)
    else
      conn.sock:read_start(client["schedule-wrap"](handle_message))
      return opts["on-success"]()
    end
  end
  conn = core.merge(conn, net.connect({host = opts.host, port = opts.port, cb = client["schedule-wrap"](_7_)}))
  return conn
end
return M
