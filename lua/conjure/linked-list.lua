-- [nfnl] Compiled from fnl/conjure/linked-list.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local function create(xs, prev)
  if not a["empty?"](xs) then
    local rest = a.rest(xs)
    local node = {}
    a.assoc(node, "val", a.first(xs))
    a.assoc(node, "prev", prev)
    return a.assoc(node, "next", create(rest, node))
  else
    return nil
  end
end
local function val(l)
  if (nil ~= l) then
    return a.get(l, "val")
  else
    return nil
  end
end
local function next(l)
  if (nil ~= l) then
    return a.get(l, "next")
  else
    return nil
  end
end
local function prev(l)
  if (nil ~= l) then
    return a.get(l, "prev")
  else
    return nil
  end
end
local function first(l)
  local c = l
  while prev(c) do
    c = prev(c)
  end
  return c
end
local function last(l)
  local c = l
  while next(c) do
    c = next(c)
  end
  return c
end
local function _until(f, l)
  local c = l
  local r = false
  local function step()
    r = f(c)
    return r
  end
  while (c and not step()) do
    c = next(c)
  end
  if r then
    return c
  else
    return nil
  end
end
local function cycle(l)
  local start = first(l)
  local _end = last(l)
  a.assoc(start, "prev", _end)
  a.assoc(_end, "next", start)
  return l
end
return {create = create, val = val, next = next, prev = prev, first = first, last = last, ["until"] = _until, cycle = cycle}
