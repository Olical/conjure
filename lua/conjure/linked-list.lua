-- [nfnl] fnl/conjure/linked-list.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local M = define("conjure.linked-list")
M.create = function(xs, prev)
  if not core["empty?"](xs) then
    local rest = core.rest(xs)
    local node = {}
    core.assoc(node, "val", core.first(xs))
    core.assoc(node, "prev", prev)
    return core.assoc(node, "next", M.create(rest, node))
  else
    return nil
  end
end
M.val = function(l)
  if (nil ~= l) then
    return core.get(l, "val")
  else
    return nil
  end
end
M.next = function(l)
  if (nil ~= l) then
    return core.get(l, "next")
  else
    return nil
  end
end
M.prev = function(l)
  if (nil ~= l) then
    return core.get(l, "prev")
  else
    return nil
  end
end
M.first = function(l)
  local c = l
  while M.prev(c) do
    c = M.prev(c)
  end
  return c
end
M.last = function(l)
  local c = l
  while M.next(c) do
    c = M.next(c)
  end
  return c
end
M["until"] = function(f, l)
  local c = l
  local r = false
  local function step()
    r = f(c)
    return r
  end
  while (c and not step()) do
    c = M.next(c)
  end
  if r then
    return c
  else
    return nil
  end
end
M.cycle = function(l)
  local start = M.first(l)
  local _end = M.last(l)
  core.assoc(start, "prev", _end)
  core.assoc(_end, "next", start)
  return l
end
return M
