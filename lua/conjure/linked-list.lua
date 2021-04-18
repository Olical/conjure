local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.linked-list"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core")}
local a = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.linked-list"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local create
do
  local v_0_
  local function create0(xs, prev)
    if not a["empty?"](xs) then
      local rest = a.rest(xs)
      local node = {}
      a.assoc(node, "val", a.first(xs))
      a.assoc(node, "prev", prev)
      return a.assoc(node, "next", create0(rest, node))
    end
  end
  v_0_ = create0
  _0_0["create"] = v_0_
  create = v_0_
end
local val
do
  local v_0_
  local function val0(l)
    local _1_0 = l
    if _1_0 then
      return a.get(_1_0, "val")
    else
      return _1_0
    end
  end
  v_0_ = val0
  _0_0["val"] = v_0_
  val = v_0_
end
local next
do
  local v_0_
  local function next0(l)
    local _1_0 = l
    if _1_0 then
      return a.get(_1_0, "next")
    else
      return _1_0
    end
  end
  v_0_ = next0
  _0_0["next"] = v_0_
  next = v_0_
end
local prev
do
  local v_0_
  local function prev0(l)
    local _1_0 = l
    if _1_0 then
      return a.get(_1_0, "prev")
    else
      return _1_0
    end
  end
  v_0_ = prev0
  _0_0["prev"] = v_0_
  prev = v_0_
end
local first
do
  local v_0_
  local function first0(l)
    local c = l
    while prev(c) do
      c = prev(c)
    end
    return c
  end
  v_0_ = first0
  _0_0["first"] = v_0_
  first = v_0_
end
local last
do
  local v_0_
  local function last0(l)
    local c = l
    while next(c) do
      c = next(c)
    end
    return c
  end
  v_0_ = last0
  _0_0["last"] = v_0_
  last = v_0_
end
local _until
do
  local v_0_
  local function _until0(f, l)
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
    end
  end
  v_0_ = _until0
  _0_0["until"] = v_0_
  _until = v_0_
end
local cycle
do
  local v_0_
  local function cycle0(l)
    local start = first(l)
    local _end = last(l)
    a.assoc(start, "prev", _end)
    a.assoc(_end, "next", start)
    return l
  end
  v_0_ = cycle0
  _0_0["cycle"] = v_0_
  cycle = v_0_
end
return nil