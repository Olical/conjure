local _0_0 = nil
do
  local name_0_ = "conjure.remote.socket"
  local module_0_ = nil
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
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.log"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string"), require("conjure.text")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text"}}
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
local text = _local_0_[6]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.socket"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local uv = nil
do
  local v_0_ = vim.loop
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["uv"] = v_0_
  uv = v_0_
end
local strip_unprintable = nil
do
  local v_0_ = nil
  local function strip_unprintable0(s)
    return string.gsub(text["strip-ansi-escape-sequences"](s), "[\1\2]", "")
  end
  v_0_ = strip_unprintable0
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["strip-unprintable"] = v_0_
  strip_unprintable = v_0_
end
local start = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function start0(opts)
      local repl_pipe = uv.new_pipe(true)
      local repl = {buffer = "", current = nil, queue = {}, status = "pending"}
      local function destroy()
        local function _2_()
          return repl_pipe:shutdown()
        end
        pcall(_2_)
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
              local function _3_()
                return cb({["done?"] = done_3f, out = result})
              end
              pcall(_3_)
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
      if opts.pipename then
        local function _2_(err)
          if err then
            return opts["on-failure"](a["merge!"](repl, {err = err, status = "failed"}))
          else
            opts["on-success"](a.assoc(repl, "status", "connected"))
            local function _3_(err0, chunk)
              return on_output(err0, chunk)
            end
            return repl_pipe:read_start(client["schedule-wrap"](_3_))
          end
        end
        uv.pipe_connect(repl_pipe, opts.pipename, client["schedule-wrap"](_2_))
      else
        nvim.err_writeln((_2amodule_name_2a .. ": No pipename specified"))
      end
      return a["merge!"](repl, {destroy = destroy, opts = opts, send = send})
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