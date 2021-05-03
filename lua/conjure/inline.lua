local _2afile_2a = "fnl/conjure/inline.fnl"
local _0_0
do
  local name_0_ = "conjure.inline"
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
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.aniseed.nvim")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", nvim = "conjure.aniseed.nvim"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local nvim = _local_0_[2]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.inline"
do local _ = ({nil, _0_0, nil, {{}, nil, nil, nil}})[2] end
local ns_id
do
  local v_0_
  do
    local v_0_0 = ((_0_0)["ns-id"] or nvim.create_namespace(_2amodule_name_2a))
    _0_0["ns-id"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["ns-id"] = v_0_
  ns_id = v_0_
end
local sanitise_text
do
  local v_0_
  do
    local v_0_0
    local function sanitise_text0(s)
      if a["string?"](s) then
        return s:gsub("%s+", " ")
      else
        return ""
      end
    end
    v_0_0 = sanitise_text0
    _0_0["sanitise-text"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["sanitise-text"] = v_0_
  sanitise_text = v_0_
end
local display
do
  local v_0_
  do
    local v_0_0
    local function display0(opts)
      local function _2_()
        return nvim.buf_set_virtual_text(a.get(opts, "buf", 0), ns_id, opts.line, {{sanitise_text(opts.text), "comment"}}, {})
      end
      return pcall(_2_)
    end
    v_0_0 = display0
    _0_0["display"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["display"] = v_0_
  display = v_0_
end
local clear
do
  local v_0_
  do
    local v_0_0
    local function clear0(opts)
      local function _2_()
        return nvim.buf_clear_namespace(a.get(opts, "buf", 0), ns_id, 0, -1)
      end
      return pcall(_2_)
    end
    v_0_0 = clear0
    _0_0["clear"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["clear"] = v_0_
  clear = v_0_
end
return nil