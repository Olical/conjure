local _0_0
do
  local name_0_ = "conjure.remote.transport.bencode"
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
    return {autoload("conjure.aniseed.core"), autoload("conjure.remote.transport.bencode.impl")}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", impl = "conjure.remote.transport.bencode.impl"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local a = _local_0_[1]
local impl = _local_0_[2]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.transport.bencode"
do local _ = ({nil, _0_0, nil, {{}, nil, nil, nil}})[2] end
local new
do
  local v_0_
  do
    local v_0_0
    local function new0()
      return {data = ""}
    end
    v_0_0 = new0
    _0_0["new"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["new"] = v_0_
  new = v_0_
end
local decode_all
do
  local v_0_
  do
    local v_0_0
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
    v_0_0 = decode_all0
    _0_0["decode-all"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["decode-all"] = v_0_
  decode_all = v_0_
end
local encode
do
  local v_0_
  do
    local v_0_0
    local function encode0(...)
      return impl.encode(...)
    end
    v_0_0 = encode0
    _0_0["encode"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_0)["aniseed/locals"]
  t_0_["encode"] = v_0_
  encode = v_0_
end
return nil