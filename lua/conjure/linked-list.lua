local _2afile_2a = "fnl/conjure/linked-list.fnl"
local _1_
do
  local name_4_auto = "conjure.linked-list"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.linked-list"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local create
do
  local v_23_auto
  do
    local v_25_auto
    local function create0(xs, prev)
      if not a["empty?"](xs) then
        local rest = a.rest(xs)
        local node = {}
        a.assoc(node, "val", a.first(xs))
        a.assoc(node, "prev", prev)
        return a.assoc(node, "next", create0(rest, node))
      end
    end
    v_25_auto = create0
    _1_["create"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["create"] = v_23_auto
  create = v_23_auto
end
local val
do
  local v_23_auto
  do
    local v_25_auto
    local function val0(l)
      local _9_ = l
      if _9_ then
        return a.get(_9_, "val")
      else
        return _9_
      end
    end
    v_25_auto = val0
    _1_["val"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["val"] = v_23_auto
  val = v_23_auto
end
local next
do
  local v_23_auto
  do
    local v_25_auto
    local function next0(l)
      local _11_ = l
      if _11_ then
        return a.get(_11_, "next")
      else
        return _11_
      end
    end
    v_25_auto = next0
    _1_["next"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["next"] = v_23_auto
  next = v_23_auto
end
local prev
do
  local v_23_auto
  do
    local v_25_auto
    local function prev0(l)
      local _13_ = l
      if _13_ then
        return a.get(_13_, "prev")
      else
        return _13_
      end
    end
    v_25_auto = prev0
    _1_["prev"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["prev"] = v_23_auto
  prev = v_23_auto
end
local first
do
  local v_23_auto
  do
    local v_25_auto
    local function first0(l)
      local c = l
      while prev(c) do
        c = prev(c)
      end
      return c
    end
    v_25_auto = first0
    _1_["first"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["first"] = v_23_auto
  first = v_23_auto
end
local last
do
  local v_23_auto
  do
    local v_25_auto
    local function last0(l)
      local c = l
      while next(c) do
        c = next(c)
      end
      return c
    end
    v_25_auto = last0
    _1_["last"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["last"] = v_23_auto
  last = v_23_auto
end
local _until
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = _until0
    _1_["until"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["until"] = v_23_auto
  _until = v_23_auto
end
local cycle
do
  local v_23_auto
  do
    local v_25_auto
    local function cycle0(l)
      local start = first(l)
      local _end = last(l)
      a.assoc(start, "prev", _end)
      a.assoc(_end, "next", start)
      return l
    end
    v_25_auto = cycle0
    _1_["cycle"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cycle"] = v_23_auto
  cycle = v_23_auto
end
return nil