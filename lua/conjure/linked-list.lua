local _0_0 = nil
do
  local name_0_ = "conjure.linked-list"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("conjure.aniseed.core")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.linked-list"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local create = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
    _0_0["create"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["create"] = v_0_
  create = v_0_
end
local val = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function val0(l)
      local _3_0 = l
      if _3_0 then
        return a.get(_3_0, "val")
      else
        return _3_0
      end
    end
    v_0_0 = val0
    _0_0["val"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["val"] = v_0_
  val = v_0_
end
local next = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function next0(l)
      local _3_0 = l
      if _3_0 then
        return a.get(_3_0, "next")
      else
        return _3_0
      end
    end
    v_0_0 = next0
    _0_0["next"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["next"] = v_0_
  next = v_0_
end
local prev = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function prev0(l)
      local _3_0 = l
      if _3_0 then
        return a.get(_3_0, "prev")
      else
        return _3_0
      end
    end
    v_0_0 = prev0
    _0_0["prev"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["prev"] = v_0_
  prev = v_0_
end
local first = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function first0(l)
      local c = l
      while prev(c) do
        c = prev(c)
      end
      return c
    end
    v_0_0 = first0
    _0_0["first"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["first"] = v_0_
  first = v_0_
end
local last = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function last0(l)
      local c = l
      while next(c) do
        c = next(c)
      end
      return c
    end
    v_0_0 = last0
    _0_0["last"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["last"] = v_0_
  last = v_0_
end
local _until = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
    _0_0["until"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["until"] = v_0_
  _until = v_0_
end
local cycle = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function cycle0(l)
      local start = first(l)
      local _end = last(l)
      a.assoc(start, "prev", _end)
      a.assoc(_end, "next", start)
      return l
    end
    v_0_0 = cycle0
    _0_0["cycle"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["cycle"] = v_0_
  cycle = v_0_
end
return nil