local _0_0
do
  local name_0_ = "conjure.aniseed.core"
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
  _0_0 = module_0_
end
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {require("conjure.aniseed.view")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {view = "conjure.aniseed.view"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local view = _local_0_[1]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.aniseed.core"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
math.randomseed(os.time())
local rand
do
  local v_0_
  do
    local v_0_0
    local function rand0(n)
      return (math.random() * (n or 1))
    end
    v_0_0 = rand0
    _0_0["rand"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["rand"] = v_0_
  rand = v_0_
end
local string_3f
do
  local v_0_
  do
    local v_0_0
    local function string_3f0(x)
      return ("string" == type(x))
    end
    v_0_0 = string_3f0
    _0_0["string?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["string?"] = v_0_
  string_3f = v_0_
end
local nil_3f
do
  local v_0_
  do
    local v_0_0
    local function nil_3f0(x)
      return (nil == x)
    end
    v_0_0 = nil_3f0
    _0_0["nil?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["nil?"] = v_0_
  nil_3f = v_0_
end
local table_3f
do
  local v_0_
  do
    local v_0_0
    local function table_3f0(x)
      return ("table" == type(x))
    end
    v_0_0 = table_3f0
    _0_0["table?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["table?"] = v_0_
  table_3f = v_0_
end
local count
do
  local v_0_
  do
    local v_0_0
    local function count0(xs)
      if table_3f(xs) then
        return table.maxn(xs)
      elseif not xs then
        return 0
      else
        return #xs
      end
    end
    v_0_0 = count0
    _0_0["count"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["count"] = v_0_
  count = v_0_
end
local empty_3f
do
  local v_0_
  do
    local v_0_0
    local function empty_3f0(xs)
      return (0 == count(xs))
    end
    v_0_0 = empty_3f0
    _0_0["empty?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["empty?"] = v_0_
  empty_3f = v_0_
end
local first
do
  local v_0_
  do
    local v_0_0
    local function first0(xs)
      if xs then
        return xs[1]
      end
    end
    v_0_0 = first0
    _0_0["first"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["first"] = v_0_
  first = v_0_
end
local second
do
  local v_0_
  do
    local v_0_0
    local function second0(xs)
      if xs then
        return xs[2]
      end
    end
    v_0_0 = second0
    _0_0["second"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["second"] = v_0_
  second = v_0_
end
local last
do
  local v_0_
  do
    local v_0_0
    local function last0(xs)
      if xs then
        return xs[count(xs)]
      end
    end
    v_0_0 = last0
    _0_0["last"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["last"] = v_0_
  last = v_0_
end
local inc
do
  local v_0_
  do
    local v_0_0
    local function inc0(n)
      return (n + 1)
    end
    v_0_0 = inc0
    _0_0["inc"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["inc"] = v_0_
  inc = v_0_
end
local dec
do
  local v_0_
  do
    local v_0_0
    local function dec0(n)
      return (n - 1)
    end
    v_0_0 = dec0
    _0_0["dec"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["dec"] = v_0_
  dec = v_0_
end
local even_3f
do
  local v_0_
  do
    local v_0_0
    local function even_3f0(n)
      return ((n % 2) == 0)
    end
    v_0_0 = even_3f0
    _0_0["even?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["even?"] = v_0_
  even_3f = v_0_
end
local odd_3f
do
  local v_0_
  do
    local v_0_0
    local function odd_3f0(n)
      return not even_3f(n)
    end
    v_0_0 = odd_3f0
    _0_0["odd?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["odd?"] = v_0_
  odd_3f = v_0_
end
local keys
do
  local v_0_
  do
    local v_0_0
    local function keys0(t)
      local result = {}
      if t then
        for k, _ in pairs(t) do
          table.insert(result, k)
        end
      end
      return result
    end
    v_0_0 = keys0
    _0_0["keys"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["keys"] = v_0_
  keys = v_0_
end
local vals
do
  local v_0_
  do
    local v_0_0
    local function vals0(t)
      local result = {}
      if t then
        for _, v in pairs(t) do
          table.insert(result, v)
        end
      end
      return result
    end
    v_0_0 = vals0
    _0_0["vals"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["vals"] = v_0_
  vals = v_0_
end
local kv_pairs
do
  local v_0_
  do
    local v_0_0
    local function kv_pairs0(t)
      local result = {}
      if t then
        for k, v in pairs(t) do
          table.insert(result, {k, v})
        end
      end
      return result
    end
    v_0_0 = kv_pairs0
    _0_0["kv-pairs"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["kv-pairs"] = v_0_
  kv_pairs = v_0_
end
local run_21
do
  local v_0_
  do
    local v_0_0
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
    v_0_0 = run_210
    _0_0["run!"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["run!"] = v_0_
  run_21 = v_0_
end
local filter
do
  local v_0_
  do
    local v_0_0
    local function filter0(f, xs)
      local result = {}
      local function _2_(x)
        if f(x) then
          return table.insert(result, x)
        end
      end
      run_21(_2_, xs)
      return result
    end
    v_0_0 = filter0
    _0_0["filter"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["filter"] = v_0_
  filter = v_0_
end
local map
do
  local v_0_
  do
    local v_0_0
    local function map0(f, xs)
      local result = {}
      local function _2_(x)
        local mapped = f(x)
        local function _3_()
          if (0 == select("#", mapped)) then
            return nil
          else
            return mapped
          end
        end
        return table.insert(result, _3_())
      end
      run_21(_2_, xs)
      return result
    end
    v_0_0 = map0
    _0_0["map"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["map"] = v_0_
  map = v_0_
end
local map_indexed
do
  local v_0_
  do
    local v_0_0
    local function map_indexed0(f, xs)
      return map(f, kv_pairs(xs))
    end
    v_0_0 = map_indexed0
    _0_0["map-indexed"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["map-indexed"] = v_0_
  map_indexed = v_0_
end
local identity
do
  local v_0_
  do
    local v_0_0
    local function identity0(x)
      return x
    end
    v_0_0 = identity0
    _0_0["identity"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["identity"] = v_0_
  identity = v_0_
end
local reduce
do
  local v_0_
  do
    local v_0_0
    local function reduce0(f, init, xs)
      local result = init
      local function _2_(x)
        result = f(result, x)
        return nil
      end
      run_21(_2_, xs)
      return result
    end
    v_0_0 = reduce0
    _0_0["reduce"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["reduce"] = v_0_
  reduce = v_0_
end
local some
do
  local v_0_
  do
    local v_0_0
    local function some0(f, xs)
      local result = nil
      local n = 1
      while (nil_3f(result) and (n <= count(xs))) do
        local candidate = f(xs[n])
        if candidate then
          result = candidate
        end
        n = inc(n)
      end
      return result
    end
    v_0_0 = some0
    _0_0["some"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["some"] = v_0_
  some = v_0_
end
local butlast
do
  local v_0_
  do
    local v_0_0
    local function butlast0(xs)
      local total = count(xs)
      local function _3_(_2_0)
        local _arg_0_ = _2_0
        local n = _arg_0_[1]
        local v = _arg_0_[2]
        return (n ~= total)
      end
      return map(second, filter(_3_, kv_pairs(xs)))
    end
    v_0_0 = butlast0
    _0_0["butlast"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["butlast"] = v_0_
  butlast = v_0_
end
local rest
do
  local v_0_
  do
    local v_0_0
    local function rest0(xs)
      local function _3_(_2_0)
        local _arg_0_ = _2_0
        local n = _arg_0_[1]
        local v = _arg_0_[2]
        return (n ~= 1)
      end
      return map(second, filter(_3_, kv_pairs(xs)))
    end
    v_0_0 = rest0
    _0_0["rest"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["rest"] = v_0_
  rest = v_0_
end
local concat
do
  local v_0_
  do
    local v_0_0
    local function concat0(...)
      local result = {}
      local function _2_(xs)
        local function _3_(x)
          return table.insert(result, x)
        end
        return run_21(_3_, xs)
      end
      run_21(_2_, {...})
      return result
    end
    v_0_0 = concat0
    _0_0["concat"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["concat"] = v_0_
  concat = v_0_
end
local mapcat
do
  local v_0_
  do
    local v_0_0
    local function mapcat0(f, xs)
      return concat(unpack(map(f, xs)))
    end
    v_0_0 = mapcat0
    _0_0["mapcat"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["mapcat"] = v_0_
  mapcat = v_0_
end
local pr_str
do
  local v_0_
  do
    local v_0_0
    local function pr_str0(...)
      local s
      local function _2_(x)
        return view.serialise(x, {["one-line"] = true})
      end
      s = table.concat(map(_2_, {...}), " ")
      if (nil_3f(s) or ("" == s)) then
        return "nil"
      else
        return s
      end
    end
    v_0_0 = pr_str0
    _0_0["pr-str"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["pr-str"] = v_0_
  pr_str = v_0_
end
local println
do
  local v_0_
  do
    local v_0_0
    local function println0(...)
      local function _2_(acc, s)
        return (acc .. s)
      end
      local function _4_(_3_0)
        local _arg_0_ = _3_0
        local i = _arg_0_[1]
        local s = _arg_0_[2]
        if (1 == i) then
          return s
        else
          return (" " .. s)
        end
      end
      local function _5_(s)
        if string_3f(s) then
          return s
        else
          return pr_str(s)
        end
      end
      return print(reduce(_2_, "", map_indexed(_4_, map(_5_, {...}))))
    end
    v_0_0 = println0
    _0_0["println"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["println"] = v_0_
  println = v_0_
end
local pr
do
  local v_0_
  do
    local v_0_0
    local function pr0(...)
      return println(pr_str(...))
    end
    v_0_0 = pr0
    _0_0["pr"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["pr"] = v_0_
  pr = v_0_
end
local slurp
do
  local v_0_
  do
    local v_0_0
    local function slurp0(path, silent_3f)
      local _2_0, _3_0 = io.open(path, "r")
      if ((_2_0 == nil) and (nil ~= _3_0)) then
        local msg = _3_0
        return nil
      elseif (nil ~= _2_0) then
        local f = _2_0
        local content = f:read("*all")
        f:close()
        return content
      end
    end
    v_0_0 = slurp0
    _0_0["slurp"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["slurp"] = v_0_
  slurp = v_0_
end
local spit
do
  local v_0_
  do
    local v_0_0
    local function spit0(path, content)
      local _2_0, _3_0 = io.open(path, "w")
      if ((_2_0 == nil) and (nil ~= _3_0)) then
        local msg = _3_0
        return error(("Could not open file: " .. msg))
      elseif (nil ~= _2_0) then
        local f = _2_0
        f:write(content)
        f:close()
        return nil
      end
    end
    v_0_0 = spit0
    _0_0["spit"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["spit"] = v_0_
  spit = v_0_
end
local merge_21
do
  local v_0_
  do
    local v_0_0
    local function merge_210(base, ...)
      local function _2_(acc, m)
        if m then
          for k, v in pairs(m) do
            acc[k] = v
          end
        end
        return acc
      end
      return reduce(_2_, (base or {}), {...})
    end
    v_0_0 = merge_210
    _0_0["merge!"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["merge!"] = v_0_
  merge_21 = v_0_
end
local merge
do
  local v_0_
  do
    local v_0_0
    local function merge0(...)
      return merge_21({}, ...)
    end
    v_0_0 = merge0
    _0_0["merge"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["merge"] = v_0_
  merge = v_0_
end
local select_keys
do
  local v_0_
  do
    local v_0_0
    local function select_keys0(t, ks)
      if (t and ks) then
        local function _2_(acc, k)
          if k then
            acc[k] = t[k]
          end
          return acc
        end
        return reduce(_2_, {}, ks)
      else
        return {}
      end
    end
    v_0_0 = select_keys0
    _0_0["select-keys"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["select-keys"] = v_0_
  select_keys = v_0_
end
local get
do
  local v_0_
  do
    local v_0_0
    local function get0(t, k, d)
      local res
      if table_3f(t) then
        local val = t[k]
        if not nil_3f(val) then
          res = val
        else
        res = nil
        end
      else
      res = nil
      end
      if nil_3f(res) then
        return d
      else
        return res
      end
    end
    v_0_0 = get0
    _0_0["get"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["get"] = v_0_
  get = v_0_
end
local get_in
do
  local v_0_
  do
    local v_0_0
    local function get_in0(t, ks, d)
      local res
      local function _2_(acc, k)
        if table_3f(acc) then
          return get(acc, k)
        end
      end
      res = reduce(_2_, t, ks)
      if nil_3f(res) then
        return d
      else
        return res
      end
    end
    v_0_0 = get_in0
    _0_0["get-in"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["get-in"] = v_0_
  get_in = v_0_
end
local assoc
do
  local v_0_
  do
    local v_0_0
    local function assoc0(t, ...)
      local _let_0_ = {...}
      local k = _let_0_[1]
      local v = _let_0_[2]
      local xs = {(table.unpack or unpack)(_let_0_, 3)}
      local rem = count(xs)
      local t0 = (t or {})
      if odd_3f(rem) then
        error("assoc expects even number of arguments after table, found odd number")
      end
      if not nil_3f(k) then
        t0[k] = v
      end
      if (rem > 0) then
        assoc0(t0, unpack(xs))
      end
      return t0
    end
    v_0_0 = assoc0
    _0_0["assoc"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["assoc"] = v_0_
  assoc = v_0_
end
local assoc_in
do
  local v_0_
  do
    local v_0_0
    local function assoc_in0(t, ks, v)
      local path = butlast(ks)
      local final = last(ks)
      local t0 = (t or {})
      local function _2_(acc, k)
        local step = get(acc, k)
        if nil_3f(step) then
          return get(assoc(acc, k, {}), k)
        else
          return step
        end
      end
      assoc(reduce(_2_, t0, path), final, v)
      return t0
    end
    v_0_0 = assoc_in0
    _0_0["assoc-in"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["assoc-in"] = v_0_
  assoc_in = v_0_
end
local update
do
  local v_0_
  do
    local v_0_0
    local function update0(t, k, f)
      return assoc(t, k, f(get(t, k)))
    end
    v_0_0 = update0
    _0_0["update"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["update"] = v_0_
  update = v_0_
end
local update_in
do
  local v_0_
  do
    local v_0_0
    local function update_in0(t, ks, f)
      return assoc_in(t, ks, f(get_in(t, ks)))
    end
    v_0_0 = update_in0
    _0_0["update-in"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["update-in"] = v_0_
  update_in = v_0_
end
local constantly
do
  local v_0_
  do
    local v_0_0
    local function constantly0(v)
      local function _2_()
        return v
      end
      return _2_
    end
    v_0_0 = constantly0
    _0_0["constantly"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["constantly"] = v_0_
  constantly = v_0_
end
return nil
