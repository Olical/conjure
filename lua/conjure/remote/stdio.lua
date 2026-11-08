-- [nfnl] fnl/conjure/remote/stdio.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local process = autoload("conjure.process")
local M = define("conjure.remote.stdio")
local vim = _G.vim
local uv = vim.uv
config.merge({stdio = {silence_missing_command = false}})
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
  local _let_6_ = M["parse-cmd"](opts.cmd)
  local cmd = _let_6_.cmd
  local args = _let_6_.args
  if not process["executable?"](cmd) then
    if not config["get-in"]({"stdio", "silence_missing_command"}) then
      local function _7_()
        return opts["on-error"](("command not found: " .. cmd .. " (is it installed and on your $PATH?)"))
      end
      client.schedule(_7_)
    else
    end
    return nil
  else
    local stdin = uv.new_pipe(false)
    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)
    local repl
    local _9_
    if opts["await-initial-prompt?"] then
      _9_ = {}
    else
      _9_ = nil
    end
    repl = {queue = {}, current = _9_}
    local function destroy()
      local function _11_()
        return stdout:read_stop()
      end
      pcall(_11_)
      local function _12_()
        return stderr:read_stop()
      end
      pcall(_12_)
      local function _13_()
        return stdout:close()
      end
      pcall(_13_)
      local function _14_()
        return stderr:close()
      end
      pcall(_14_)
      local function _15_()
        return stdin:close()
      end
      pcall(_15_)
      if repl.handle then
        local function _16_()
          return uv.process_kill(repl.handle, "sigterm")
        end
        pcall(_16_)
        local function _17_()
          return repl.handle:close()
        end
        pcall(_17_)
      else
      end
      return nil
    end
    local function on_exit(code, signal)
      destroy()
      return client.schedule(opts["on-exit"], code, signal)
    end
    local function next_in_queue()
      local next_msg = core.first(repl.queue)
      if (next_msg and not repl.current) then
        table.remove(repl.queue, 1)
        core.assoc(repl, "current", next_msg)
        log.dbg(("remote.stdio.next-in-queue; sending next-msg.code:'" .. core.str(next_msg.code) .. "'"))
        return stdin:write(next_msg.code)
      else
        return nil
      end
    end
    local function on_message(source, err, chunk)
      log.dbg(("remote.stdio.on-message; from:" .. source .. ", err:'" .. core.str(err) .. "', chunk:'" .. core.str(chunk) .. "'"))
      if err then
        opts["on-error"](err)
        return destroy()
      else
        if chunk then
          local done_3f, result = parse_prompt(chunk, opts["prompt-pattern"])
          local cb = core["get-in"](repl, {"current", "cb"}, opts["on-stray-output"])
          if cb then
            local function _20_()
              local _21_
              if opts["preserve-prompt?"] then
                _21_ = chunk
              else
                _21_ = result
              end
              return cb({[source] = _21_, ["done?"] = done_3f})
            end
            pcall(_20_)
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
        local function _27_()
          return on_message("err", err, chunk)
        end
        return vim.defer_fn(_27_, opts["delay-stderr-ms"])
      else
        return on_message("err", err, chunk)
      end
    end
    local function send(code, cb, opts0)
      local _29_
      if core.get(opts0, "batch?") then
        local msgs = {}
        local function _31_(msg)
          table.insert(msgs, msg)
          if msg["done?"] then
            return cb(msgs)
          else
            return nil
          end
        end
        _29_ = _31_
      else
        _29_ = cb
      end
      table.insert(repl.queue, {code = code, cb = _29_})
      next_in_queue()
      return nil
    end
    local function immediate_send(code)
      stdin:write(code)
      return nil
    end
    local function send_signal(signal)
      uv.process_kill(repl.handle, signal)
      return nil
    end
    local handle, pid_or_err = uv.spawn(cmd, {stdio = {stdin, stdout, stderr}, args = args, env = extend_env(core["merge!"]({INPUTRC = "/dev/null", TERM = "dumb"}, opts.env))}, client["schedule-wrap"](on_exit))
    if handle then
      stdout:read_start(client["schedule-wrap"](on_stdout))
      stderr:read_start(client["schedule-wrap"](on_stderr))
      local function _34_()
        return opts["on-success"]()
      end
      client.schedule(_34_)
      return core["merge!"](repl, {handle = handle, pid = pid_or_err, send = send, ["immediate-send"] = immediate_send, opts = opts, ["send-signal"] = send_signal, destroy = destroy})
    else
      local function _35_()
        return opts["on-error"](pid_or_err)
      end
      client.schedule(_35_)
      return destroy()
    end
  end
end
return M
