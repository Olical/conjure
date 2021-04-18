local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.fennel.stdio"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.config"), require("conjure.log"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.remote.stdio"), require("conjure.aniseed.string"), require("conjure.text")}
local a = _local_0_[1]
local client = _local_0_[2]
local config = _local_0_[3]
local log = _local_0_[4]
local mapping = _local_0_[5]
local nvim = _local_0_[6]
local stdio = _local_0_[7]
local str = _local_0_[8]
local text = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.fennel.stdio"
do local _ = ({nil, _0_0, {{nil}, nil, nil, nil}})[2] end
config.merge({client = {fennel = {stdio = {command = "fennel", mapping = {eval_reload = "eF", start = "cs", stop = "cS"}, prompt_pattern = ">> "}}}})
local cfg = config["get-in-fn"]({"client", "fennel", "stdio"})
local state
local function _1_()
  return {repl = nil}
end
state = client["new-state"](_1_)
local buf_suffix
do
  local v_0_ = ".fnl"
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
    return log.append({(comment_prefix .. "No REPL running")})
  end
end
local function format_message(msg)
  return str.split((msg.out or msg.err), "\n")
end
local function display_result(msg)
  local function _2_(_241)
    return not ("" == _241)
  end
  return log.append(a.filter(_2_, format_message(msg)))
end
local eval_str
do
  local v_0_
  local function eval_str0(opts)
    local function _2_(repl)
      local function _3_(msgs)
        if ((1 == a.count(msgs)) and ("" == a["get-in"](msgs, {1, "out"}))) then
          a["assoc-in"](msgs, {1, "out"}, (comment_prefix .. "Empty result."))
        end
        local msgs0
        local function _5_(_241)
          return (".." ~= (_241).out)
        end
        msgs0 = a.filter(_5_, msgs)
        if opts["on-result"] then
          opts["on-result"](str.join("\n", format_message(a.last(msgs0))))
        end
        return a["run!"](display_result, msgs0)
      end
      return repl.send((opts.code .. "\n"), _3_, {["batch?"] = true})
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
    return eval_str(a.assoc(opts, "code", a.slurp(opts["file-path"])))
  end
  v_0_ = eval_file0
  _0_0["eval-file"] = v_0_
  eval_file = v_0_
end
local eval_reload
do
  local v_0_
  local function eval_reload0()
    local file_path = nvim.fn.expand("%")
    local module_path = nvim.fn.fnamemodify(file_path, ":.:r")
    log.append({(comment_prefix .. ",reload " .. module_path)}, {["break?"] = true})
    return eval_str({["file-path"] = file_path, action = "eval", code = (",reload " .. module_path), origin = "reload"})
  end
  v_0_ = eval_reload0
  _0_0["eval-reload"] = v_0_
  eval_reload = v_0_
end
local doc_str
do
  local v_0_
  local function doc_str0(opts)
    local function _2_(_241)
      return ("(doc " .. _241 .. ")\n")
    end
    return eval_str(a.update(opts, "code", _2_))
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
        return display_repl_status("started")
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
local on_filetype
do
  local v_0_
  local function on_filetype0()
    mapping.buf("n", "FnlStart", cfg({"mapping", "start"}), _2amodule_name_2a, "start")
    mapping.buf("n", "FnlStop", cfg({"mapping", "stop"}), _2amodule_name_2a, "stop")
    return mapping.buf("n", "FnlEvalReload", cfg({"mapping", "eval_reload"}), _2amodule_name_2a, "eval-reload")
  end
  v_0_ = on_filetype0
  _0_0["on-filetype"] = v_0_
  on_filetype = v_0_
end
return nil