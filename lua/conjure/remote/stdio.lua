local _2afile_2a = "fnl/conjure/remote/stdio.fnl"
local _1_
do
  local name_4_auto = "conjure.remote.stdio"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local client = _local_4_[2]
local log = _local_4_[3]
local nvim = _local_4_[4]
local str = _local_4_[5]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.remote.stdio"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local uv
do
  local v_23_auto = vim.loop
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["uv"] = v_23_auto
  uv = v_23_auto
end
local parse_prompt
do
  local v_23_auto
  local function parse_prompt0(s, pat)
    if s:find(pat) then
      return true, s:gsub(pat, "")
    else
      return false, s
    end
  end
  v_23_auto = parse_prompt0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["parse-prompt"] = v_23_auto
  parse_prompt = v_23_auto
end
local parse_cmd
do
  local v_23_auto
  do
    local v_25_auto
    local function parse_cmd0(x)
      if a["table?"](x) then
        return {args = a.rest(x), cmd = a.first(x)}
      elseif a["string?"](x) then
        return parse_cmd0(str.split(x, "%s"))
      end
    end
    v_25_auto = parse_cmd0
    _1_["parse-cmd"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["parse-cmd"] = v_23_auto
  parse_cmd = v_23_auto
end
local extend_env
do
  local v_23_auto
  local function extend_env0(vars)
    local function _12_(_10_)
      local _arg_11_ = _10_
      local k = _arg_11_[1]
      local v = _arg_11_[2]
      return (k .. "=" .. v)
    end
    return a.map(_12_, a["kv-pairs"](a.merge(nvim.fn.environ(), vars)))
  end
  v_23_auto = extend_env0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["extend-env"] = v_23_auto
  extend_env = v_23_auto
end
local start
do
  local v_23_auto
  do
    local v_25_auto
    local function start0(opts)
      local stdin = uv.new_pipe(false)
      local stdout = uv.new_pipe(false)
      local stderr = uv.new_pipe(false)
      local repl = {current = nil, queue = {}}
      local function destroy()
        local function _13_()
          return stdout:read_stop()
        end
        pcall(_13_)
        local function _14_()
          return stderr:read_stop()
        end
        pcall(_14_)
        local function _15_()
          return stdout:close()
        end
        pcall(_15_)
        local function _16_()
          return stderr:close()
        end
        pcall(_16_)
        local function _17_()
          return stdin:close()
        end
        pcall(_17_)
        if repl.handle then
          local function _18_()
            return uv.process_kill(repl.handle)
          end
          pcall(_18_)
          local function _19_()
            return (repl.handle):close()
          end
          pcall(_19_)
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
              local function _22_()
                return cb({["done?"] = done_3f, [source] = result})
              end
              pcall(_22_)
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
        local _27_
        if a.get(opts0, "batch?") then
          local msgs = {}
          local function _29_(msg)
            table.insert(msgs, msg)
            if msg["done?"] then
              return cb(msgs)
            end
          end
          _27_ = _29_
        else
          _27_ = cb
        end
        table.insert(repl.queue, {cb = _27_, code = code})
        next_in_queue()
        return nil
      end
      local function send_signal(signal)
        uv.process_kill(repl.handle, signal)
        return nil
      end
      local _let_32_ = parse_cmd(opts.cmd)
      local args = _let_32_["args"]
      local cmd = _let_32_["cmd"]
      local handle, pid_or_err = uv.spawn(cmd, {args = args, env = extend_env({INPUTRC = "/dev/null"}), stdio = {stdin, stdout, stderr}}, client["schedule-wrap"](on_exit))
      if handle then
        stdout:read_start(client["schedule-wrap"](on_stdout))
        stderr:read_start(client["schedule-wrap"](on_stderr))
        local function _33_()
          return opts["on-success"]()
        end
        client.schedule(_33_)
        return a["merge!"](repl, {["send-signal"] = send_signal, destroy = destroy, handle = handle, opts = opts, pid = pid_or_err, send = send})
      else
        local function _34_()
          return opts["on-error"](pid_or_err)
        end
        client.schedule(_34_)
        return destroy()
      end
    end
    v_25_auto = start0
    _1_["start"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["start"] = v_23_auto
  start = v_23_auto
end
return nil