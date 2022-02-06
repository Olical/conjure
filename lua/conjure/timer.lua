local _2afile_2a = "fnl/conjure/timer.fnl"
local _2amodule_name_2a = "conjure.timer"
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
local a, nvim = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["nvim"] = nvim
local function defer(f, ms)
  local t = vim.loop.new_timer()
  t:start(ms, 0, vim.schedule_wrap(f))
  return t
end
_2amodule_2a["defer"] = defer
local function destroy(t)
  if t then
    t:stop()
    t:close()
  else
  end
  return nil
end
_2amodule_2a["destroy"] = destroy
return _2amodule_2a