-- [nfnl] fnl/conjure/client/clojure/nrepl/parse.fnl
local function strip_meta(s)
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
local function strip_comments(s)
  if (nil ~= s) then
    return string.gsub(s, ";.-[\n$]", "")
  else
    return nil
  end
end
local function strip_shebang(s)
  if (nil ~= s) then
    return string.gsub(s, "^#![^\n]*\n", "")
  else
    return nil
  end
end
return {["strip-comments"] = strip_comments, ["strip-meta"] = strip_meta, ["strip-shebang"] = strip_shebang}
