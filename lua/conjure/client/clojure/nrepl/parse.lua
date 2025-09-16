-- [nfnl] fnl/conjure/client/clojure/nrepl/parse.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_["define"]
local M = define("conjure.client.clojure.nrepl.parse")
M["strip-meta"] = function(s)
  if (nil ~= s) then
    local tmp_3_ = string.gsub(s, "%^:.-%s+", "")
    if (nil ~= tmp_3_) then
      return string.gsub(tmp_3_, "%^%b{}%s+", "")
    else
      return nil
    end
  else
    return nil
  end
end
M["strip-comments"] = function(s)
  if (nil ~= s) then
    return string.gsub(s, ";.-[\n$]", "")
  else
    return nil
  end
end
M["strip-shebang"] = function(s)
  if (nil ~= s) then
    return string.gsub(s, "^#![^\n]*\n", "")
  else
    return nil
  end
end
return M
