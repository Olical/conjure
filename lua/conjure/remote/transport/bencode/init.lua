local _2afile_2a = "fnl/conjure/remote/transport/bencode/init.fnl"
local _1_
do
  local name_4_auto = "conjure.remote.transport.bencode"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.remote.transport.bencode.impl")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", impl = "conjure.remote.transport.bencode.impl"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local impl = _local_4_[2]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.remote.transport.bencode"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local new
do
  local v_23_auto
  do
    local v_25_auto
    local function new0()
      return {data = ""}
    end
    v_25_auto = new0
    _1_["new"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["new"] = v_23_auto
  new = v_23_auto
end
local decode_all
do
  local v_23_auto
  do
    local v_25_auto
    local function decode_all0(bs, part)
      local progress = 1
      local end_3f = false
      local s = (bs.data .. part)
      local acc = {}
      while ((progress < a.count(s)) and not end_3f) do
        local msg, consumed = impl.decode(s, progress)
        if a["nil?"](msg) then
          end_3f = true
        else
          table.insert(acc, msg)
          progress = consumed
        end
      end
      a.assoc(bs, "data", string.sub(s, progress))
      return acc
    end
    v_25_auto = decode_all0
    _1_["decode-all"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["decode-all"] = v_23_auto
  decode_all = v_23_auto
end
local encode
do
  local v_23_auto
  do
    local v_25_auto
    local function encode0(...)
      return impl.encode(...)
    end
    v_25_auto = encode0
    _1_["encode"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["encode"] = v_23_auto
  encode = v_23_auto
end
return nil