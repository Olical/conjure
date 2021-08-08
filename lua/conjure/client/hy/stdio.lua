local _2afile_2a = "fnl/conjure/client/hy/stdio.fnl"
local _1_
do
  local name_4_auto = "conjure.client.hy.stdio"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.remote.stdio"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {["require-macros"] = {["conjure.macros"] = true}, autoload = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.config", extract = "conjure.extract", log = "conjure.log", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", stdio = "conjure.remote.stdio", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local text = _local_4_[10]
local client = _local_4_[2]
local config = _local_4_[3]
local extract = _local_4_[4]
local log = _local_4_[5]
local mapping = _local_4_[6]
local nvim = _local_4_[7]
local stdio = _local_4_[8]
local str = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client.hy.stdio"
do local _ = ({nil, _1_, nil, {{nil}, nil, nil, nil}})[2] end
config.merge({client = {hy = {stdio = {command = "hy --repl-output-fn=hy.contrib.hy-repr.hy-repr", mapping = {interrupt = "ei", start = "cs", stop = "cS"}, prompt_pattern = "=> "}}}})
local cfg
do
  local v_23_auto = config["get-in-fn"]({"client", "hy", "stdio"})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cfg"] = v_23_auto
  cfg = v_23_auto
end
local state
do
  local v_23_auto
  local function _8_()
    return {repl = nil}
  end
  v_23_auto = ((_1_)["aniseed/locals"].state or client["new-state"](_8_))
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state"] = v_23_auto
  state = v_23_auto
end
local buf_suffix
do
  local v_23_auto
  do
    local v_25_auto = ".hy"
    _1_["buf-suffix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf-suffix"] = v_23_auto
  buf_suffix = v_23_auto
