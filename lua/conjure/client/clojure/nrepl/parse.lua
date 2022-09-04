local _2afile_2a = "fnl/conjure/client/clojure/nrepl/parse.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.parse"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local function strip_meta(s)
  local _1_ = s
  if (nil ~= _1_) then
    local _2_ = string.gsub(_1_, "%^:.-%s+", "")
    if (nil ~= _2_) then
      return string.gsub(_2_, "%^%b{}%s+", "")
    else
      return _2_
    end
  else
    return _1_
  end
end
_2amodule_2a["strip-meta"] = strip_meta
local function strip_comments(s)
  local _5_ = s
  if (nil ~= _5_) then
    return string.gsub(_5_, ";.-[\n$]", "")
  else
    return _5_
  end
end
_2amodule_2a["strip-comments"] = strip_comments
local function strip_shebang(s)
  local _7_ = s
  if (nil ~= _7_) then
    return string.gsub(_7_, "^#![^\n]*\n", "")
  else
    return _7_
  end
end
_2amodule_2a["strip-shebang"] = strip_shebang
return _2amodule_2a