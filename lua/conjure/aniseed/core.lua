local _2afile_2a = "fnl/aniseed/core.fnl"
local _2amodule_name_2a = "conjure.aniseed.core"
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
local view = autoload("conjure.aniseed.view")
do end (_2amodule_locals_2a)["view"] = view
math.randomseed(os.time())
local function rand(n)
  return (math.random() * (n or 1))
end
_2amodule_2a["rand"] = rand
local function nil_3f(x)
  return (nil == x)
end
_2amodule_2a["nil?"] = nil_3f
local function number_3f(x)
  return ("number" == type(x))
end
_2amodule_2a["number?"] = number_3f
local function boolean_3f(x)
  return ("boolean" == type(x))
end
_2amodule_2a["boolean?"] = boolean_3f
local function string_3f(x)
  return ("string" == type(x))
end
_2amodule_2a["string?"] = string_3f
local function table_3f(x)
  return ("table" == type(x))
end
_2amodule_2a["table?"] = table_3f
local function function_3f(value)
  return ("function" == type(value))
end
_2amodule_2a["function?"] = function_3f
local function keys(t)
  local result = {}
  if t then
    for k, _ in pairs(t) do
      table.insert(result, k)
    end
  else
  end
  return result
end
_2amodule_2a["keys"] = keys
local function count(xs)
  if table_3f(xs) then
    local maxn = table.maxn(xs)
    if (0 == maxn) then
      return table.maxn(keys(xs))
    else
      return maxn
    end
  elseif not xs then
    return 0
  else
    return #xs
  end
end
_2amodule_2a["count"] = count
local function empty_3f(xs)
  return (0 == count(xs))
end
_2amodule_2a["empty?"] = empty_3f
local function first(xs)
  if xs then
    return xs[1]
  else
    return nil
  end
end
_2amodule_2a["first"] = first
local function second(xs)
  if xs then
    return xs[2]
  else
    return nil
  end
end
_2amodule_2a["second"] = second
local function last(xs)
  if xs then
    return xs[count(xs)]
  else
    return nil
  end
end
_2amodule_2a["last"] = last
local function inc(n)
  return (n + 1)
end
_2amodule_2a["inc"] = inc
local function dec(n)
  return (n - 1)
end
_2amodule_2a["dec"] = dec
local function even_3f(n)
  return ((n % 2) == 0)
end
_2amodule_2a["even?"] = even_3f
local function odd_3f(n)
  return not even_3f(n)
end
_2amodule_2a["odd?"] = odd_3f
local function vals(t)
  local result = {}
  if t then
    for _, v in pairs(t) do
      table.insert(result, v)
    end
  else
  end
  return result
end
_2amodule_2a["vals"] = vals
local function kv_pairs(t)
  local result = {}
  if t then
    for k, v in pairs(t) do
      table.insert(result, {k, v})
    end
  else
  end
  return result
end
_2amodule_2a["kv-pairs"] = kv_pairs
local function run_21(f, xs)
  if xs then
    local nxs = count(xs)
    if (nxs > 0) then
      for i = 1, nxs do
        f(xs[i])
      end
      return nil
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_2a["run!"] = run_21
local function complement(f)
  local function _11_(...)
    return not f(...)
  end
  return _11_
end
_2amodule_2a["complement"] = complement
local function filter(f, xs)
  local result = {}
  local function _12_(x)
    if f(x) then
      return table.insert(result, x)
    else
      return nil
    end
  end
  run_21(_12_, xs)
  return result
end
_2amodule_2a["filter"] = filter
local function remove(f, xs)
  return filter(complement(f), xs)
end
_2amodule_2a["remove"] = remove
local function map(f, xs)
  local result = {}
  local function _14_(x)
    local mapped = f(x)
    local function _15_()
      if (0 == select("#", mapped)) then
        return nil
      else
        return mapped
      end
    end
    return table.insert(result, _15_())
  end
  run_21(_14_, xs)
  return result
end
_2amodule_2a["map"] = map
local function map_indexed(f, xs)
  return map(f, kv_pairs(xs))
end
_2amodule_2a["map-indexed"] = map_indexed
local function identity(x)
  return x
end
_2amodule_2a["identity"] = identity
local function reduce(f, init, xs)
  local result = init
  local function _16_(x)
    result = f(result, x)
    return nil
  end
  run_21(_16_, xs)
  return result
end
_2amodule_2a["reduce"] = reduce
local function some(f, xs)
  local result = nil
  local n = 1
  while (nil_3f(result) and (n <= count(xs))) do
    local candidate = f(xs[n])
    if candidate then
      result = candidate
    else
    end
    n = inc(n)
  end
  return result
end
_2amodule_2a["some"] = some
local function butlast(xs)
  local total = count(xs)
  local function _20_(_18_)
    local _arg_19_ = _18_
    local n = _arg_19_[1]
    local v = _arg_19_[2]
    return (n ~= total)
  end
  return map(second, filter(_20_, kv_pairs(xs)))
end
_2amodule_2a["butlast"] = butlast
local function rest(xs)
  local function _23_(_21_)
    local _arg_22_ = _21_
    local n = _arg_22_[1]
    local v = _arg_22_[2]
    return (n ~= 1)
  end
  return map(second, filter(_23_, kv_pairs(xs)))
