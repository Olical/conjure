local _2afile_2a = "fnl/conjure/linked-list.fnl"
local _2amodule_name_2a = "conjure.linked-list"
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
local a = autoload("conjure.aniseed.core")
do end (_2amodule_locals_2a)["a"] = a
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
_2amodule_2a["create"] = create
local function val(l)
  local _2_ = l
  if (nil ~= _2_) then
    return a.get(_2_, "val")
  else
    return _2_
  end
end
_2amodule_2a["val"] = val
local function next(l)
  local _4_ = l
  if (nil ~= _4_) then
    return a.get(_4_, "next")
  else
    return _4_
  end
end
_2amodule_2a["next"] = next
local function prev(l)
  local _6_ = l
  if (nil ~= _6_) then
    return a.get(_6_, "prev")
  else
    return _6_
  end
end
_2amodule_2a["prev"] = prev
local function first(l)
  local c = l
  while prev(c) do
    c = prev(c)
  end
  return c
end
_2amodule_2a["first"] = first
local function last(l)
  local c = l
  while next(c) do
    c = next(c)
  end
  return c
end
_2amodule_2a["last"] = last
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
_2amodule_2a["until"] = _until
local function cycle(l)
  local start = first(l)
  local _end = last(l)
  a.assoc(start, "prev", _end)
  a.assoc(_end, "next", start)
  return l
end
_2amodule_2a["cycle"] = cycle
return _2amodule_2a