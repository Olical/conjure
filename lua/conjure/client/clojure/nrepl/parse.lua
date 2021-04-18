local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.clojure.nrepl.parse"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {}
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl.parse"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local strip_meta
do
  local v_0_
  local function strip_meta0(s)
    local _1_0 = s
    if _1_0 then
      local _2_0 = string.gsub(_1_0, "%^:.-%s+", "")
      if _2_0 then
        return string.gsub(_2_0, "%^%b{}%s+", "")
      else
        return _2_0
      end
    else
      return _1_0
    end
  end
  v_0_ = strip_meta0
  _0_0["strip-meta"] = v_0_
  strip_meta = v_0_
end
return nil