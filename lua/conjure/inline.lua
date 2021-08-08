local _2afile_2a = "fnl/conjure/inline.fnl"
local _1_
do
  local name_4_auto = "conjure.inline"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local nvim = _local_4_[2]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.inline"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local ns_id
do
  local v_23_auto
  do
    local v_25_auto = ((_1_)["ns-id"] or nvim.create_namespace(_2amodule_name_2a))
    do end (_1_)["ns-id"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["ns-id"] = v_23_auto
  ns_id = v_23_auto
end
local sanitise_text
do
  local v_23_auto
  do
    local v_25_auto
    local function sanitise_text0(s)
      if a["string?"](s) then
        return s:gsub("%s+", " ")
      else
        return ""
      end
    end
    v_25_auto = sanitise_text0
    _1_["sanitise-text"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["sanitise-text"] = v_23_auto
  sanitise_text = v_23_auto
end
local display
do
  local v_23_auto
  do
    local v_25_auto
    local function display0(opts)
      local function _9_()
        return nvim.buf_set_virtual_text(a.get(opts, "buf", 0), ns_id, opts.line, {{sanitise_text(opts.text), "comment"}}, {})
      end
      return pcall(_9_)
    end
    v_25_auto = display0
    _1_["display"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["display"] = v_23_auto
  display = v_23_auto
end
local clear
do
  local v_23_auto
  do
    local v_25_auto
    local function clear0(opts)
      local function _10_()
        return nvim.buf_clear_namespace(a.get(opts, "buf", 0), ns_id, 0, -1)
      end
      return pcall(_10_)
    end
    v_25_auto = clear0
    _1_["clear"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["clear"] = v_23_auto
  clear = v_23_auto
end
return nil