-- [nfnl] Compiled from fnl/conjure/stack.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local function push(s, v)
  table.insert(s, v)
  return s
end
local function pop(s)
  table.remove(s)
  return s
end
local function peek(s)
  return a.last(s)
end
return {push = push, pop = pop, peek = peek}
