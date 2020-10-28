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
    return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.log"), require("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", nvim = "conjure.aniseed.nvim"}}
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
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.stdio"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local uv = nil
do
  local v_0_ = vim.loop
  _0_0["aniseed/locals"]["uv"] = v_0_
  uv = v_0_
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
      local repl = {queue = {}}
      local function destroy()
        return stdin:shutdown()
      end
      local function on_exit(code, signal)
        stdin:close()
        stdout:close()
        stderr:close()
        return (repl.handle):close()
      end
      local function on_stdout(err, chunk)
        return a.println("out:", err, "-", chunk)
      end
      local function on_stderr(err, chunk)
        return a.println("err:", err, "-", chunk)
      end
      local function send(msg, cb)
        table.insert(repl.queue, cb)
        log.dbg("send", msg)
        return stdin:write(msg)
      end
      local handle, pid = uv.spawn(opts.cmd, {stdio = {stdin, stdout, stderr}}, client.wrap(on_exit))
      stdout:read_start(client.wrap(on_stdout))
      stderr:read_start(client.wrap(on_stderr))
      return a["merge!"](repl, {destroy = destroy, handle = handle, pid = pid, send = send})
    end
    v_0_0 = start0
    _0_0["start"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["start"] = v_0_
  start = v_0_
end
-- (def repl (start table: 0x7f489e6c87f0)) (repl.send (+ 1 2)  (fn table: 0x7f489e4e3a88 (a.println msg: msg))) (repl.destroy)
return nil