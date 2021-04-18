local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.remote.socket"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.log"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string"), require("conjure.text")}
local a = _local_0_[1]
local client = _local_0_[2]
local log = _local_0_[3]
local nvim = _local_0_[4]
local str = _local_0_[5]
local text = _local_0_[6]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.socket"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local uv = vim.loop
local function strip_unprintable(s)
  return string.gsub(text["strip-ansi-escape-sequences"](s), "[\1\2]", "")
end
local start
do
  local v_0_
  local function start0(opts)
    local repl_pipe = uv.new_pipe(true)
    local repl = {buffer = "", current = nil, queue = {}, status = "pending"}
    local function destroy()
      local function _1_()
        return repl_pipe:shutdown()
      end
      pcall(_1_)
      return nil
    end
    local function next_in_queue()
      local next_msg = a.first(repl.queue)
      if (next_msg and not repl.current) then
        table.remove(repl.queue, 1)
        a.assoc(repl, "current", next_msg)
        log.dbg("send", next_msg.code)
        return repl_pipe:write((next_msg.code .. "\n"))
      end
    end
    local function on_message(chunk)
      log.dbg("receive", chunk)
      if chunk then
        local _let_0_ = opts["parse-output"](chunk)
        local done_3f = _let_0_["done?"]
        local error_3f = _let_0_["error?"]
        local result = _let_0_["result"]
        local cb = a["get-in"](repl, {"current", "cb"}, opts["on-stray-output"])
        if error_3f then
          opts["on-error"]({["done?"] = done_3f, err = repl.buffer}, repl)
        end
        if done_3f then
          if cb then
            local function _2_()
              return cb({["done?"] = done_3f, out = result})
            end
            pcall(_2_)
          end
          a.assoc(repl, "current", nil)
          a.assoc(repl, "buffer", "")
          return next_in_queue()
        end
      end
    end
    local function on_output(err, chunk)
      if err then
        return opts["on-failure"](a["merge!"](repl, {err = err, status = "failed"}))
      elseif chunk then
        a.assoc(repl, "buffer", (a.get(repl, "buffer") .. chunk))
        return on_message(strip_unprintable(a.get(repl, "buffer")))
      else
        return opts["on-close"](a.assoc(repl, "status", "closed"))
      end
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
    if opts.pipename then
      local function _1_(err)
        if err then
          return opts["on-failure"](a["merge!"](repl, {err = err, status = "failed"}))
        else
          opts["on-success"](a.assoc(repl, "status", "connected"))
          local function _2_(err0, chunk)
            return on_output(err0, chunk)
          end
          return repl_pipe:read_start(client["schedule-wrap"](_2_))
        end
      end
      uv.pipe_connect(repl_pipe, opts.pipename, client["schedule-wrap"](_1_))
    else
      nvim.err_writeln((_2amodule_name_2a .. ": No pipename specified"))
    end
    return a["merge!"](repl, {destroy = destroy, opts = opts, send = send})
  end
  v_0_ = start0
  _0_0["start"] = v_0_
  start = v_0_
end
return nil