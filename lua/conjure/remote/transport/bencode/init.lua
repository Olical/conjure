local _0_0 = nil
do
  local name_0_ = "conjure.remote.transport.bencode"
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
    return {require("conjure.aniseed.core"), require("conjure.remote.transport.bencode.impl")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", impl = "conjure.remote.transport.bencode.impl"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local a = _1_[1]
local impl = _1_[2]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.transport.bencode"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local new = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function new0()
      return {data = ""}
    end
    v_0_0 = new0
    _0_0["new"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["new"] = v_0_
  new = v_0_
end
local decode_all = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
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
  _0_0["aniseed/locals"]["decode-all"] = v_0_
  decode_all = v_0_
end
local encode = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function encode0(...)
      return impl.encode(...)
    end
    v_0_0 = encode0
    _0_0["encode"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["encode"] = v_0_
  encode = v_0_
end
return nil