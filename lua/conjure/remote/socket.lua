local _2afile_2a = "fnl/conjure/remote/socket.fnl"
local _2amodule_name_2a = "conjure.remote.socket"
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
local a, client, log, nvim, str, text = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
local uv = vim.loop
_2amodule_locals_2a["uv"] = uv
local function strip_unprintable(s)
  return string.gsub(text["strip-ansi-escape-sequences"](s), "[\1\2]", "")
end
_2amodule_locals_2a["strip-unprintable"] = strip_unprintable
local function start(opts)
  local repl_pipe = uv.new_pipe(true)
  local repl = {status = "pending", queue = {}, current = nil, buffer = ""}
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
    else
      return nil
    end
  end
  local function on_message(chunk)
    log.dbg("receive", chunk)
    if chunk then
      local _let_3_ = opts["parse-output"](chunk)
      local done_3f = _let_3_["done?"]
      local error_3f = _let_3_["error?"]
      local result = _let_3_["result"]
      local cb = a["get-in"](repl, {"current", "cb"}, opts["on-stray-output"])
      if error_3f then
        opts["on-error"]({err = repl.buffer, ["done?"] = done_3f}, repl)
      else
      end
      if done_3f then
        if cb then
          local function _5_()
            return cb({out = result, ["done?"] = done_3f})
          end
          pcall(_5_)
        else
        end
        a.assoc(repl, "current", nil)
        a.assoc(repl, "buffer", "")
        return next_in_queue()
      else
        return nil
      end
    else
      return nil
    end
  end
  local function on_output(err, chunk)
    if err then
      return opts["on-failure"](a["merge!"](repl, {status = "failed", err = err}))
    elseif chunk then
      a.assoc(repl, "buffer", (a.get(repl, "buffer") .. chunk))
      return on_message(strip_unprintable(a.get(repl, "buffer")))
    else
      return opts["on-close"](a.assoc(repl, "status", "closed"))
    end
  end
  local function send(code, cb, opts0)
    local _10_
    if a.get(opts0, "batch?") then
      local msgs = {}
      local function _12_(msg)
        table.insert(msgs, msg)
        if msg["done?"] then
          return cb(msgs)
        else
          return nil
        end
      end
      _10_ = _12_
    else
      _10_ = cb
    end
    table.insert(repl.queue, {code = code, cb = _10_})
    next_in_queue()
    return nil
  end
  if opts.pipename then
    local function _15_(err)
      if err then
        return opts["on-failure"](a["merge!"](repl, {status = "failed", err = err}))
      else
        opts["on-success"](a.assoc(repl, "status", "connected"))
        local function _16_(err0, chunk)
          return on_output(err0, chunk)
        end
        return repl_pipe:read_start(client["schedule-wrap"](_16_))
      end
    end
    uv.pipe_connect(repl_pipe, opts.pipename, client["schedule-wrap"](_15_))
  else
    nvim.err_writeln((_2amodule_name_2a .. ": No pipename specified"))
  end
  return a["merge!"](repl, {opts = opts, destroy = destroy, send = send})
end
_2amodule_2a["start"] = start
return _2amodule_2a