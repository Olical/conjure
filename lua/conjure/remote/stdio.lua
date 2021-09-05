local _2afile_2a = "fnl/conjure/remote/stdio.fnl"
local _2amodule_name_2a = "conjure.remote.stdio"
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
local a, client, log, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local uv = vim.loop
_2amodule_locals_2a["uv"] = uv
local function parse_prompt(s, pat)
  if s:find(pat) then
    return true, s:gsub(pat, "")
  else
    return false, s
  end
end
_2amodule_locals_2a["parse-prompt"] = parse_prompt
local function parse_cmd(x)
  if a["table?"](x) then
    return {args = a.rest(x), cmd = a.first(x)}
  elseif a["string?"](x) then
    return parse_cmd(str.split(x, "%s"))
  end
end
_2amodule_2a["parse-cmd"] = parse_cmd
local function extend_env(vars)
  local function _5_(_3_)
    local _arg_4_ = _3_
    local k = _arg_4_[1]
    local v = _arg_4_[2]
    return (k .. "=" .. v)
  end
  return a.map(_5_, a["kv-pairs"](a.merge(nvim.fn.environ(), vars)))
end
_2amodule_locals_2a["extend-env"] = extend_env
local function start(opts)
  local stdin = uv.new_pipe(false)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  local repl = {current = nil, queue = {}}
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
        return uv.process_kill(repl.handle)
      end
      pcall(_11_)
      local function _12_()
        return (repl.handle):close()
      end
      pcall(_12_)
    end
    return nil
  end
  local function on_exit(code, signal)
    destroy()
    return client.schedule(opts["on-exit"], code, signal)
  end
  local function next_in_queue()
    local next_msg = a.first(repl.queue)
    if (next_msg and not repl.current) then
      table.remove(repl.queue, 1)
      a.assoc(repl, "current", next_msg)
      log.dbg("send", next_msg.code)
      return stdin:write(next_msg.code)
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
        local cb = a["get-in"](repl, {"current", "cb"}, opts["on-stray-output"])
        if cb then
          local function _15_()
            return cb({["done?"] = done_3f, [source] = result})
          end
          pcall(_15_)
        end
        if done_3f then
          a.assoc(repl, "current", nil)
          return next_in_queue()
        end
      end
    end
  end
  local function on_stdout(err, chunk)
    return on_message("out", err, chunk)
  end
  local function on_stderr(err, chunk)
    return on_message("err", err, chunk)
  end
  local function send(code, cb, opts0)
    local _20_
    if a.get(opts0, "batch?") then
      local msgs = {}
      local function _22_(msg)
        table.insert(msgs, msg)
        if msg["done?"] then
          return cb(msgs)
        end
      end
      _20_ = _22_
    else
      _20_ = cb
    end
    table.insert(repl.queue, {cb = _20_, code = code})
    next_in_queue()
    return nil
  end
  local function send_signal(signal)
    uv.process_kill(repl.handle, signal)
    return nil
  end
  local _let_25_ = parse_cmd(opts.cmd)
  local args = _let_25_["args"]
  local cmd = _let_25_["cmd"]
  local handle, pid_or_err = uv.spawn(cmd, {args = args, env = extend_env({INPUTRC = "/dev/null", TERM = "dumb"}), stdio = {stdin, stdout, stderr}}, client["schedule-wrap"](on_exit))
  if handle then
    stdout:read_start(client["schedule-wrap"](on_stdout))
    stderr:read_start(client["schedule-wrap"](on_stderr))
    local function _26_()
      return opts["on-success"]()
    end
    client.schedule(_26_)
    return a["merge!"](repl, {["send-signal"] = send_signal, destroy = destroy, handle = handle, opts = opts, pid = pid_or_err, send = send})
  else
    local function _27_()
      return opts["on-error"](pid_or_err)
    end
    client.schedule(_27_)
    return destroy()
  end
end
_2amodule_2a["start"] = start