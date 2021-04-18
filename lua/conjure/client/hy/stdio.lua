local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.hy.stdio"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.extract"), require("conjure.log"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.remote.stdio"), require("conjure.aniseed.string"), require("conjure.text")}
local a = _local_0_[1]
local text = _local_0_[10]
local client = _local_0_[2]
local config = _local_0_[3]
local extract = _local_0_[4]
local log = _local_0_[5]
local mapping = _local_0_[6]
local nvim = _local_0_[7]
local stdio = _local_0_[8]
local str = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.hy.stdio"
do local _ = ({nil, _0_0, {{nil}, nil, nil, nil}})[2] end
config.merge({client = {hy = {stdio = {command = "hy --repl-output-fn=hy.contrib.hy-repr.hy-repr", mapping = {interrupt = "ei", start = "cs", stop = "cS"}, prompt_pattern = "=> "}}}})
local cfg = config["get-in-fn"]({"client", "hy", "stdio"})
local state
local function _1_()
  return {repl = nil}
end
state = client["new-state"](_1_)
local buf_suffix
do
  local v_0_ = ".hy"
  _0_0["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local comment_prefix
do
  local v_0_ = "; "
  _0_0["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
local function with_repl_or_warn(f, opts)
  local repl = state("repl")
  if repl then
    return f(repl)
  else
    return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
  end
end
local function display_result(msg)
  local prefix
  local _2_
  if msg.err then
    _2_ = "(err)"
  else
    _2_ = "(out)"
  end
  prefix = (comment_prefix .. _2_ .. " ")
  local function _4_(_241)
    return (prefix .. _241)
  end
  local function _5_(_241)
    return ("" ~= _241)
  end
  return log.append(a.map(_4_, a.filter(_5_, str.split((msg.err or msg.out), "\n"))))
end
local function prep_code(s)
  return (s .. "\n")
end
local eval_str
do
  local v_0_
  local function eval_str0(opts)
    local last_value = nil
    local function _2_(repl)
      local function _3_(msg)
        log.dbg("msg", msg)
        local msgs
        local function _4_(_241)
          return not ("" == _241)
        end
        msgs = a.filter(_4_, str.split((msg.err or msg.out), "\n"))
        last_value = (a.last(msgs) or last_value)
        display_result(msg)
        if msg["done?"] then
          log.append({""})
          if opts["on-result"] then
            return opts["on-result"](last_value)
          end
        end
      end
      return repl.send(prep_code(opts.code), _3_)
    end
    return with_repl_or_warn(_2_)
  end
  v_0_ = eval_str0
  _0_0["eval-str"] = v_0_
  eval_str = v_0_
end
local eval_file
do
  local v_0_
  local function eval_file0(opts)
    return log.append({(comment_prefix .. "Not implemented")})
  end
  v_0_ = eval_file0
  _0_0["eval-file"] = v_0_
  eval_file = v_0_
end
local doc_str
do
  local v_0_
  local function doc_str0(opts)
    local obj
    if ("." == string.sub(opts.code, 1, 1)) then
      obj = extract.prompt("Specify object or module: ")
    else
    obj = nil
    end
    local obj0 = ((obj or "") .. opts.code)
    local code = ("(if (in (mangle '" .. obj0 .. ") --macros--)\n                    (doc " .. obj0 .. ")\n                    (help " .. obj0 .. "))")
    local function _3_(repl)
      local function _4_(msg)
        local function _5_()
          if msg.err then
            return "(err) "
          else
            return "(doc) "
          end
        end
        return log.append(text["prefixed-lines"]((msg.err or msg.out), (comment_prefix .. _5_())))
      end
      return repl.send(prep_code(code), _4_)
    end
    return with_repl_or_warn(_3_)
  end
  v_0_ = doc_str0
  _0_0["doc-str"] = v_0_
  doc_str = v_0_
end
local function display_repl_status(status)
  local repl = state("repl")
  if repl then
    return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
  end
end
local stop
do
  local v_0_
  local function stop0()
    local repl = state("repl")
    if repl then
      repl.destroy()
      display_repl_status("stopped")
      return a.assoc(state(), "repl", nil)
    end
  end
  v_0_ = stop0
  _0_0["stop"] = v_0_
  stop = v_0_
end
local start
do
  local v_0_
  local function start0()
    if state("repl") then
      return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
    else
      local function _2_(err)
        return display_repl_status(err)
      end
      local function _3_(code, signal)
        if (("number" == type(code)) and (code > 0)) then
          log.append({(comment_prefix .. "process exited with code " .. code)})
        end
        if (("number" == type(signal)) and (signal > 0)) then
          log.append({(comment_prefix .. "process exited with signal " .. signal)})
        end
        return stop()
      end
      local function _4_(msg)
        return display_result(msg)
      end
      local function _5_()
        display_repl_status("started")
        local function _6_(repl)
          return repl.send(prep_code("(import sys) (setv sys.ps2 \"\") (del sys)"))
        end
        return with_repl_or_warn(_6_)
      end
      return a.assoc(state(), "repl", stdio.start({["on-error"] = _2_, ["on-exit"] = _3_, ["on-stray-output"] = _4_, ["on-success"] = _5_, ["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"})}))
    end
  end
  v_0_ = start0
  _0_0["start"] = v_0_
  start = v_0_
end
local on_load
do
  local v_0_
  local function on_load0()
    return start()
  end
  v_0_ = on_load0
  _0_0["on-load"] = v_0_
  on_load = v_0_
end
local on_exit
do
  local v_0_
  local function on_exit0()
    return stop()
  end
  v_0_ = on_exit0
  _0_0["on-exit"] = v_0_
  on_exit = v_0_
end
local interrupt
do
  local v_0_
  local function interrupt0()
    log.dbg("sending interrupt message", "")
    local function _2_(repl)
      local uv = vim.loop
      return uv.kill(repl.pid, uv.constants.SIGINT)
    end
    return with_repl_or_warn(_2_)
  end
  v_0_ = interrupt0
  _0_0["interrupt"] = v_0_
  interrupt = v_0_
end
local on_filetype
do
  local v_0_
  local function on_filetype0()
    mapping.buf("n", "HyStart", cfg({"mapping", "start"}), _2amodule_name_2a, "start")
    mapping.buf("n", "HyStop", cfg({"mapping", "stop"}), _2amodule_name_2a, "stop")
    return mapping.buf("n", "HyInterrupt", cfg({"mapping", "interrupt"}), _2amodule_name_2a, "interrupt")
  end
  v_0_ = on_filetype0
  _0_0["on-filetype"] = v_0_
  on_filetype = v_0_
end
return nil