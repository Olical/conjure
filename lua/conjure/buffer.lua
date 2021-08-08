local _2afile_2a = "fnl/conjure/buffer.fnl"
local _1_
do
  local name_4_auto = "conjure.buffer"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local nvim = _local_4_[2]
local str = _local_4_[3]
local text = _local_4_[4]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.buffer"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local unlist
do
  local v_23_auto
  do
    local v_25_auto
    local function unlist0(buf)
      return nvim.buf_set_option(buf, "buflisted", false)
    end
    v_25_auto = unlist0
    _1_["unlist"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["unlist"] = v_23_auto
  unlist = v_23_auto
end
local resolve
do
  local v_23_auto
  do
    local v_25_auto
    local function resolve0(buf_name)
      return nvim.buf_get_name(nvim.fn.bufnr(buf_name))
    end
    v_25_auto = resolve0
    _1_["resolve"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["resolve"] = v_23_auto
  resolve = v_23_auto
end
local upsert_hidden
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = upsert_hidden0
    _1_["upsert-hidden"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["upsert-hidden"] = v_23_auto
  upsert_hidden = v_23_auto
end
local empty_3f
do
  local v_23_auto
  do
    local v_25_auto
    local function empty_3f0(buf)
      return ((nvim.buf_line_count(buf) <= 1) and (0 == a.count(a.first(nvim.buf_get_lines(buf, 0, -1, false)))))
    end
    v_25_auto = empty_3f0
    _1_["empty?"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["empty?"] = v_23_auto
  empty_3f = v_23_auto
end
local replace_range
do
  local v_23_auto
  do
    local v_25_auto
    local function replace_range0(buf, range, s)
      local start_line = a.dec(a["get-in"](range, {"start", 1}))
      local end_line = a["get-in"](range, {"end", 1})
      local start_char = a["get-in"](range, {"start", 2})
      local end_char = a["get-in"](range, {"end", 2})
      local new_lines = text["split-lines"](s)
      local old_lines = nvim.buf_get_lines(buf, start_line, end_line, false)
      local head = string.sub(a.first(old_lines), 1, start_char)
      local tail = string.sub(a.last(old_lines), (end_char + 2))
      local function _11_(l)
        return (head .. l)
      end
      a.update(new_lines, 1, _11_)
      local function _12_(l)
        return (l .. tail)
      end
      a.update(new_lines, a.count(new_lines), _12_)
      return nvim.buf_set_lines(buf, start_line, end_line, false, new_lines)
    end
    v_25_auto = replace_range0
    _1_["replace-range"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["replace-range"] = v_23_auto
  replace_range = v_23_auto
end
local take_while
do
  local v_23_auto
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
  v_23_auto = take_while0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["take-while"] = v_23_auto
  take_while = v_23_auto
end
local append_prefixed_line
do
  local v_23_auto
  do
    local v_25_auto
    local function append_prefixed_line0(buf, _14_, prefix, body)
      local _arg_15_ = _14_
      local tl = _arg_15_[1]
      local tc = _arg_15_[2]
      local tl0 = a.dec(tl)
      local _let_16_ = nvim.buf_get_lines(buf, tl0, -1, false)
      local head_line = _let_16_[1]
      local lines = {(table.unpack or unpack)(_let_16_, 2)}
      local to_append = text["prefixed-lines"](body, prefix, {})
      if head_line:find(prefix, tc) then
        local function _20_(_18_)
          local _arg_19_ = _18_
          local n = _arg_19_[1]
          local line = _arg_19_[2]
          if text["starts-with"](line, prefix) then
            return {(tl0 + n), a.concat({line}, to_append)}
          else
            return false
          end
        end
        local _let_17_ = (a.last(take_while(a.identity, a.map(_20_, a["kv-pairs"](lines)))) or {tl0, a.concat({head_line}, to_append)})
        local new_tl = _let_17_[1]
        local lines0 = _let_17_[2]
        return nvim.buf_set_lines(buf, new_tl, a.inc(new_tl), false, lines0)
      else
        local function _22_()
          if (1 == a.count(to_append)) then
            return {(head_line .. " " .. a.first(to_append))}
          else
            return a.concat({head_line}, to_append)
          end
        end
        return nvim.buf_set_lines(buf, tl0, a.inc(tl0), false, _22_())
      end
    end
    v_25_auto = append_prefixed_line0
    _1_["append-prefixed-line"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["append-prefixed-line"] = v_23_auto
  append_prefixed_line = v_23_auto
end
return nil