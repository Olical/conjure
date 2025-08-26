-- [nfnl] fnl/conjure/remote/stdio-rt.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local M = define("conjure.remote.stdio-rt")
local uv = vim.uv
local function parse_prompt(s, pat)
  if s:find(pat) then
    return true, s:gsub(pat, "")
  else
    return false, s
  end
end
M["parse-cmd"] = function(x)
  if core["table?"](x) then
    return {cmd = core.first(x), args = core.rest(x)}
  elseif core["string?"](x) then
    return M["parse-cmd"](str.split(x, "%s"))
  else
    return nil
  end
end
local function extend_env(vars)
  local function _5_(_4_)
    local k = _4_[1]
    local v = _4_[2]
    return (k .. "=" .. v)
  end
  return core.map(_5_, core["kv-pairs"](core.merge(vim.fn.environ(), vars)))
end
M.start = function(opts)
  local stdin = uv.new_pipe(false)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local repl = {queue = {}, current = nil}
  local function destroy()
    local function _6_()
      return stdout:read_stop()
    end
    pcall(_6_)
    local function _7_()
      return stderr:read_stop()
    end
    pcall(_7_)
    local function _8_()
      return stdout:close()
    end
    pcall(_8_)
    local function _9_()
      return stderr:close()
    end
    pcall(_9_)
    local function _10_()
      return stdin:close()
    end
    pcall(_10_)
    if repl.handle then
      local function _11_()
        return uv.process_kill(repl.handle, uv.constants.SIGINT)
      end
      pcall(_11_)
    else
    end
    return nil
  end
  local function on_exit(code, signal)
    log.dbg("on-exit called")
    destroy()
    return client.schedule(opts["on-exit"], code, signal)
  end
  local function next_in_queue()
    local next_msg = core.first(repl.queue)
    if next_msg then
      table.remove(repl.queue, 1)
      core.assoc(repl, "current", next_msg)
      log.dbg("send", next_msg.code)
      return stdin:write(next_msg.code)
    else
      return nil
    end
  end
  local function on_message(source, err, chunk)
    log.dbg("receive", source, err, chunk)
    if err then
      opts["on-error"](err)
      return destroy()
    else
      if chunk then
        local done_3f, result = parse_prompt(chunk, opts["prompt-pattern"])
        local cb = core["get-in"](repl, {"current", "cb"}, opts["on-stray-output"])
        if cb then
          local function _14_()
            return cb({[source] = result, ["done?"] = done_3f})
          end
          pcall(_14_)
        else
        end
        if done_3f then
          core.assoc(repl, "current", nil)
          return next_in_queue()
        else
          return nil
        end
      else
        return nil
      end
    end
  end
  local function on_stdout(err, chunk)
    return on_message("out", err, chunk)
  end
  local function on_stderr(err, chunk)
    if opts["delay-stderr-ms"] then
      local function _19_()
        return on_message("err", err, chunk)
      end
      return vim.defer_fn(_19_, opts["delay-stderr-ms"])
    else
      return on_message("err", err, chunk)
    end
  end
  local function send(code, cb, opts0)
    local _21_
    if core.get(opts0, "batch?") then
      local msgs = {}
      local function _23_(msg)
        table.insert(msgs, msg)
        if msg["done?"] then
          return cb(msgs)
        else
          return nil
        end
      end
      _21_ = _23_
    else
      _21_ = cb
    end
    table.insert(repl.queue, {code = code, cb = _21_})
    next_in_queue()
    return nil
  end
  local function send_signal(signal)
    uv.process_kill(repl.handle, signal)
    return nil
  end
  local _let_26_ = M["parse-cmd"](opts.cmd)
  local cmd = _let_26_["cmd"]
  local args = _let_26_["args"]
  local handle, pid_or_err = uv.spawn(cmd, {stdio = {stdin, stdout, stderr}, args = args, env = extend_env(core["merge!"]({INPUTRC = "/dev/null", TERM = "dumb"}, opts.env))}, client["schedule-wrap"](on_exit))
  if handle then
    stdout:read_start(client["schedule-wrap"](on_stdout))
    stderr:read_start(client["schedule-wrap"](on_stderr))
    local function _27_()
      return opts["on-success"]()
    end
    client.schedule(_27_)
    return core["merge!"](repl, {handle = handle, pid = pid_or_err, send = send, opts = opts, ["send-signal"] = send_signal, destroy = destroy})
  else
    local function _28_()
      return opts["on-error"](pid_or_err)
    end
    client.schedule(_28_)
    return destroy()
  end
end
return M
