-- [nfnl] fnl/conjure/process.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local M = define("conjure.process")
M["executable?"] = function(cmd)
  return (1 == vim.fn.executable(core.first(str.split(cmd, "%s+"))))
end
M["running?"] = function(proc)
  if proc then
    return proc["running?"]
  else
    return false
  end
end
local state = {jobs = {}}
M["on-exit"] = function(job_id)
  local proc = state.jobs[job_id]
  if M["running?"](proc) then
    core.assoc(proc, "running?", false)
    state.jobs[proc["job-id"]] = nil
    pcall(vim.api.nvim_buf_delete, proc.buf, {force = true})
    local on_exit = core["get-in"](proc, {"opts", "on-exit"})
    if on_exit then
      return on_exit(proc)
    else
      return nil
    end
  else
    return nil
  end
end
local function _5_(_241)
  return M["on-exit"](_241.args)
end
vim.api.nvim_create_user_command("ConjureProcessOnExit", _5_, {})
M.execute = function(cmd, opts)
  local win = vim.api.nvim_tabpage_get_win(0)
  local original_buf = vim.api.nvim_win_get_buf(win)
  local term_buf
  local _7_
  do
    local t_6_ = opts
    if (nil ~= t_6_) then
      t_6_ = t_6_["hidden?"]
    else
    end
    _7_ = t_6_
  end
  term_buf = vim.api.nvim_create_buf(not _7_, true)
  local proc = {cmd = cmd, buf = term_buf, ["running?"] = true, opts = opts}
  local job_id
  do
    vim.api.nvim_win_set_buf(win, term_buf)
    job_id = vim.fn.termopen(cmd, {on_exit = "ConjureProcessOnExit"})
  end
  if (job_id == 0) then
    error("invalid arguments or job table full")
  elseif (job_id == -1) then
    error(("'" .. cmd .. "' is not executable"))
  else
  end
  vim.api.nvim_win_set_buf(win, original_buf)
  state.jobs[job_id] = proc
  return core.assoc(proc, "job-id", job_id)
end
M.stop = function(proc)
  if M["running?"](proc) then
    vim.fn.jobstop(proc["job-id"])
    M["on-exit"](proc["job-id"])
  else
  end
  return proc
end
return M
