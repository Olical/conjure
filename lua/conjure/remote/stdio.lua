local _0_0 = nil
do
  local name_0_ = "conjure.remote.stdio"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.log"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local client = _1_[2]
local log = _1_[3]
local nvim = _1_[4]
local str = _1_[5]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.stdio"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local uv = nil
do
  local v_0_ = vim.loop
  _0_0["aniseed/locals"]["uv"] = v_0_
  uv = v_0_
end
local parse_prompt = nil
do
  local v_0_ = nil
  local function parse_prompt0(s, pat)
    if s:find(pat) then
      return true, s:gsub(pat, "")
    else
      return false, s
    end
  end
  v_0_ = parse_prompt0
  _0_0["aniseed/locals"]["parse-prompt"] = v_0_
  parse_prompt = v_0_
end
local parse_cmd = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  _0_0["aniseed/locals"]["parse-cmd"] = v_0_
  parse_cmd = v_0_
end
local start = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function start0(opts)
      local stdin = uv.new_pipe(false)
      local stdout = uv.new_pipe(false)
      local stderr = uv.new_pipe(false)
      local repl = {current = nil, queue = {}}
      local function destroy()
        local function _3_()
          return stdin:shutdown()
        end
        pcall(_3_)
        return nil
      end
      local function on_exit(code, signal)
        local function _3_()
          stdin:close()
          stdout:close()
          stderr:close()
          return (repl.handle):close()
        end
        pcall(_3_)
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
              local function _3_()
                return cb({["done?"] = done_3f, [source] = result})
              end
              pcall(_3_)
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
        local _3_
        if a.get(opts0, "batch?") then
          local msgs = {}
          local function _5_(msg)
            table.insert(msgs, msg)
            if msg["done?"] then
              return cb(msgs)
            end
          end
          _3_ = _5_
        else
          _3_ = cb
        end
        table.insert(repl.queue, {cb = _3_, code = code})
        next_in_queue()
        return nil
      end
      local _3_ = parse_cmd(opts.cmd)
      local args = _3_["args"]
      local cmd = _3_["cmd"]
      local handle, pid = uv.spawn(cmd, {args = args, stdio = {stdin, stdout, stderr}}, client["schedule-wrap"](on_exit))
      stdout:read_start(client["schedule-wrap"](on_stdout))
      stderr:read_start(client["schedule-wrap"](on_stderr))
      local function _4_()
        return opts["on-success"]()
      end
      client.schedule(_4_)
      return a["merge!"](repl, {destroy = destroy, handle = handle, opts = opts, pid = pid, send = send})
    end
    v_0_0 = start0
    _0_0["start"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["start"] = v_0_
  start = v_0_
end
return nil