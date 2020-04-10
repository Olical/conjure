local _0_0 = nil
do
  local name_23_0_ = "conjure.aniseed.core"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {view = "conjure.aniseed.view"}}
  return {require("conjure.aniseed.view")}
end
local _2_ = _1_(...)
local view = _2_[1]
do local _ = ({nil, _0_0, nil})[2] end
local string_3f = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function string_3f0(x)
      return ("string" == type(x))
    end
    v_23_0_0 = string_3f0
    _0_0["string?"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["string?"] = v_23_0_
  string_3f = v_23_0_
end
local nil_3f = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function nil_3f0(x)
      return (nil == x)
    end
    v_23_0_0 = nil_3f0
    _0_0["nil?"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["nil?"] = v_23_0_
  nil_3f = v_23_0_
end
local table_3f = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function table_3f0(x)
      return ("table" == type(x))
    end
    v_23_0_0 = table_3f0
    _0_0["table?"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["table?"] = v_23_0_
  table_3f = v_23_0_
end
local count = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function count0(xs)
      if table_3f(xs) then
        return table.maxn(xs)
      elseif not xs then
        return 0
      else
        return #xs
      end
    end
    v_23_0_0 = count0
    _0_0["count"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["count"] = v_23_0_
  count = v_23_0_
end
local empty_3f = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function empty_3f0(xs)
      return (0 == count(xs))
    end
    v_23_0_0 = empty_3f0
    _0_0["empty?"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["empty?"] = v_23_0_
  empty_3f = v_23_0_
end
local first = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function first0(xs)
      if xs then
        return xs[1]
      end
    end
    v_23_0_0 = first0
    _0_0["first"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["first"] = v_23_0_
  first = v_23_0_
end
local second = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function second0(xs)
      if xs then
        return xs[2]
      end
    end
    v_23_0_0 = second0
    _0_0["second"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["second"] = v_23_0_
  second = v_23_0_
end
local last = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function last0(xs)
      if xs then
        return xs[count(xs)]
      end
    end
    v_23_0_0 = last0
    _0_0["last"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["last"] = v_23_0_
  last = v_23_0_
end
local inc = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function inc0(n)
      return (n + 1)
    end
    v_23_0_0 = inc0
    _0_0["inc"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["inc"] = v_23_0_
  inc = v_23_0_
end
local dec = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function dec0(n)
      return (n - 1)
    end
    v_23_0_0 = dec0
    _0_0["dec"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["dec"] = v_23_0_
  dec = v_23_0_
end
local keys = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function keys0(t)
      local result = {}
      if t then
        for k, _ in pairs(t) do
          table.insert(result, k)
        end
      end
      return result
    end
    v_23_0_0 = keys0
    _0_0["keys"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["keys"] = v_23_0_
  keys = v_23_0_
end
local vals = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function vals0(t)
      local result = {}
      if t then
        for _, v in pairs(t) do
          table.insert(result, v)
        end
      end
      return result
    end
    v_23_0_0 = vals0
    _0_0["vals"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["vals"] = v_23_0_
  vals = v_23_0_
end
local kv_pairs = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function kv_pairs0(t)
      local result = {}
      if t then
        for k, v in pairs(t) do
          table.insert(result, {k, v})
        end
      end
      return result
    end
    v_23_0_0 = kv_pairs0
    _0_0["kv-pairs"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["kv-pairs"] = v_23_0_
  kv_pairs = v_23_0_
end
local update = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function update0(tbl, k, f)
      tbl[k] = f(tbl[k])
      return tbl
    end
    v_23_0_0 = update0
    _0_0["update"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["update"] = v_23_0_
  update = v_23_0_
end
local run_21 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_210(f, xs)
      if xs then
        local nxs = count(xs)
        if (nxs > 0) then
          for i = 1, nxs do
            f(xs[i])
          end
          return nil
        end
      end
    end
    v_23_0_0 = run_210
    _0_0["run!"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run!"] = v_23_0_
  run_21 = v_23_0_
end
local filter = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function filter0(f, xs)
      local result = {}
      local function _3_(x)
        if f(x) then
          return table.insert(result, x)
        end
      end
      run_21(_3_, xs)
      return result
    end
    v_23_0_0 = filter0
    _0_0["filter"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["filter"] = v_23_0_
  filter = v_23_0_
end
local map = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function map0(f, xs)
      local result = {}
      local function _3_(x)
        local mapped = f(x)
        local function _4_()
          if (0 == select("#", mapped)) then
            return nil
          else
            return mapped
          end
        end
        return table.insert(result, _4_())
      end
      run_21(_3_, xs)
      return result
    end
    v_23_0_0 = map0
    _0_0["map"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["map"] = v_23_0_
  map = v_23_0_
end
local map_indexed = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function map_indexed0(f, xs)
      return map(f, kv_pairs(xs))
    end
    v_23_0_0 = map_indexed0
    _0_0["map-indexed"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["map-indexed"] = v_23_0_
  map_indexed = v_23_0_
end
local identity = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function identity0(x)
      return x
    end
    v_23_0_0 = identity0
    _0_0["identity"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["identity"] = v_23_0_
  identity = v_23_0_
end
local reduce = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function reduce0(f, init, xs)
      local result = init
      local function _3_(x)
        result = f(result, x)
        return nil
      end
      run_21(_3_, xs)
      return result
    end
    v_23_0_0 = reduce0
    _0_0["reduce"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["reduce"] = v_23_0_
  reduce = v_23_0_
end
local some = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function some0(f, xs)
      local result = nil
      local n = 1
      while (not result and (n <= count(xs))) do
        local candidate = f(xs[n])
        if candidate then
          result = candidate
        end
        n = inc(n)
      end
      return result
    end
    v_23_0_0 = some0
    _0_0["some"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["some"] = v_23_0_
  some = v_23_0_
end
local butlast = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function butlast0(xs)
      local total = count(xs)
      local function _3_(_4_0)
        local _5_ = _4_0
        local n = _5_[1]
        local v = _5_[2]
        return (n ~= total)
      end
      return map(second, filter(_3_, kv_pairs(xs)))
    end
    v_23_0_0 = butlast0
    _0_0["butlast"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["butlast"] = v_23_0_
  butlast = v_23_0_
end
local rest = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function rest0(xs)
      local function _3_(_4_0)
        local _5_ = _4_0
        local n = _5_[1]
        local v = _5_[2]
        return (n ~= 1)
      end
      return map(second, filter(_3_, kv_pairs(xs)))
    end
    v_23_0_0 = rest0
    _0_0["rest"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["rest"] = v_23_0_
  rest = v_23_0_
end
local concat = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function concat0(...)
      local result = {}
      local function _3_(xs)
        local function _4_(x)
          return table.insert(result, x)
        end
        return run_21(_4_, xs)
      end
      run_21(_3_, {...})
      return result
    end
    v_23_0_0 = concat0
    _0_0["concat"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["concat"] = v_23_0_
  concat = v_23_0_
end
local mapcat = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function mapcat0(f, xs)
      return concat(unpack(map(f, xs)))
    end
    v_23_0_0 = mapcat0
    _0_0["mapcat"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["mapcat"] = v_23_0_
  mapcat = v_23_0_
end
local _2aprinter_2a = nil
do
  local v_23_0_ = print
  _0_0["aniseed/locals"]["*printer*"] = v_23_0_
  _2aprinter_2a = v_23_0_
end
local with_out_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function with_out_str0(f)
      local acc = ""
      local function _3_(_241)
        acc = (acc .. _241 .. "\n")
        return nil
      end
      _2aprinter_2a = _3_
      do
        local ok_3f, result = pcall(f)
        _2aprinter_2a = print
        if not ok_3f then
          error(result)
        end
      end
      return acc
    end
    v_23_0_0 = with_out_str0
    _0_0["with-out-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["with-out-str"] = v_23_0_
  with_out_str = v_23_0_
end
local pr_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function pr_str0(...)
      local s = nil
      local function _3_(x)
        return view.serialise(x, {["one-line"] = true})
      end
      s = table.concat(map(_3_, {...}), " ")
      if (not s or ("" == s)) then
        return "nil"
      else
        return s
      end
    end
    v_23_0_0 = pr_str0
    _0_0["pr-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["pr-str"] = v_23_0_
  pr_str = v_23_0_
end
local println = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function println0(...)
      local function _3_(acc, s)
        return (acc .. s)
      end
      local function _4_(_5_0)
        local _6_ = _5_0
        local i = _6_[1]
        local s = _6_[2]
        if (1 == i) then
          return s
        else
          return (" " .. s)
        end
      end
      local function _6_(s)
        if string_3f(s) then
          return s
        else
          return pr_str(s)
        end
      end
      return _2aprinter_2a(reduce(_3_, "", map_indexed(_4_, map(_6_, {...}))))
    end
    v_23_0_0 = println0
    _0_0["println"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["println"] = v_23_0_
  println = v_23_0_
end
local pr = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function pr0(...)
      return println(pr_str(...))
    end
    v_23_0_0 = pr0
    _0_0["pr"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["pr"] = v_23_0_
  pr = v_23_0_
end
local slurp = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function slurp0(path)
      local _3_0, _4_0 = io.open(path, "r")
      if ((_3_0 == nil) and (nil ~= _4_0)) then
        local msg = _4_0
        return println(("Could not open file: " .. msg))
      elseif (nil ~= _3_0) then
        local f = _3_0
        do
          local content = f:read("*all")
          f:close()
          return content
        end
      end
    end
    v_23_0_0 = slurp0
    _0_0["slurp"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["slurp"] = v_23_0_
  slurp = v_23_0_
end
local spit = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function spit0(path, content)
      local _3_0, _4_0 = io.open(path, "w")
      if ((_3_0 == nil) and (nil ~= _4_0)) then
        local msg = _4_0
        return println(("Could not open file: " .. msg))
      elseif (nil ~= _3_0) then
        local f = _3_0
        do
          f:write(content)
          f:close()
          return nil
        end
      end
    end
    v_23_0_0 = spit0
    _0_0["spit"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["spit"] = v_23_0_
  spit = v_23_0_
end
local merge = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function merge0(...)
      local function _3_(acc, m)
        if m then
          for k, v in pairs(m) do
            acc[k] = v
          end
        end
        return acc
      end
      return reduce(_3_, {}, {...})
    end
    v_23_0_0 = merge0
    _0_0["merge"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["merge"] = v_23_0_
  merge = v_23_0_
end
local select_keys = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function select_keys0(t, ks)
      if (t and ks) then
        local function _3_(acc, k)
          if k then
            acc[k] = t[k]
          end
          return acc
        end
        return reduce(_3_, {}, ks)
      else
        return {}
      end
    end
    v_23_0_0 = select_keys0
    _0_0["select-keys"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["select-keys"] = v_23_0_
  select_keys = v_23_0_
end
local get = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function get0(t, k, d)
      local res = ((t and t[k]) or nil)
      if nil_3f(res) then
        return d
      else
        return res
      end
    end
    v_23_0_0 = get0
    _0_0["get"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["get"] = v_23_0_
  get = v_23_0_
end
local get_in = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function get_in0(t, ks, d)
      local res = nil
      local function _3_(acc, k)
        if table_3f(acc) then
          return get(acc, k)
        end
      end
      res = reduce(_3_, t, ks)
      if nil_3f(res) then
        return d
      else
        return res
      end
    end
    v_23_0_0 = get_in0
    _0_0["get-in"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["get-in"] = v_23_0_
  get_in = v_23_0_
end
local assoc = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function assoc0(t, k, v)
      local t0 = (t or {})
      if not nil_3f(k) then
        t0[k] = v
      end
      return t0
    end
    v_23_0_0 = assoc0
    _0_0["assoc"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["assoc"] = v_23_0_
  assoc = v_23_0_
end
local assoc_in = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function assoc_in0(t, ks, v)
      local path = butlast(ks)
      local final = last(ks)
      local t0 = (t or {})
      local function _3_(acc, k)
        local step = get(acc, k)
        if nil_3f(step) then
          return get(assoc(acc, k, {}), k)
        else
          return step
        end
      end
      assoc(reduce(_3_, t0, path), final, v)
      return t0
    end
    v_23_0_0 = assoc_in0
    _0_0["assoc-in"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["assoc-in"] = v_23_0_
  assoc_in = v_23_0_
end
return nil
