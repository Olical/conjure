local _0_0 = nil
do
  local name_0_ = "conjure.buffer"
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
    return {require("conjure.aniseed.core"), require("conjure.aniseed.nvim"), require("conjure.text")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim", text = "conjure.text"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local nvim = _1_[2]
local text = _1_[3]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.buffer"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local unlist = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function unlist0(buf)
      return nvim.buf_set_option(buf, "buflisted", false)
    end
    v_0_0 = unlist0
    _0_0["unlist"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["unlist"] = v_0_
  unlist = v_0_
end
local resolve = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function resolve0(buf_name)
      return nvim.buf_get_name(nvim.fn.bufnr(buf_name))
    end
    v_0_0 = resolve0
    _0_0["resolve"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["resolve"] = v_0_
  resolve = v_0_
end
local upsert_hidden = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function upsert_hidden0(buf_name, new_buf_fn)
      local buf = nvim.fn.bufnr(buf_name)
      if (-1 == buf) then
        local buf0 = nvim.fn.bufadd(buf_name)
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
    _0_0["upsert-hidden"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["upsert-hidden"] = v_0_
  upsert_hidden = v_0_
end
local empty_3f = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function empty_3f0(buf)
      return ((nvim.buf_line_count(buf) <= 1) and (0 == a.count(a.first(nvim.buf_get_lines(buf, 0, -1, false)))))
    end
    v_0_0 = empty_3f0
    _0_0["empty?"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["empty?"] = v_0_
  empty_3f = v_0_
end
local replace_range = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
    _0_0["replace-range"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["replace-range"] = v_0_
  replace_range = v_0_
end
return nil