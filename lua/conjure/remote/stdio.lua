local _0_0
do
  local name_0_ = "conjure.remote.stdio"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local client = _local_0_[2]
local log = _local_0_[3]
local nvim = _local_0_[4]
local str = _local_0_[5]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.stdio"
do local _ = ({nil, _0_0, nil, {{}, nil, nil, nil}})[2] end
local uv
do
  local v_0_ = vim.loop
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["uv"] = v_0_
  uv = v_0_
end
local parse_prompt
do
  local v_0_
  local function parse_prompt0(s, pat)
    if s:find(pat) then
      return true, s:gsub(pat, "")
    else
      return false, s
    end
  end
  v_0_ = parse_prompt0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["parse-prompt"] = v_0_
  parse_prompt = v_0_
end
local parse_cmd
do
  local v_0_
  do
    local v_0_0
    local function parse_cmd0(x)
      if a["table?"](x) then
        return {args = a.rest(x), cmd = a.first(x)}
      elseif a["string?"](x) then
        return parse_cmd0(str.split(x, "%s"))
      end
    end
    v_0_0 = parse_cmd0
    _0_0["parse-cmd"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["parse-cmd"] = v_0_
  parse_cmd = v_0_
end
local extend_env
do
  local v_0_
  local function extend_env0(vars)
    local function _3_(_2_0)
      local _arg_0_ = _2_0
      local k = _arg_0_[1]
      local v = _arg_0_[2]
      return (k .. "=" .. v)
    end
    return a.map(_3_, a["kv-pairs"](a.merge(nvim.fn.environ(), vars)))
  end
  v_0_ = extend_env0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["extend-env"] = v_0_
  extend_env = v_0_
end
local start
do
  local v_0_
  do
    local v_0_0
    local function start0(opts)
      local stdin = uv.new_pipe(false)
      local stdout = uv.new_pipe(false)
      local stderr = uv.new_pipe(false)
      local repl = {current = nil, queue = {}}
      local function destroy()
        local function _2_()
          return stdout:read_stop()
        end
        pcall(_2_)
        local function _3_()
          return stderr:read_stop()
        end
        pcall(_3_)
        local function _4_()
          return stdout:close()
        end
        pcall(_4_)
        local function _5_()
          return stderr:close()
        end
        pcall(_5_)
        local function _6_()
          return stdin:close()
        end
        pcall(_6_)
        if repl.handle then
          local function _7_()
            return uv.process_kill(repl.handle)
          end
          pcall(_7_)
          local function _8_()
            return (repl.handle):close()
          end
          pcall(_8_)
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
              local function _2_()
                return cb({["done?"] = done_3f, [source] = result})
              end
              pcall(_2_)
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
        local _2_
        if a.get(opts0, "batch?") then
          local msgs = {}
          local function _4_(msg)
            table.insert(msgs, msg)
            if msg["done?"] then
              return cb(msgs)
            end
          end
          _2_ = _4_
        else
          _2_ = cb
        end
        table.insert(repl.queue, {cb = _2_, code = code})
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
        local function _2_()
          return opts["on-success"]()
        end
        client.schedule(_2_)
        return a["merge!"](repl, {destroy = destroy, handle = handle, opts = opts, pid = pid_or_err, send = send})
      else
        local function _2_()
          return opts["on-error"](pid_or_err)
        end
        client.schedule(_2_)
        return destroy()
      end
    end
    v_0_0 = start0
    _0_0["start"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["start"] = v_0_
  start = v_0_
end
return nil