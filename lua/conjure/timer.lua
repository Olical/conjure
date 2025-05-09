-- [nfnl] fnl/conjure/timer.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local nvim = autoload("conjure.aniseed.nvim")
local function defer(f, ms)
  local t = vim.loop.new_timer()
  t:start(ms, 0, vim.schedule_wrap(f))
  return t
end
local function destroy(t)
  if t then
    t:stop()
    t:close()
  else
  end
  return nil
end
return {defer = defer, destroy = destroy}
