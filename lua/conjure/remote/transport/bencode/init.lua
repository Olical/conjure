local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.remote.transport.bencode"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.remote.transport.bencode.impl")}
local a = _local_0_[1]
local impl = _local_0_[2]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.remote.transport.bencode"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local new
do
  local v_0_
  local function new0()
    return {data = ""}
  end
  v_0_ = new0
  _0_0["new"] = v_0_
  new = v_0_
end
local decode_all
do
  local v_0_
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
  v_0_ = decode_all0
  _0_0["decode-all"] = v_0_
  decode_all = v_0_
end
local encode
do
  local v_0_
  local function encode0(...)
    return impl.encode(...)
  end
  v_0_ = encode0
  _0_0["encode"] = v_0_
  encode = v_0_
end
return nil