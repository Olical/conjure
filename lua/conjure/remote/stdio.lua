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
        return pcall(_3_)
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
            local results = str.split(chunk, opts["prompt-pattern"])
            local done_3f = (a.count(results) > 1)
            local results0 = nil
            local function _3_(_241)
              return not a["empty?"](_241)
            end
            results0 = a.filter(_3_, results)
            local result_count = a.count(results0)
            local cb = a["get-in"](repl, {"current", "cb"})
            if cb then
              local function _4_(_5_0)
                local _6_ = _5_0
                local n = _6_[1]
                local result = _6_[2]
                log.dbg("result", result)
                local function _7_()
                  return cb({["done?"] = (done_3f and (n == result_count)), [source] = result})
                end
                return pcall(_7_)
              end
              a["map-indexed"](_4_, results0)
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
      local function send(code, cb)
        table.insert(repl.queue, {cb = cb, code = code})
        next_in_queue()
        return nil
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
-- (def repl (start table: 0x7f16b0efa068)) (repl.send (+ 1 2)  (fn table: 0x7f16b0f12378 (a.println msg: msg))) (repl.send (+ 1 2)(print "Hello, World!")  (fn table: 0x7f16b0e0b4e8 (a.println msg: msg))) (repl.send (/ 1 0)(display "boundary!")  (fn table: 0x7f16b0d83868 (a.println msg: msg))) (repl.destroy)
return nil