local _2afile_2a = "fnl/conjure/linked-list.fnl"
local _0_
do
  local name_0_ = "conjure.linked-list"
  local module_0_
  do
    local x_0_ = package.loaded[name_0_]
    if ("table" == type(x_0_)) then
      module_0_ = x_0_
    else
      module_0_ = {}
    end
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = ((module_0_)["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_ = module_0_
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.linked-list"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local create
do
  local v_0_
  do
    local v_0_0
    local function create0(xs, prev)
      if not a["empty?"](xs) then
        local rest = a.rest(xs)
        local node = {}
        a.assoc(node, "val", a.first(xs))
        a.assoc(node, "prev", prev)
        return a.assoc(node, "next", create0(rest, node))
      end
    end
    v_0_0 = create0
    _0_["create"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["create"] = v_0_
  create = v_0_
end
local val
do
  local v_0_
  do
    local v_0_0
    local function val0(l)
      local _2_ = l
      if _2_ then
        return a.get(_2_, "val")
      else
        return _2_
      end
    end
    v_0_0 = val0
    _0_["val"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["val"] = v_0_
  val = v_0_
end
local next
do
  local v_0_
  do
    local v_0_0
    local function next0(l)
      local _2_ = l
      if _2_ then
        return a.get(_2_, "next")
      else
        return _2_
      end
    end
    v_0_0 = next0
    _0_["next"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["next"] = v_0_
  next = v_0_
end
local prev
do
  local v_0_
  do
    local v_0_0
    local function prev0(l)
      local _2_ = l
      if _2_ then
        return a.get(_2_, "prev")
      else
        return _2_
      end
    end
    v_0_0 = prev0
    _0_["prev"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["prev"] = v_0_
  prev = v_0_
end
local first
do
  local v_0_
  do
    local v_0_0
    local function first0(l)
      local c = l
      while prev(c) do
        c = prev(c)
      end
      return c
    end
    v_0_0 = first0
    _0_["first"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["first"] = v_0_
  first = v_0_
end
local last
do
  local v_0_
  do
    local v_0_0
    local function last0(l)
      local c = l
      while next(c) do
        c = next(c)
      end
      return c
    end
    v_0_0 = last0
    _0_["last"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["last"] = v_0_
  last = v_0_
end
local _until
do
  local v_0_
  do
    local v_0_0
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
    v_0_0 = _until0
    _0_["until"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["until"] = v_0_
  _until = v_0_
end
local cycle
do
  local v_0_
  do
    local v_0_0
    local function cycle0(l)
      local start = first(l)
      local _end = last(l)
      a.assoc(start, "prev", _end)
      a.assoc(_end, "next", start)
      return l
    end
    v_0_0 = cycle0
    _0_["cycle"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["cycle"] = v_0_
  cycle = v_0_
end
return nil