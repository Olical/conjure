-- [nfnl] Compiled from fnl/conjure/remote/socket.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local str = autoload("conjure.aniseed.string")
local text = autoload("conjure.text")
local uv = vim.loop
local function strip_unprintable(s)
  return string.gsub(text["strip-ansi-escape-sequences"](s), "[\1\2]", "")
end
local function start(opts)
  local repl_pipe = uv.new_pipe(true)
  local repl = {status = "pending", queue = {}, current = nil, buffer = ""}
  local function destroy()
    local function _2_()
      return repl_pipe:shutdown()
    end
    pcall(_2_)
    return nil
  end
  local function next_in_queue()
    local next_msg = a.first(repl.queue)
    if (next_msg and not repl.current) then
      table.remove(repl.queue, 1)
      a.assoc(repl, "current", next_msg)
      log.dbg("send", next_msg.code)
      return repl_pipe:write((next_msg.code .. "\n"))
    else
      return nil
    end
  end
  local function on_message(chunk)
    log.dbg("receive", chunk)
    if chunk then
      local _let_4_ = opts["parse-output"](chunk)
      local done_3f = _let_4_["done?"]
      local error_3f = _let_4_["error?"]
      local result = _let_4_["result"]
      local cb = a["get-in"](repl, {"current", "cb"}, opts["on-stray-output"])
      if error_3f then
        opts["on-error"]({err = repl.buffer, ["done?"] = done_3f}, repl)
      else
      end
      if done_3f then
        if cb then
          local function _6_()
            return cb({out = result, ["done?"] = done_3f})
          end
          pcall(_6_)
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
    local _11_
    if a.get(opts0, "batch?") then
      local msgs = {}
      local function _13_(msg)
        table.insert(msgs, msg)
        if msg["done?"] then
          return cb(msgs)
        else
          return nil
        end
      end
      _11_ = _13_
    else
      _11_ = cb
    end
    table.insert(repl.queue, {code = code, cb = _11_})
    next_in_queue()
    return nil
  end
  if opts.pipename then
    local function _16_(err)
      if err then
        return opts["on-failure"](a["merge!"](repl, {status = "failed", err = err}))
      else
        opts["on-success"](a.assoc(repl, "status", "connected"))
        local function _17_(err0, chunk)
          return on_output(err0, chunk)
        end
        return repl_pipe:read_start(client["schedule-wrap"](_17_))
      end
    end
    uv.pipe_connect(repl_pipe, opts.pipename, client["schedule-wrap"](_16_))
  else
    vim.api.nvim_err_writeln("conjure.remote.socket: No pipename specified")
  end
  return a["merge!"](repl, {opts = opts, destroy = destroy, send = send})
end
return {start = start}
