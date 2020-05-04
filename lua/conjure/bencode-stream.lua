local _0_0 = nil
do
  local name_23_0_ = "conjure.bencode-stream"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", bencode = "conjure.bencode"}}
  return {require("conjure.aniseed.core"), require("conjure.bencode")}
end
local _2_ = _1_(...)
local a = _2_[1]
local bencode = _2_[2]
do local _ = ({nil, _0_0, nil})[2] end
local new = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function new0()
      return {data = ""}
    end
    v_23_0_0 = new0
    _0_0["new"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["new"] = v_23_0_
  new = v_23_0_
end
local decode_all = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function decode_all0(bs, part)
      local progress = 1
      local end_3f = false
      do
        local s = (bs.data .. part)
        local acc = {}
        while ((progress < a.count(s)) and not end_3f) do
          local msg, consumed = bencode.decode(s, progress)
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
    end
    v_23_0_0 = decode_all0
    _0_0["decode-all"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["decode-all"] = v_23_0_
  decode_all = v_23_0_
end
return nil