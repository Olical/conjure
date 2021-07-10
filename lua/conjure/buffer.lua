local _2afile_2a = "fnl/conjure/buffer.fnl"
local _0_
do
  local name_0_ = "conjure.buffer"
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
  do end (module_0_)["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  do end (package.loaded)[name_0_] = module_0_
  _0_ = module_0_
end
local autoload
local function _1_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _1_
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _2_(...)
local a = _local_0_[1]
local nvim = _local_0_[2]
local str = _local_0_[3]
local text = _local_0_[4]
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.buffer"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local unlist
do
  local v_0_
  do
    local v_0_0
    local function unlist0(buf)
      return nvim.buf_set_option(buf, "buflisted", false)
    end
    v_0_0 = unlist0
    _0_["unlist"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["unlist"] = v_0_
  unlist = v_0_
end
local resolve
do
  local v_0_
  do
    local v_0_0
    local function resolve0(buf_name)
      return nvim.buf_get_name(nvim.fn.bufnr(buf_name))
    end
    v_0_0 = resolve0
    _0_["resolve"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["resolve"] = v_0_
  resolve = v_0_
end
local upsert_hidden
do
  local v_0_
  do
    local v_0_0
    local function upsert_hidden0(buf_name, new_buf_fn)
      local buf = nvim.fn.bufnr(buf_name)
      local loaded_3f = nvim.buf_is_loaded(buf)
      if ((-1 == buf) or not loaded_3f) then
        local buf0
        if loaded_3f then
          buf0 = buf
        else
          buf0 = nvim.fn.bufadd(buf_name)
        end
        nvim.buf_set_option(buf0, "buftype", "nofile")
        nvim.buf_set_option(buf0, "bufhidden", "hide")
        nvim.buf_set_option(buf0, "swapfile", false)
        unlist(buf0)
        if new_buf_fn then
          new_buf_fn(buf0)
        end
        return buf0
      else
        return buf
      end
    end
    v_0_0 = upsert_hidden0
    _0_["upsert-hidden"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["upsert-hidden"] = v_0_
  upsert_hidden = v_0_
end
local empty_3f
do
  local v_0_
  do
    local v_0_0
    local function empty_3f0(buf)
      return ((nvim.buf_line_count(buf) <= 1) and (0 == a.count(a.first(nvim.buf_get_lines(buf, 0, -1, false)))))
    end
    v_0_0 = empty_3f0
    _0_["empty?"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["empty?"] = v_0_
  empty_3f = v_0_
end
local replace_range
do
  local v_0_
  do
    local v_0_0
    local function replace_range0(buf, range, s)
      local start_line = a.dec(a["get-in"](range, {"start", 1}))
      local end_line = a["get-in"](range, {"end", 1})
      local start_char = a["get-in"](range, {"start", 2})
      local end_char = a["get-in"](range, {"end", 2})
      local new_lines = text["split-lines"](s)
      local old_lines = nvim.buf_get_lines(buf, start_line, end_line, false)
      local head = string.sub(a.first(old_lines), 1, start_char)
      local tail = string.sub(a.last(old_lines), (end_char + 2))
      local function _3_(l)
        return (head .. l)
      end
      a.update(new_lines, 1, _3_)
      local function _4_(l)
        return (l .. tail)
      end
      a.update(new_lines, a.count(new_lines), _4_)
      return nvim.buf_set_lines(buf, start_line, end_line, false, new_lines)
    end
    v_0_0 = replace_range0
    _0_["replace-range"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["replace-range"] = v_0_
  replace_range = v_0_
end
local take_while
do
  local v_0_
  local function take_while0(f, xs)
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
  v_0_ = take_while0
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["take-while"] = v_0_
  take_while = v_0_
end
local append_prefixed_line
do
  local v_0_
  do
    local v_0_0
    local function append_prefixed_line0(buf, _3_, prefix, body)
      local _arg_0_ = _3_
      local tl = _arg_0_[1]
      local tc = _arg_0_[2]
      local tl0 = a.dec(tl)
      local _let_0_ = nvim.buf_get_lines(buf, tl0, -1, false)
      local head_line = _let_0_[1]
      local lines = {(table.unpack or unpack)(_let_0_, 2)}
      local to_append = text["prefixed-lines"](body, prefix, {})
      if head_line:find(prefix, tc) then
        local function _5_(_4_)
          local _arg_1_ = _4_
          local n = _arg_1_[1]
          local line = _arg_1_[2]
          if text["starts-with"](line, prefix) then
            return {(tl0 + n), a.concat({line}, to_append)}
          else
            return false
          end
        end
        local _let_1_ = (a.last(take_while(a.identity, a.map(_5_, a["kv-pairs"](lines)))) or {tl0, a.concat({head_line}, to_append)})
        local new_tl = _let_1_[1]
        local lines0 = _let_1_[2]
        return nvim.buf_set_lines(buf, new_tl, a.inc(new_tl), false, lines0)
      else
        local function _4_()
          if (1 == a.count(to_append)) then
            return {(head_line .. " " .. a.first(to_append))}
          else
            return a.concat({head_line}, to_append)
          end
        end
        return nvim.buf_set_lines(buf, tl0, a.inc(tl0), false, _4_())
      end
    end
    v_0_0 = append_prefixed_line0
    _0_["append-prefixed-line"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["append-prefixed-line"] = v_0_
  append_prefixed_line = v_0_
end
return nil