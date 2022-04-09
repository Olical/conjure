local _2afile_2a = "fnl/conjure/process.fnl"
local _2amodule_name_2a = "conjure.process"
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
local a, nvim, str = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
local function executable_3f(cmd)
  return (1 == nvim.fn.executable(a.first(str.split(cmd, "%s+"))))
end
_2amodule_2a["executable?"] = executable_3f
local function running_3f(proc)
  if proc then
    return proc["running?"]
  else
    return false
  end
end
_2amodule_2a["running?"] = running_3f
local state = ((_2amodule_2a).state or {jobs = {}})
do end (_2amodule_locals_2a)["state"] = state
local function on_exit(job_id)
  local proc = state.jobs[job_id]
  if running_3f(proc) then
    a.assoc(proc, "running?", false)
    do end (state.jobs)[proc["job-id"]] = nil
    pcall(nvim.buf_delete, proc.buf, {force = true})
    local on_exit0 = a["get-in"](proc, {"opts", "on-exit"})
    if on_exit0 then
      return on_exit0(proc)
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_2a["on-exit"] = on_exit
nvim.ex.function_(str.join("\n", {"ConjureProcessOnExit(...)", "call luaeval(\"require('conjure.process')['on-exit'](unpack(_A))\", a:000)", "endfunction"}))
local function execute(cmd, opts)
  local win = nvim.tabpage_get_win(0)
  local original_buf = nvim.win_get_buf(win)
  local term_buf
  local _5_
  do
    local t_4_ = opts
    if (nil ~= t_4_) then
      t_4_ = (t_4_)["hidden?"]
    else
    end
    _5_ = t_4_
  end
  term_buf = nvim.create_buf(not _5_, true)
  local proc = {cmd = cmd, buf = term_buf, ["running?"] = true, opts = opts}
  local job_id
  do
    nvim.win_set_buf(win, term_buf)
    job_id = nvim.fn.termopen(cmd, {on_exit = "ConjureProcessOnExit"})
  end
  do
    local _7_ = job_id
    if (_7_ == 0) then
      error("invalid arguments or job table full")
    elseif (_7_ == -1) then
      error(("'" .. cmd .. "' is not executable"))
    else
    end
  end
  nvim.win_set_buf(win, original_buf)
  do end (state.jobs)[job_id] = proc
  return a.assoc(proc, "job-id", job_id)
end
_2amodule_2a["execute"] = execute
local function stop(proc)
  if running_3f(proc) then
    nvim.fn.jobstop(proc["job-id"])
    on_exit(proc["job-id"])
  else
  end
  return proc
end
_2amodule_2a["stop"] = stop
return _2amodule_2a