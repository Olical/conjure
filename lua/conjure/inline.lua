local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.inline"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.aniseed.nvim")}
local a = _local_0_[1]
local nvim = _local_0_[2]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.inline"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local ns_id
do
  local v_0_ = nvim.create_namespace(_2amodule_name_2a)
  _0_0["ns-id"] = v_0_
  ns_id = v_0_
end
local sanitise_text
do
  local v_0_
  local function sanitise_text0(s)
    if a["string?"](s) then
      return s:gsub("%s+", " ")
    else
      return ""
    end
  end
  v_0_ = sanitise_text0
  _0_0["sanitise-text"] = v_0_
  sanitise_text = v_0_
end
local display
do
  local v_0_
  local function display0(opts)
    local function _1_()
      return nvim.buf_set_virtual_text(a.get(opts, "buf", 0), ns_id, opts.line, {{sanitise_text(opts.text), "comment"}}, {})
    end
    return pcall(_1_)
  end
  v_0_ = display0
  _0_0["display"] = v_0_
  display = v_0_
end
local clear
do
  local v_0_
  local function clear0(opts)
    local function _1_()
      return nvim.buf_clear_namespace(a.get(opts, "buf", 0), ns_id, 0, -1)
    end
    return pcall(_1_)
  end
  v_0_ = clear0
  _0_0["clear"] = v_0_
  clear = v_0_
end
return nil