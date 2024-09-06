-- [nfnl] Compiled from fnl/conjure/client/clojure/nrepl/parse.fnl by https://github.com/Olical/nfnl, do not edit.
local function strip_meta(s)
  if (nil ~= s) then
    local tmp_3_auto = string.gsub(s, "%^:.-%s+", "")
    if (nil ~= tmp_3_auto) then
      return string.gsub(tmp_3_auto, "%^%b{}%s+", "")
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
