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
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_ = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local nvim = _local_0_[2]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.process"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local executable_3f
do
  local v_0_
  do
    local v_0_0
    local function executable_3f0(name)
      return (1 == nvim.fn.executable(name))
    end
    v_0_0 = executable_3f0
    _0_["executable?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["executable?"] = v_0_
  executable_3f = v_0_
end
-- (executable? bb) (executable? nope-this-doesnt)
local running_3f
do
  local v_0_
  do
    local v_0_0
    local function running_3f0(proc)
      return proc["running?"]
    end
    v_0_0 = running_3f0
    _0_["running?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["running?"] = v_0_
  running_3f = v_0_
end
local on_exit
do
  local v_0_
  local function on_exit0(proc)
    if running_3f(proc) then
      a.assoc(proc, "running?", false)
      return pcall(nvim.buf_delete, proc.buf, {force = true})
    end
  end
  v_0_ = on_exit0
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["on-exit"] = v_0_
  on_exit = v_0_
end
local execute
do
  local v_0_
  do
    local v_0_0
    local function execute0(cmd)
      local win = nvim.tabpage_get_win(0)
      local original_buf = nvim.win_get_buf(win)
      local term_buf = nvim.create_buf(true, true)
      local res = {["running?"] = true, buf = term_buf, cmd = cmd}
      local opts
      local function _2_()
        return on_exit(res)
      end
      opts = {on_exit = _2_}
      nvim.win_set_buf(win, term_buf)
      local job_id = nvim.fn.termopen(cmd, opts)
      do
        local _3_ = job_id
        if (_3_ == 0) then
          error("invalid arguments or job table full")
        elseif (_3_ == -1) then
          error(("'" .. cmd .. "' is not executable"))
        end
      end
      nvim.win_set_buf(win, original_buf)
      return a.assoc(res, "job-id", job_id)
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
        on_exit(proc)
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
-- (def bb (execute bb nrepl-server)) (stop bb)
return nil