end
local comment_prefix
do
  local v_23_auto
  do
    local v_25_auto = "; "
    _1_["comment-prefix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["comment-prefix"] = v_23_auto
  comment_prefix = v_23_auto
end
local with_repl_or_warn
do
  local v_23_auto
  local function with_repl_or_warn0(f, opts)
    local repl = state("repl")
    if repl then
      return f(repl)
    else
      return log.append({(comment_prefix .. "No REPL running"), (comment_prefix .. "Start REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "start"}))})
    end
  end
  v_23_auto = with_repl_or_warn0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-repl-or-warn"] = v_23_auto
  with_repl_or_warn = v_23_auto
end
local display_result
do
  local v_23_auto
  local function display_result0(msg)
    local prefix
    local _10_
    if msg.err then
      _10_ = "(err)"
    else
      _10_ = "(out)"
    end
    prefix = (comment_prefix .. _10_ .. " ")
    local function _12_(_241)
      return (prefix .. _241)
    end
    local function _13_(_241)
      return ("" ~= _241)
    end
    return log.append(a.map(_12_, a.filter(_13_, str.split((msg.err or msg.out), "\n"))))
  end
  v_23_auto = display_result0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-result"] = v_23_auto
  display_result = v_23_auto
end
local prep_code
do
  local v_23_auto
  local function prep_code0(s)
    return (s .. "\n")
  end
  v_23_auto = prep_code0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["prep-code"] = v_23_auto
  prep_code = v_23_auto
end
local eval_str
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_str0(opts)
      local last_value = nil
      local function _14_(repl)
        local function _15_(msg)
          log.dbg("msg", msg)
          local msgs
          local function _16_(_241)
            return not ("" == _241)
          end
          msgs = a.filter(_16_, str.split((msg.err or msg.out), "\n"))
          last_value = (a.last(msgs) or last_value)
          display_result(msg)
          if msg["done?"] then
            log.append({""})
            if opts["on-result"] then
              return opts["on-result"](last_value)
            end
          end
        end
        return repl.send(prep_code(opts.code), _15_)
      end
      return with_repl_or_warn(_14_)
    end
    v_25_auto = eval_str0
    _1_["eval-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-str"] = v_23_auto
  eval_str = v_23_auto
end
local eval_file
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_file0(opts)
      return log.append({(comment_prefix .. "Not implemented")})
    end
    v_25_auto = eval_file0
    _1_["eval-file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-file"] = v_23_auto
  eval_file = v_23_auto
end
local doc_str
do
  local v_23_auto
  do
    local v_25_auto
    local function doc_str0(opts)
      local obj
      if ("." == string.sub(opts.code, 1, 1)) then
        obj = extract.prompt("Specify object or module: ")
      else
      obj = nil
      end
      local obj0 = ((obj or "") .. opts.code)
      local code = ("(if (in (mangle '" .. obj0 .. ") --macros--)\n                    (doc " .. obj0 .. ")\n                    (help " .. obj0 .. "))")
      local function _20_(repl)
        local function _21_(msg)
          local _22_
          if msg.err then
            _22_ = "(err) "
          else
            _22_ = "(doc) "
          end
          return log.append(text["prefixed-lines"]((msg.err or msg.out), (comment_prefix .. _22_)))
        end
        return repl.send(prep_code(code), _21_)
      end
      return with_repl_or_warn(_20_)
    end
    v_25_auto = doc_str0
    _1_["doc-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["doc-str"] = v_23_auto
  doc_str = v_23_auto
end
local display_repl_status
do
  local v_23_auto
  local function display_repl_status0(status)
    local repl = state("repl")
    if repl then
      return log.append({(comment_prefix .. a["pr-str"](a["get-in"](repl, {"opts", "cmd"})) .. " (" .. status .. ")")}, {["break?"] = true})
    end
  end
  v_23_auto = display_repl_status0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display-repl-status"] = v_23_auto
  display_repl_status = v_23_auto
end
local stop
do
  local v_23_auto
  do
    local v_25_auto
    local function stop0()
      local repl = state("repl")
      if repl then
        repl.destroy()
        display_repl_status("stopped")
        return a.assoc(state(), "repl", nil)
      end
    end
    v_25_auto = stop0
    _1_["stop"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["stop"] = v_23_auto
  stop = v_23_auto
end
local start
do
  local v_23_auto
  do
    local v_25_auto
    local function start0()
      if state("repl") then
        return log.append({(comment_prefix .. "Can't start, REPL is already running."), (comment_prefix .. "Stop the REPL with " .. config["get-in"]({"mapping", "prefix"}) .. cfg({"mapping", "stop"}))}, {["break?"] = true})
      else
        local function _26_(err)
          return display_repl_status(err)
        end
        local function _27_(code, signal)
          if (("number" == type(code)) and (code > 0)) then
            log.append({(comment_prefix .. "process exited with code " .. code)})
          end
          if (("number" == type(signal)) and (signal > 0)) then
            log.append({(comment_prefix .. "process exited with signal " .. signal)})
          end
          return stop()
        end
        local function _30_(msg)
          return display_result(msg)
        end
        local function _31_()
          display_repl_status("started")
          local function _32_(repl)
            return repl.send(prep_code("(import sys) (setv sys.ps2 \"\") (del sys)"))
          end
          return with_repl_or_warn(_32_)
        end
        return a.assoc(state(), "repl", stdio.start({["on-error"] = _26_, ["on-exit"] = _27_, ["on-stray-output"] = _30_, ["on-success"] = _31_, ["prompt-pattern"] = cfg({"prompt_pattern"}), cmd = cfg({"command"})}))
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
local on_load
do
  local v_23_auto
  do
    local v_25_auto
    local function on_load0()
      return start()
    end
    v_25_auto = on_load0
    _1_["on-load"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-load"] = v_23_auto
  on_load = v_23_auto
end
local on_exit
do
  local v_23_auto
  do
    local v_25_auto
    local function on_exit0()
      return stop()
    end
    v_25_auto = on_exit0
    _1_["on-exit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-exit"] = v_23_auto
  on_exit = v_23_auto
end
local interrupt
do
  local v_23_auto
  do
    local v_25_auto
    local function interrupt0()
      log.dbg("sending interrupt message", "")
      local function _34_(repl)
        local uv = vim.loop
        return uv.kill(repl.pid, uv.constants.SIGINT)
      end
      return with_repl_or_warn(_34_)
    end
    v_25_auto = interrupt0
    _1_["interrupt"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["interrupt"] = v_23_auto
  interrupt = v_23_auto
end
local on_filetype
do
  local v_23_auto
  do
    local v_25_auto
    local function on_filetype0()
      mapping.buf("n", "HyStart", cfg({"mapping", "start"}), _2amodule_name_2a, "start")
      mapping.buf("n", "HyStop", cfg({"mapping", "stop"}), _2amodule_name_2a, "stop")
      return mapping.buf("n", "HyInterrupt", cfg({"mapping", "interrupt"}), _2amodule_name_2a, "interrupt")
    end
    v_25_auto = on_filetype0
    _1_["on-filetype"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-filetype"] = v_23_auto
  on_filetype = v_23_auto
end
return nil