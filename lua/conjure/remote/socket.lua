local _2afile_2a = "fnl/conjure/remote/socket.fnl"
local _1_
do
  local name_4_auto = "conjure.remote.socket"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text"}}
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
local text = _local_4_[6]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.remote.socket"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local uv
do
  local v_23_auto = vim.loop
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["uv"] = v_23_auto
  uv = v_23_auto
end
local strip_unprintable
do
  local v_23_auto
  local function strip_unprintable0(s)
    return string.gsub(text["strip-ansi-escape-sequences"](s), "[\1\2]", "")
  end
  v_23_auto = strip_unprintable0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["strip-unprintable"] = v_23_auto
  strip_unprintable = v_23_auto
end
local start
do
  local v_23_auto
  do
    local v_25_auto
    local function start0(opts)
      local repl_pipe = uv.new_pipe(true)
      local repl = {buffer = "", current = nil, queue = {}, status = "pending"}
      local function destroy()
        local function _8_()
          return repl_pipe:shutdown()
        end
        pcall(_8_)
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
          local _let_10_ = opts["parse-output"](chunk)
          local done_3f = _let_10_["done?"]
          local error_3f = _let_10_["error?"]
          local result = _let_10_["result"]
          local cb = a["get-in"](repl, {"current", "cb"}, opts["on-stray-output"])
          if error_3f then
            opts["on-error"]({["done?"] = done_3f, err = repl.buffer}, repl)
          end
          if done_3f then
            if cb then
              local function _12_()
                return cb({["done?"] = done_3f, out = result})
              end
              pcall(_12_)
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
        local _17_
        if a.get(opts0, "batch?") then
          local msgs = {}
          local function _19_(msg)
            table.insert(msgs, msg)
            if msg["done?"] then
              return cb(msgs)
            end
          end
          _17_ = _19_
        else
          _17_ = cb
        end
        table.insert(repl.queue, {cb = _17_, code = code})
        next_in_queue()
        return nil
      end
      if opts.pipename then
        local function _22_(err)
          if err then
            return opts["on-failure"](a["merge!"](repl, {err = err, status = "failed"}))
          else
            opts["on-success"](a.assoc(repl, "status", "connected"))
            local function _23_(err0, chunk)
              return on_output(err0, chunk)
            end
            return repl_pipe:read_start(client["schedule-wrap"](_23_))
          end
        end
        uv.pipe_connect(repl_pipe, opts.pipename, client["schedule-wrap"](_22_))
      else
        nvim.err_writeln((_2amodule_name_2a .. ": No pipename specified"))
      end
      return a["merge!"](repl, {destroy = destroy, opts = opts, send = send})
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