-- [nfnl] fnl/conjure/timer.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_["define"]
local M = define("conjure.timer")
M.defer = function(f, ms)
  local t = vim.uv.new_timer()
  t:start(ms, 0, vim.schedule_wrap(f))
  return t
end
M.destroy = function(t)
  if t then
    t:stop()
    t:close()
  else
  end
  return nil
end
return M
