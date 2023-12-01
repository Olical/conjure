-- [nfnl] Compiled from fnl/conjure/buffer.fnl by https://github.com/Olical/nfnl, do not edit.
local _2amodule_name_2a = "conjure.buffer"
local _2amodule_2a
do
  _G.package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = _G.package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local a, nvim, str, text = autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
do local _ = {nil, nil, nil, nil, nil, nil, nil, nil, nil} end
local function unlist(buf)
  return nvim.buf_set_option(buf, "buflisted", false)
end
_2amodule_2a["unlist"] = unlist
do local _ = {unlist, nil} end
local function resolve(buf_name)
  return nvim.buf_get_name(nvim.fn.bufnr(buf_name))
end
_2amodule_2a["resolve"] = resolve
do local _ = {resolve, nil} end
local function upsert_hidden(buf_name, new_buf_fn)
  local ok_3f, buf = pcall(nvim.fn.bufnr, buf_name)
  local loaded_3f = (ok_3f and nvim.buf_is_loaded(buf))
  if ((-1 ~= buf) and not loaded_3f) then
    nvim.buf_delete(buf, {})
  else
  end
  if ((-1 == buf) or not loaded_3f) then
    local buf0
    if loaded_3f then
      buf0 = buf
    else
      local buf1 = nvim.fn.bufadd(buf_name)
      nvim.fn.bufload(buf1)
      buf0 = buf1
    end
    nvim.buf_set_option(buf0, "buftype", "nofile")
    nvim.buf_set_option(buf0, "bufhidden", "hide")
    nvim.buf_set_option(buf0, "swapfile", false)
    unlist(buf0)
    if new_buf_fn then
      new_buf_fn(buf0)
    else
    end
    return buf0
  else
    return buf
  end
end
_2amodule_2a["upsert-hidden"] = upsert_hidden
do local _ = {upsert_hidden, nil} end
local function empty_3f(buf)
  return ((nvim.buf_line_count(buf) <= 1) and (0 == a.count(a.first(nvim.buf_get_lines(buf, 0, -1, false)))))
end
_2amodule_2a["empty?"] = empty_3f
do local _ = {empty_3f, nil} end
local function replace_range(buf, range, s)
  local start_line = a.dec(a["get-in"](range, {"start", 1}))
  local end_line = a["get-in"](range, {"end", 1})
  local start_char = a["get-in"](range, {"start", 2})
  local end_char = a["get-in"](range, {"end", 2})
  local new_lines = text["split-lines"](s)
  local old_lines = nvim.buf_get_lines(buf, start_line, end_line, false)
  local head = string.sub(a.first(old_lines), 1, start_char)
  local tail = string.sub(a.last(old_lines), (end_char + 2))
  local function _5_(l)
    return (head .. l)
  end
  a.update(new_lines, 1, _5_)
  local function _6_(l)
    return (l .. tail)
  end
  a.update(new_lines, a.count(new_lines), _6_)
  return nvim.buf_set_lines(buf, start_line, end_line, false, new_lines)
end
_2amodule_2a["replace-range"] = replace_range
do local _ = {replace_range, nil} end
local function take_while(f, xs)
  local acc = {}
  local done_3f = false
  for i = 1, a.count(xs), 1 do
    local v = xs[i]
    if (not done_3f and f(v)) then
      table.insert(acc, v)
    else
      done_3f = true
    end
  end
  return acc
end
_2amodule_locals_2a["take-while"] = take_while
local function append_prefixed_line(buf, _8_, prefix, body)
  local _arg_9_ = _8_
  local tl = _arg_9_[1]
  local tc = _arg_9_[2]
  local tl0 = a.dec(tl)
  local _let_10_ = nvim.buf_get_lines(buf, tl0, -1, false)
  local head_line = _let_10_[1]
  local lines = (function (t, k, e) local mt = getmetatable(t) if 'table' == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) elseif e then local rest = {} for k, v in pairs(t) do if not e[k] then rest[k] = v end end return rest else return {(table.unpack or unpack)(t, k)} end end)(_let_10_, 2)
  local to_append = text["prefixed-lines"](body, prefix, {})
  if head_line:find(prefix, tc) then
    local function _12_()
      local function _15_(_13_)
        local _arg_14_ = _13_
        local n = _arg_14_[1]
        local line = _arg_14_[2]
        if text["starts-with"](line, prefix) then
          return {(tl0 + n), a.concat({line}, to_append)}
        else
          return false
        end
      end
      return a.last(take_while(a.identity, a.map(_15_, a["kv-pairs"](lines))))
    end
    local _let_11_ = (_12_() or {tl0, a.concat({head_line}, to_append)})
    local new_tl = _let_11_[1]
    local lines0 = _let_11_[2]
    return nvim.buf_set_lines(buf, new_tl, a.inc(new_tl), false, lines0)
  else
    local function _17_()
      if (1 == a.count(to_append)) then
        return {(head_line .. " " .. a.first(to_append))}
      else
        return a.concat({head_line}, to_append)
      end
    end
    return nvim.buf_set_lines(buf, tl0, a.inc(tl0), false, _17_())
  end
end
_2amodule_2a["append-prefixed-line"] = append_prefixed_line
do local _ = {append_prefixed_line, nil} end
return _2amodule_2a
