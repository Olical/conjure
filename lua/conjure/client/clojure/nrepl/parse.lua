local _2afile_2a = "fnl/conjure/client/clojure/nrepl/parse.fnl"
local _0_
do
  local name_0_ = "conjure.client.clojure.nrepl.parse"
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
  do end (module_0_)["aniseed/local-fns"] = ((module_0_)["aniseed/local-fns"] or {})
  do end (package.loaded)[name_0_] = module_0_
  _0_ = module_0_
end
local autoload
local function _1_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _1_
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _2_(...)
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.client.clojure.nrepl.parse"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local strip_meta
do
  local v_0_
  do
    local v_0_0
    local function strip_meta0(s)
      local _3_ = s
      if _3_ then
        local _4_ = string.gsub(_3_, "%^:.-%s+", "")
        if _4_ then
          return string.gsub(_4_, "%^%b{}%s+", "")
        else
          return _4_
        end
      else
        return _3_
      end
    end
    v_0_0 = strip_meta0
    _0_["strip-meta"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["strip-meta"] = v_0_
  strip_meta = v_0_
end
local strip_comments
do
  local v_0_
  do
    local v_0_0
    local function strip_comments0(s)
      local _3_ = s
      if _3_ then
        return string.gsub(_3_, ";.-[\n$]", "")
      else
        return _3_
      end
    end
    v_0_0 = strip_comments0
    _0_["strip-comments"] = v_0_0
    v_0_ = v_0_0
  end
  local t_0_ = (_0_)["aniseed/locals"]
  t_0_["strip-comments"] = v_0_
  strip_comments = v_0_
end
return nil