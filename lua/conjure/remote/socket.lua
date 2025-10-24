-- [nfnl] fnl/conjure/remote/socket.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
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
  local repl = {status = "pending", queue = {}, current = nil, buffer = ""}
  local handle = nil
  local function destroy()
    local function _3_()
      return handle:shutdown()
    end
    pcall(_3_)
    return nil
  end
  local function next_in_queue()
    local next_msg = a.first(repl.queue)
    if (next_msg and not repl.current) then
      table.remove(repl.queue, 1)
      a.assoc(repl, "current", next_msg)
      log.dbg("remote.socket: send", next_msg.code)
      return handle:write((next_msg.code .. "\n"))
    else
      return nil
    end
  end
  local function on_message(chunk)
    log.dbg("remote.socket: receive", chunk)
    if chunk then
      local _let_5_ = opts["parse-output"](chunk)
      local done_3f = _let_5_["done?"]
      local error_3f = _let_5_["error?"]
      local result = _let_5_.result
      local cb = a["get-in"](repl, {"current", "cb"}, opts["on-stray-output"])
      if error_3f then
        opts["on-error"]({err = repl.buffer, ["done?"] = done_3f}, repl)
      else
      end
      if done_3f then
        if cb then
          local function _7_()
            return cb({out = result, ["done?"] = done_3f})
          end
          pcall(_7_)
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
    local _12_
    if a.get(opts0, "batch?") then
      local msgs = {}
      local function _14_(msg)
        table.insert(msgs, msg)
        if msg["done?"] then
          return cb(msgs)
        else
          return nil
        end
      end
      _12_ = _14_
    else
      _12_ = cb
    end
    table.insert(repl.queue, {code = code, cb = _12_})
    next_in_queue()
    return nil
  end
  local function on_connect(err)
    if err then
      return opts["on-failure"](a["merge!"](repl, {status = "failed", err = err}))
    else
      opts["on-success"](a.assoc(repl, "status", "connected"))
      local function _17_(err0, chunk)
        return on_output(err0, chunk)
      end
      return handle:read_start(client["schedule-wrap"](_17_))
    end
  end
  if opts.pipename then
    log.dbg(a.str("remote.socket: pipename=", opts.pipename))
    handle = uv.new_pipe(true)
    uv.pipe_connect(handle, opts.pipename, client["schedule-wrap"](on_connect))
  elseif opts["host-port"] then
    log.dbg(a.str("remote.socket: host-port=", opts["host-port"]))
    handle = uv.new_tcp("inet")
    local _let_19_ = vim.split(opts["host-port"], ":")
    local host = _let_19_[1]
    local port = _let_19_[2]
    local conn_status = uv.tcp_connect(handle, host__3eaddr(host), tonumber(port), client["schedule-wrap"](on_connect))
    log.dbg(a.str("remote.socket: host=", host))
    log.dbg(a.str("remote.socket: port=", port))
    log.dbg(a.str("remote.socket: conn_status=", conn_status))
    if not conn_status then
      a["merge!"](repl, {status = "failed", err = a.str("couldn't connect to ", host, ":", port)})
      opts["on-failure"](a["merge!"](repl, {status = "failed", err = a.str("couldn't connect to ", host, ":", port)}))
    else
    end
  else
    vim.api.nvim_echo({{"conjure.remote.socket: No pipename or host-port specified"}}, true, {err = true})
  end
  log.dbg(a.str("remote.socket: repl = ", repl))
  return a["merge!"](repl, {opts = opts, destroy = destroy, send = send})
end
return {start = start}
