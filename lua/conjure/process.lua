local _2afile_2a = "fnl/conjure/process.fnl"
local _1_
do
  local name_4_auto = "conjure.process"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local nvim = _local_4_[2]
local str = _local_4_[3]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.process"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local executable_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function executable_3f0(cmd)
      return (1 == nvim.fn.executable(a.first(str.split(cmd, "%s+"))))
    end
    v_25_auto = executable_3f0
    _1_["executable?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["executable?"] = v_23_auto
  executable_3f = v_23_auto
end
local running_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function running_3f0(proc)
      if proc then
        return proc["running?"]
      else
        return false
      end
    end
    v_25_auto = running_3f0
    _1_["running?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["running?"] = v_23_auto
  running_3f = v_23_auto
end
local state
do
  local v_23_auto = ((_1_)["aniseed/locals"].state or {jobs = {}})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["state"] = v_23_auto
  state = v_23_auto
end
local on_exit
do
  local v_23_auto
  do
    local v_25_auto
    local function on_exit0(job_id)
      local proc = state.jobs[job_id]
      if running_3f(proc) then
        a.assoc(proc, "running?", false)
        do end (state.jobs)[proc["job-id"]] = nil
        pcall(nvim.buf_delete, proc.buf, {force = true})
        local on_exit1 = a["get-in"](proc, {"opts", "on-exit"})
        if on_exit1 then
          return on_exit1(proc)
        end
      end
    end
    v_25_auto = on_exit0
    _1_["on-exit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-exit"] = v_23_auto
  on_exit = v_23_auto
end
nvim.ex.function_(str.join("\n", {"ConjureProcessOnExit(...)", "call luaeval(\"require('conjure.process')['on-exit'](unpack(_A))\", a:000)", "endfunction"}))
local execute
do
  local v_23_auto
  do
    local v_25_auto
    local function execute0(cmd, opts)
      local win = nvim.tabpage_get_win(0)
      local original_buf = nvim.win_get_buf(win)
      local term_buf
      local _12_
      do
        local t_11_ = opts
        if (nil ~= t_11_) then
          t_11_ = (t_11_)["hidden?"]
        end
        _12_ = t_11_
      end
      term_buf = nvim.create_buf(not _12_, true)
      local proc = {["running?"] = true, buf = term_buf, cmd = cmd, opts = opts}
      local job_id
      do
        nvim.win_set_buf(win, term_buf)
        job_id = nvim.fn.termopen(cmd, {on_exit = "ConjureProcessOnExit"})
      end
      do
        local _14_ = job_id
        if (_14_ == 0) then
          error("invalid arguments or job table full")
        elseif (_14_ == -1) then
          error(("'" .. cmd .. "' is not executable"))
        end
      end
      nvim.win_set_buf(win, original_buf)
      do end (state.jobs)[job_id] = proc
      return a.assoc(proc, "job-id", job_id)
    end
    v_25_auto = execute0
    _1_["execute"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["execute"] = v_23_auto
  execute = v_23_auto
end
local stop
do
  local v_23_auto
  do
    local v_25_auto
    local function stop0(proc)
      if running_3f(proc) then
        nvim.fn.jobstop(proc["job-id"])
        on_exit(proc["job-id"])
      end
      return proc
    end
    v_25_auto = stop0
    _1_["stop"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["stop"] = v_23_auto
  stop = v_23_auto
end
return nil