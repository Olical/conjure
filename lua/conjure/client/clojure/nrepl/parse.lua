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
local autoload = (require("conjure.aniseed.autoload")).autoload
local function _1_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _1_()
    return {}
  end
  ok_3f_0_, val_0_ = pcall(_1_)
  if ok_3f_0_ then
    _0_["aniseed/local-fns"] = {}
    return val_0_
  else
    return print(val_0_)
  end
end
local _local_0_ = _1_(...)
local _2amodule_2a = _0_
local _2amodule_name_2a = "conjure.client.clojure.nrepl.parse"
do local _ = ({nil, _0_, nil, {{}, nil, nil, nil}})[2] end
local strip_meta
do
  local v_0_
  do
    local v_0_0
    local function strip_meta0(s)
      local _2_ = s
      if _2_ then
        local _3_ = string.gsub(_2_, "%^:.-%s+", "")
        if _3_ then
          return string.gsub(_3_, "%^%b{}%s+", "")
        else
          return _3_
        end
      else
        return _2_
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
      local _2_ = s
      if _2_ then
        return string.gsub(_2_, ";.-[\n$]", "")
      else
        return _2_
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