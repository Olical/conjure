-- [nfnl] fnl/conjure/remote/socket.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local text = autoload("conjure.text")
local uv = vim.uv
local function strip_unprintable(s)
  return string.gsub(text["strip-ansi-escape-sequences"](s), "[\1\2]", "")
end
local function host__3eaddr(s)
  local info = uv.getaddrinfo(s, nil, {family = "inet", protocol = "tcp"})
  if info then
    return info[1].addr
  else
    return nil
  end
end
local function start(opts)
  local _let_3_ = vim.split(opts.pipename, ":")
  local host = _let_3_[1]
  local port = _let_3_[2]
  local host0 = host__3eaddr(host)
  local repl = {status = "pending", queue = {}, current = nil, buffer = ""}
  local handle = nil
  log.dbg(a.str("opts.pipename=", opts.pipename))
  log.dbg(a.str("host=", host0))
  local function destroy()
    local function _4_()
      return handle:shutdown()
    end
    pcall(_4_)
    return nil
  end
  local function next_in_queue()
    local next_msg = a.first(repl.queue)
    if (next_msg and not repl.current) then
      table.remove(repl.queue, 1)
      a.assoc(repl, "current", next_msg)
      log.dbg("send", next_msg.code)
      return handle:write((next_msg.code .. "\n"))
    else
      return nil
    end
  end
  local function on_message(chunk)
    log.dbg("receive", chunk)
    if chunk then
      local _let_6_ = opts["parse-output"](chunk)
      local done_3f = _let_6_["done?"]
      local error_3f = _let_6_["error?"]
      local result = _let_6_["result"]
      local cb = a["get-in"](repl, {"current", "cb"}, opts["on-stray-output"])
      if error_3f then
        opts["on-error"]({err = repl.buffer, ["done?"] = done_3f}, repl)
      else
      end
      if done_3f then
        if cb then
          local function _8_()
            return cb({out = result, ["done?"] = done_3f})
          end
          pcall(_8_)
        else
        end
        a.assoc(repl, "current", nil)
        a.assoc(repl, "buffer", "")
        return next_in_queue()
      else
        return nil
      end
    else
      return nil
    end
  end
  local function on_output(err, chunk)
    if err then
      return opts["on-failure"](a["merge!"](repl, {status = "failed", err = err}))
    elseif chunk then
      a.assoc(repl, "buffer", (a.get(repl, "buffer") .. chunk))
      return on_message(strip_unprintable(a.get(repl, "buffer")))
    else
      return opts["on-close"](a.assoc(repl, "status", "closed"))
    end
  end
  local function send(code, cb, opts0)
    local _13_
    if a.get(opts0, "batch?") then
      local msgs = {}
      local function _15_(msg)
        table.insert(msgs, msg)
        if msg["done?"] then
          return cb(msgs)
        else
          return nil
        end
      end
      _13_ = _15_
    else
      _13_ = cb
    end
    table.insert(repl.queue, {code = code, cb = _13_})
    next_in_queue()
    return nil
  end
  local function on_connect(err)
    if err then
      return opts["on-failure"](a["merge!"](repl, {status = "failed", err = err}))
    else
      opts["on-success"](a.assoc(repl, "status", "connected"))
      local function _18_(err0, chunk)
        return on_output(err0, chunk)
      end
      return handle:read_start(client["schedule-wrap"](_18_))
    end
  end
  if (host0 and port) then
    handle = uv.new_tcp("inet")
    uv.tcp_connect(handle, host0, tonumber(port), client["schedule-wrap"](on_connect))
  elseif not port then
    handle = uv.new_pipe(true)
    uv.pipe_connect(handle, opts.pipename, client["schedule-wrap"](on_connect))
  else
    vim.api.nvim_err_writeln(("conjure.remote.socket: can't connect to " .. opts.pipename))
  end
  return a["merge!"](repl, {opts = opts, destroy = destroy, send = send})
end
return {start = start}
