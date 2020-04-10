local _0_0 = nil
do
  local name_23_0_ = "conjure.buffer"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim"}}
  return {require("conjure.aniseed.core"), require("conjure.aniseed.nvim")}
end
local _2_ = _1_(...)
local a = _2_[1]
local nvim = _2_[2]
do local _ = ({nil, _0_0, nil})[2] end
local unlist = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function unlist0(buf)
      return nvim.buf_set_option(buf, "buflisted", false)
    end
    v_23_0_0 = unlist0
    _0_0["unlist"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["unlist"] = v_23_0_
  unlist = v_23_0_
end
local upsert_hidden = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function upsert_hidden0(buf_name)
      local buf = nvim.fn.bufnr(buf_name)
      if (-1 == buf) then
        local buf0 = nvim.fn.bufadd(buf_name)
        nvim.buf_set_option(buf0, "buftype", "nofile")
        nvim.buf_set_option(buf0, "bufhidden", "hide")
        nvim.buf_set_option(buf0, "swapfile", false)
        unlist(buf0)
        return buf0
      else
        return buf
      end
    end
    v_23_0_0 = upsert_hidden0
    _0_0["upsert-hidden"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["upsert-hidden"] = v_23_0_
  upsert_hidden = v_23_0_
end
local empty_3f = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function empty_3f0(buf)
      return ((nvim.buf_line_count(buf) <= 1) and (0 == a.count(a.first(nvim.buf_get_lines(buf, 0, -1, false)))))
    end
    v_23_0_0 = empty_3f0
    _0_0["empty?"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["empty?"] = v_23_0_
  empty_3f = v_23_0_
end
return nil