local _2afile_2a = "fnl/conjure/process.fnl"
local _0_
do
  local name_0_ = "conjure.process"
  local module_0_
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
  do end (module_0_)["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  do end (package.loaded)[name_0_] = module_0_
  _0_ = module_0_
end
local autoload
local function _1_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _1_
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _2_(...)
local a = _local_0_[1]
local nvim = _local_0_[2]
local str = _local_0_[3]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.process"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local executable_3f
do
  local v_0_
  do
    local v_0_0
    local function executable_3f0(cmd)
      return (1 == nvim.fn.executable(a.first(str.split(cmd, "%s+"))))
    end
    v_0_0 = executable_3f0
    _0_["executable?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["executable?"] = v_0_
  executable_3f = v_0_
end
local running_3f
do
  local v_0_
  do
    local v_0_0
    local function running_3f0(proc)
      if proc then
        return proc["running?"]
      else
        return false
      end
    end
    v_0_0 = running_3f0
    _0_["running?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["running?"] = v_0_
  running_3f = v_0_
end
local state
do
  local v_0_ = ((_0_)["aniseed/locals"].state or {jobs = {}})
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["state"] = v_0_
  state = v_0_
end
local on_exit
do
  local v_0_
  do
    local v_0_0
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
    v_0_0 = on_exit0
    _0_["on-exit"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["on-exit"] = v_0_
  on_exit = v_0_
end
nvim.ex.function_(str.join("\n", {"ConjureProcessOnExit(...)", "call luaeval(\"require('conjure.process')['on-exit'](unpack(_A))\", a:000)", "endfunction"}))
local execute
do
  local v_0_
  do
    local v_0_0
    local function execute0(cmd, opts)
      local win = nvim.tabpage_get_win(0)
      local original_buf = nvim.win_get_buf(win)
      local term_buf
      local _3_
      do
        local t_0_ = opts
        if (nil ~= t_0_) then
          t_0_ = (t_0_)["hidden?"]
        end
        _3_ = t_0_
      end
      term_buf = nvim.create_buf(not _3_, true)
      local proc = {["running?"] = true, buf = term_buf, cmd = cmd, opts = opts}
      local job_id
      do
        nvim.win_set_buf(win, term_buf)
        job_id = nvim.fn.termopen(cmd, {on_exit = "ConjureProcessOnExit"})
      end
      do
        local _4_ = job_id
        if (_4_ == 0) then
          error("invalid arguments or job table full")
        elseif (_4_ == -1) then
          error(("'" .. cmd .. "' is not executable"))
        end
      end
      nvim.win_set_buf(win, original_buf)
      do end (state.jobs)[job_id] = proc
      return a.assoc(proc, "job-id", job_id)
    end
    v_0_0 = execute0
    _0_["execute"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["execute"] = v_0_
  execute = v_0_
end
local stop
do
  local v_0_
  do
    local v_0_0
    local function stop0(proc)
      if running_3f(proc) then
        nvim.fn.jobstop(proc["job-id"])
        on_exit(proc["job-id"])
      end
      return proc
    end
    v_0_0 = stop0
    _0_["stop"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["stop"] = v_0_
  stop = v_0_
end
return nil