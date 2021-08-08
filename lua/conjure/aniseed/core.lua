local _2afile_2a = "fnl/aniseed/core.fnl"
local _1_
do
  local name_4_auto = "conjure.aniseed.core"
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
    return {autoload("conjure.aniseed.view")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {view = "conjure.aniseed.view"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local view = _local_4_[1]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.aniseed.core"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
math.randomseed(os.time())
local rand
do
  local v_23_auto
  do
    local v_25_auto
    local function rand0(n)
      return (math.random() * (n or 1))
    end
    v_25_auto = rand0
    _1_["rand"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["rand"] = v_23_auto
  rand = v_23_auto
end
local string_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function string_3f0(x)
      return ("string" == type(x))
    end
    v_25_auto = string_3f0
    _1_["string?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["string?"] = v_23_auto
  string_3f = v_23_auto
end
local nil_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function nil_3f0(x)
      return (nil == x)
    end
    v_25_auto = nil_3f0
    _1_["nil?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["nil?"] = v_23_auto
  nil_3f = v_23_auto
end
local table_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function table_3f0(x)
      return ("table" == type(x))
    end
    v_25_auto = table_3f0
    _1_["table?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["table?"] = v_23_auto
  table_3f = v_23_auto
end
local count
do
  local v_23_auto
  do
    local v_25_auto
    local function count0(xs)
      if table_3f(xs) then
        return table.maxn(xs)
      elseif not xs then
        return 0
      else
        return #xs
      end
    end
    v_25_auto = count0
    _1_["count"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["count"] = v_23_auto
  count = v_23_auto
end
local empty_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function empty_3f0(xs)
      return (0 == count(xs))
    end
    v_25_auto = empty_3f0
    _1_["empty?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["empty?"] = v_23_auto
  empty_3f = v_23_auto
end
local first
do
  local v_23_auto
  do
    local v_25_auto
    local function first0(xs)
      if xs then
        return xs[1]
      end
    end
    v_25_auto = first0
    _1_["first"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["first"] = v_23_auto
  first = v_23_auto
end
local second
do
  local v_23_auto
  do
    local v_25_auto
    local function second0(xs)
      if xs then
        return xs[2]
      end
    end
    v_25_auto = second0
    _1_["second"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["second"] = v_23_auto
  second = v_23_auto
end
local last
do
  local v_23_auto
  do
    local v_25_auto
    local function last0(xs)
      if xs then
        return xs[count(xs)]
      end
    end
    v_25_auto = last0
    _1_["last"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["last"] = v_23_auto
  last = v_23_auto
end
local inc
do
  local v_23_auto
  do
    local v_25_auto
    local function inc0(n)
      return (n + 1)
    end
    v_25_auto = inc0
    _1_["inc"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["inc"] = v_23_auto
  inc = v_23_auto
end
local dec
do
  local v_23_auto
  do
    local v_25_auto
    local function dec0(n)
      return (n - 1)
    end
    v_25_auto = dec0
    _1_["dec"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["dec"] = v_23_auto
  dec = v_23_auto
end
local even_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function even_3f0(n)
      return ((n % 2) == 0)
    end
    v_25_auto = even_3f0
    _1_["even?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["even?"] = v_23_auto
  even_3f = v_23_auto
end
local odd_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function odd_3f0(n)
      return not even_3f(n)
    end
    v_25_auto = odd_3f0
    _1_["odd?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["odd?"] = v_23_auto
  odd_3f = v_23_auto
end
local keys
do
  local v_23_auto
  do
    local v_25_auto
    local function keys0(t)
      local result = {}
      if t then
        for k, _ in pairs(t) do
          table.insert(result, k)
        end
      end
      return result
    end
    v_25_auto = keys0
    _1_["keys"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["keys"] = v_23_auto
  keys = v_23_auto
end
local vals
do
  local v_23_auto
  do
    local v_25_auto
    local function vals0(t)
      local result = {}
      if t then
        for _, v in pairs(t) do
          table.insert(result, v)
        end
      end
      return result
    end
    v_25_auto = vals0
    _1_["vals"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["vals"] = v_23_auto
  vals = v_23_auto
end
local kv_pairs
do
  local v_23_auto
  do
    local v_25_auto
    local function kv_pairs0(t)
      local result = {}
      if t then
        for k, v in pairs(t) do
          table.insert(result, {k, v})
        end
      end
      return result
    end
    v_25_auto = kv_pairs0
    _1_["kv-pairs"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["kv-pairs"] = v_23_auto
  kv_pairs = v_23_auto
end
local run_21
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = run_210
    _1_["run!"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["run!"] = v_23_auto
  run_21 = v_23_auto
end
local filter
do
  local v_23_auto
  do
    local v_25_auto
    local function filter0(f, xs)
      local result = {}
      local function _17_(x)
        if f(x) then
          return table.insert(result, x)
        end
      end
      run_21(_17_, xs)
      return result
    end
    v_25_auto = filter0
    _1_["filter"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["filter"] = v_23_auto
  filter = v_23_auto
end
local map
do
  local v_23_auto
  do
    local v_25_auto
    local function map0(f, xs)
      local result = {}
      local function _19_(x)
        local mapped = f(x)
        local function _20_()
          if (0 == select("#", mapped)) then
            return nil
          else
            return mapped
          end
        end
        return table.insert(result, _20_())
      end
      run_21(_19_, xs)
      return result
    end
    v_25_auto = map0
    _1_["map"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["map"] = v_23_auto
  map = v_23_auto
end
local map_indexed
do
  local v_23_auto
  do
    local v_25_auto
    local function map_indexed0(f, xs)
      return map(f, kv_pairs(xs))
    end
    v_25_auto = map_indexed0
    _1_["map-indexed"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["map-indexed"] = v_23_auto
  map_indexed = v_23_auto
end
local identity
do
  local v_23_auto
  do
    local v_25_auto
    local function identity0(x)
      return x
    end
    v_25_auto = identity0
    _1_["identity"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["identity"] = v_23_auto
  identity = v_23_auto
end
local reduce
do
  local v_23_auto
  do
    local v_25_auto
    local function reduce0(f, init, xs)
      local result = init
      local function _21_(x)
        result = f(result, x)
        return nil
      end
      run_21(_21_, xs)
      return result
    end
    v_25_auto = reduce0
    _1_["reduce"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["reduce"] = v_23_auto
  reduce = v_23_auto
end
local some
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = some0
    _1_["some"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["some"] = v_23_auto
  some = v_23_auto
end
local butlast
do
  local v_23_auto
  do
    local v_25_auto
    local function butlast0(xs)
      local total = count(xs)
      local function _25_(_23_)
        local _arg_24_ = _23_
        local n = _arg_24_[1]
        local v = _arg_24_[2]
        return (n ~= total)
      end
      return map(second, filter(_25_, kv_pairs(xs)))
    end
    v_25_auto = butlast0
    _1_["butlast"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["butlast"] = v_23_auto
  butlast = v_23_auto
end
local rest
do
  local v_23_auto
  do
    local v_25_auto
    local function rest0(xs)
      local function _28_(_26_)
        local _arg_27_ = _26_
        local n = _arg_27_[1]
        local v = _arg_27_[2]
        return (n ~= 1)
      end
      return map(second, filter(_28_, kv_pairs(xs)))
    end
    v_25_auto = rest0
    _1_["rest"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["rest"] = v_23_auto
  rest = v_23_auto
end
local concat
do
  local v_23_auto
  do
    local v_25_auto
    local function concat0(...)
      local result = {}
      local function _29_(xs)
        local function _30_(x)
          return table.insert(result, x)
        end
        return run_21(_30_, xs)
      end
      run_21(_29_, {...})
      return result
    end
    v_25_auto = concat0
    _1_["concat"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["concat"] = v_23_auto
  concat = v_23_auto
end
local mapcat
do
  local v_23_auto
  do
    local v_25_auto
    local function mapcat0(f, xs)
      return concat(unpack(map(f, xs)))
    end
    v_25_auto = mapcat0
    _1_["mapcat"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["mapcat"] = v_23_auto
  mapcat = v_23_auto
end
local pr_str
do
  local v_23_auto
  do
    local v_25_auto
    local function pr_str0(...)
      local s
      local function _31_(x)
        return view.serialise(x, {["one-line"] = true})
      end
      s = table.concat(map(_31_, {...}), " ")
      if (nil_3f(s) or ("" == s)) then
        return "nil"
      else
        return s
      end
    end
    v_25_auto = pr_str0
    _1_["pr-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["pr-str"] = v_23_auto
  pr_str = v_23_auto
end
local str
do
  local v_23_auto
  do
    local v_25_auto
    local function str0(...)
      local function _33_(acc, s)
        return (acc .. s)
      end
      local function _34_(s)
        if string_3f(s) then
          return s
        else
          return pr_str(s)
        end
      end
      return reduce(_33_, "", map(_34_, {...}))
    end
    v_25_auto = str0
    _1_["str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["str"] = v_23_auto
  str = v_23_auto
end
local println
do
  local v_23_auto
  do
    local v_25_auto
    local function println0(...)
      local function _36_(acc, s)
        return (acc .. s)
      end
      local function _39_(_37_)
        local _arg_38_ = _37_
        local i = _arg_38_[1]
        local s = _arg_38_[2]
        if (1 == i) then
          return s
        else
          return (" " .. s)
        end
      end
      local function _41_(s)
        if string_3f(s) then
          return s
        else
          return pr_str(s)
        end
      end
      return print(reduce(_36_, "", map_indexed(_39_, map(_41_, {...}))))
    end
    v_25_auto = println0
    _1_["println"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["println"] = v_23_auto
  println = v_23_auto
end
local pr
do
  local v_23_auto
  do
    local v_25_auto
    local function pr0(...)
      return println(pr_str(...))
    end
    v_25_auto = pr0
    _1_["pr"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["pr"] = v_23_auto
  pr = v_23_auto
end
local slurp
do
  local v_23_auto
  do
    local v_25_auto
    local function slurp0(path, silent_3f)
      local _43_, _44_ = io.open(path, "r")
      if ((_43_ == nil) and (nil ~= _44_)) then
        local msg = _44_
        return nil
      elseif (nil ~= _43_) then
        local f = _43_
        local content = f:read("*all")
        f:close()
        return content
      end
    end
    v_25_auto = slurp0
    _1_["slurp"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["slurp"] = v_23_auto
  slurp = v_23_auto
end
local spit
do
  local v_23_auto
  do
    local v_25_auto
    local function spit0(path, content)
      local _46_, _47_ = io.open(path, "w")
      if ((_46_ == nil) and (nil ~= _47_)) then
        local msg = _47_
        return error(("Could not open file: " .. msg))
      elseif (nil ~= _46_) then
        local f = _46_
        f:write(content)
        f:close()
        return nil
      end
    end
    v_25_auto = spit0
    _1_["spit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["spit"] = v_23_auto
  spit = v_23_auto
end
local merge_21
do
  local v_23_auto
  do
    local v_25_auto
    local function merge_210(base, ...)
      local function _49_(acc, m)
        if m then
          for k, v in pairs(m) do
            acc[k] = v
          end
        end
        return acc
      end
      return reduce(_49_, (base or {}), {...})
    end
    v_25_auto = merge_210
    _1_["merge!"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["merge!"] = v_23_auto
  merge_21 = v_23_auto
end
local merge
do
  local v_23_auto
  do
    local v_25_auto
    local function merge0(...)
      return merge_21({}, ...)
    end
    v_25_auto = merge0
    _1_["merge"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["merge"] = v_23_auto
  merge = v_23_auto
end
local select_keys
do
  local v_23_auto
  do
    local v_25_auto
    local function select_keys0(t, ks)
      if (t and ks) then
        local function _51_(acc, k)
          if k then
            acc[k] = t[k]
          end
          return acc
        end
        return reduce(_51_, {}, ks)
      else
        return {}
      end
    end
    v_25_auto = select_keys0
    _1_["select-keys"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["select-keys"] = v_23_auto
  select_keys = v_23_auto
end
local get
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = get0
    _1_["get"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["get"] = v_23_auto
  get = v_23_auto
end
local get_in
do
  local v_23_auto
  do
    local v_25_auto
    local function get_in0(t, ks, d)
      local res
      local function _57_(acc, k)
        if table_3f(acc) then
          return get(acc, k)
        end
      end
      res = reduce(_57_, t, ks)
      if nil_3f(res) then
        return d
      else
        return res
      end
    end
    v_25_auto = get_in0
    _1_["get-in"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["get-in"] = v_23_auto
  get_in = v_23_auto
end
local assoc
do
  local v_23_auto
  do
    local v_25_auto
    local function assoc0(t, ...)
      local _let_60_ = {...}
      local k = _let_60_[1]
      local v = _let_60_[2]
      local xs = {(table.unpack or unpack)(_let_60_, 3)}
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
    v_25_auto = assoc0
    _1_["assoc"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["assoc"] = v_23_auto
  assoc = v_23_auto
end
local assoc_in
do
  local v_23_auto
  do
    local v_25_auto
    local function assoc_in0(t, ks, v)
      local path = butlast(ks)
      local final = last(ks)
      local t0 = (t or {})
      local function _64_(acc, k)
        local step = get(acc, k)
        if nil_3f(step) then
          return get(assoc(acc, k, {}), k)
        else
          return step
        end
      end
      assoc(reduce(_64_, t0, path), final, v)
      return t0
    end
    v_25_auto = assoc_in0
    _1_["assoc-in"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["assoc-in"] = v_23_auto
  assoc_in = v_23_auto
end
local update
do
  local v_23_auto
  do
    local v_25_auto
    local function update0(t, k, f)
      return assoc(t, k, f(get(t, k)))
    end
    v_25_auto = update0
    _1_["update"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["update"] = v_23_auto
  update = v_23_auto
end
local update_in
do
  local v_23_auto
  do
    local v_25_auto
    local function update_in0(t, ks, f)
      return assoc_in(t, ks, f(get_in(t, ks)))
    end
    v_25_auto = update_in0
    _1_["update-in"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["update-in"] = v_23_auto
  update_in = v_23_auto
end
local constantly
do
  local v_23_auto
  do
    local v_25_auto
    local function constantly0(v)
      local function _66_()
        return v
      end
      return _66_
    end
    v_25_auto = constantly0
    _1_["constantly"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["constantly"] = v_23_auto
  constantly = v_23_auto
end
return nil
