local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.remote.stdio"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.log"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local client = _local_0_[2]
local log = _local_0_[3]
local nvim = _local_0_[4]
local str = _local_0_[5]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.stdio"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local uv = vim.loop
local function parse_prompt(s, pat)
  if s:find(pat) then
    return true, s:gsub(pat, "")
  else
    return false, s
  end
end
local parse_cmd
do
  local v_0_
  local function parse_cmd0(x)
    if a["table?"](x) then
      return {args = a.rest(x), cmd = a.first(x)}
    elseif a["string?"](x) then
      return parse_cmd0(str.split(x, "%s"))
    end
  end
  v_0_ = parse_cmd0
  _0_0["parse-cmd"] = v_0_
  parse_cmd = v_0_
end
local function extend_env(vars)
  local function _2_(_1_0)
    local _arg_0_ = _1_0
    local k = _arg_0_[1]
    local v = _arg_0_[2]
    return (k .. "=" .. v)
  end
  return a.map(_2_, a["kv-pairs"](a.merge(nvim.fn.environ(), vars)))
end
local start
do
  local v_0_
  local function start0(opts)
    local stdin = uv.new_pipe(false)
    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)
    local repl = {current = nil, queue = {}}
    local function destroy()
      local function _1_()
        return stdout:read_stop()
      end
      pcall(_1_)
      local function _2_()
        return stderr:read_stop()
      end
      pcall(_2_)
      local function _3_()
        return stdout:close()
      end
      pcall(_3_)
      local function _4_()
        return stderr:close()
      end
      pcall(_4_)
      local function _5_()
        return stdin:close()
      end
      pcall(_5_)
      if repl.handle then
        local function _6_()
          return uv.process_kill(repl.handle)
        end
        pcall(_6_)
        local function _7_()
          return (repl.handle):close()
        end
        pcall(_7_)
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
            local function _1_()
              return cb({["done?"] = done_3f, [source] = result})
            end
            pcall(_1_)
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
      local _1_
      if a.get(opts0, "batch?") then
        local msgs = {}
        local function _3_(msg)
          table.insert(msgs, msg)
          if msg["done?"] then
            return cb(msgs)
          end
        end
        _1_ = _3_
      else
        _1_ = cb
      end
      table.insert(repl.queue, {cb = _1_, code = code})
      next_in_queue()
      return nil
    end
    local _let_0_ = parse_cmd(opts.cmd)
    local args = _let_0_["args"]
    local cmd = _let_0_["cmd"]
    local handle, pid_or_err = uv.spawn(cmd, {args = args, env = extend_env({INPUTRC = "/dev/null"}), stdio = {stdin, stdout, stderr}}, client["schedule-wrap"](on_exit))
    if handle then
      stdout:read_start(client["schedule-wrap"](on_stdout))
      stderr:read_start(client["schedule-wrap"](on_stderr))
      local function _1_()
        return opts["on-success"]()
      end
      client.schedule(_1_)
      return a["merge!"](repl, {destroy = destroy, handle = handle, opts = opts, pid = pid_or_err, send = send})
    else
      local function _1_()
        return opts["on-error"](pid_or_err)
      end
      client.schedule(_1_)
      return destroy()
    end
  end
  v_0_ = start0
  _0_0["start"] = v_0_
  start = v_0_
end
return nil