end
_2amodule_2a["rest"] = rest
local function concat(...)
  local result = {}
  local function _24_(xs)
    local function _25_(x)
      return table.insert(result, x)
    end
    return run_21(_25_, xs)
  end
  run_21(_24_, {...})
  return result
end
_2amodule_2a["concat"] = concat
local function mapcat(f, xs)
  return concat(unpack(map(f, xs)))
end
_2amodule_2a["mapcat"] = mapcat
local function pr_str(...)
  local s
  local function _26_(x)
    return view.serialise(x, {["one-line"] = true})
  end
  s = table.concat(map(_26_, {...}), " ")
  if (nil_3f(s) or ("" == s)) then
    return "nil"
  else
    return s
  end
end
_2amodule_2a["pr-str"] = pr_str
local function str(...)
  local function _28_(acc, s)
    return (acc .. s)
  end
  local function _29_(s)
    if string_3f(s) then
      return s
    else
      return pr_str(s)
    end
  end
  return reduce(_28_, "", map(_29_, {...}))
end
_2amodule_2a["str"] = str
local function println(...)
  local function _31_(acc, s)
    return (acc .. s)
  end
  local function _34_(_32_)
    local _arg_33_ = _32_
    local i = _arg_33_[1]
    local s = _arg_33_[2]
    if (1 == i) then
      return s
    else
      return (" " .. s)
    end
  end
  local function _36_(s)
    if string_3f(s) then
      return s
    else
      return pr_str(s)
    end
  end
  return print(reduce(_31_, "", map_indexed(_34_, map(_36_, {...}))))
end
_2amodule_2a["println"] = println
local function pr(...)
  return println(pr_str(...))
end
_2amodule_2a["pr"] = pr
local function slurp(path, silent_3f)
  local _38_, _39_ = io.open(path, "r")
  if ((_38_ == nil) and (nil ~= _39_)) then
    local msg = _39_
    return nil
  elseif (nil ~= _38_) then
    local f = _38_
    local content = f:read("*all")
    f:close()
    return content
  else
    return nil
  end
end
_2amodule_2a["slurp"] = slurp
local function spit(path, content)
  local _41_, _42_ = io.open(path, "w")
  if ((_41_ == nil) and (nil ~= _42_)) then
    local msg = _42_
    return error(("Could not open file: " .. msg))
  elseif (nil ~= _41_) then
    local f = _41_
    f:write(content)
    f:close()
    return nil
  else
    return nil
  end
end
_2amodule_2a["spit"] = spit
local function merge_21(base, ...)
  local function _44_(acc, m)
    if m then
      for k, v in pairs(m) do
        acc[k] = v
      end
    else
    end
    return acc
  end
  return reduce(_44_, (base or {}), {...})
end
_2amodule_2a["merge!"] = merge_21
local function merge(...)
  return merge_21({}, ...)
end
_2amodule_2a["merge"] = merge
local function select_keys(t, ks)
  if (t and ks) then
    local function _46_(acc, k)
      if k then
        acc[k] = t[k]
      else
      end
      return acc
    end
    return reduce(_46_, {}, ks)
  else
    return {}
  end
end
_2amodule_2a["select-keys"] = select_keys
local function get(t, k, d)
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
_2amodule_2a["get"] = get
local function get_in(t, ks, d)
  local res
  local function _52_(acc, k)
    if table_3f(acc) then
      return get(acc, k)
    else
      return nil
    end
  end
  res = reduce(_52_, t, ks)
  if nil_3f(res) then
    return d
  else
    return res
  end
end
_2amodule_2a["get-in"] = get_in
local function assoc(t, ...)
  local _let_55_ = {...}
  local k = _let_55_[1]
  local v = _let_55_[2]
  local xs = (function (t, k, e) local mt = getmetatable(t) if 'table' == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) elseif e then local rest = {} for k, v in pairs(t) do if not e[k] then rest[k] = v end end return rest else return {(table.unpack or unpack)(t, k)} end end)(_let_55_, 3)
  local rem = count(xs)
  local t0 = (t or {})
  if odd_3f(rem) then
    error("assoc expects even number of arguments after table, found odd number")
  else
  end
  if not nil_3f(k) then
    t0[k] = v
  else
  end
  if (rem > 0) then
    assoc(t0, unpack(xs))
  else
  end
  return t0
end
_2amodule_2a["assoc"] = assoc
local function assoc_in(t, ks, v)
  local path = butlast(ks)
  local final = last(ks)
  local t0 = (t or {})
  local function _59_(acc, k)
    local step = get(acc, k)
    if nil_3f(step) then
      return get(assoc(acc, k, {}), k)
    else
      return step
    end
  end
  assoc(reduce(_59_, t0, path), final, v)
  return t0
end
_2amodule_2a["assoc-in"] = assoc_in
local function update(t, k, f)
  return assoc(t, k, f(get(t, k)))
end
_2amodule_2a["update"] = update
local function update_in(t, ks, f)
  return assoc_in(t, ks, f(get_in(t, ks)))
end
_2amodule_2a["update-in"] = update_in
local function constantly(v)
  local function _61_()
    return v
  end
  return _61_
end
_2amodule_2a["constantly"] = constantly
return _2amodule_2a
