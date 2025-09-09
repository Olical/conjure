-- [nfnl] fnl/conjure/client/javascript/transformers.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
local M = define("conjure.client.javascript.transformers")
local function is_arrow_fn_3f(code)
  if (text["starts-with"](code, "let") or text["starts-with"](code, "const")) then
    local pat
    if string.find(code, "async") then
      pat = ".*=%s*async%s+%(.*%)%s*:+.*=>"
    else
      pat = ".*=%s*%(.*%)%s*:?.*=>"
    end
    if string.match(code, pat) then
      return true
    else
      return false
    end
  else
    return nil
  end
end
M["remove-comments"] = function(s)
  local sub, _ = string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(s, "^//.-\n", ""), "%s*[^:]//.-\n", "\n"), "([^:]//).-\n", ""), "%/%*.-%*%/", ""), "^%s*%*.*", ""), "^%s*%/%*+.*", "")
  return sub
end
M["replace-arrows"] = function(s)
  if not is_arrow_fn_3f(s) then
    return s
  else
    local decl
    if text["starts-with"](s, "const") then
      decl = "const"
    elseif text["starts-with"](s, "let") then
      decl = "let"
    else
      decl = nil
    end
    local pattern = (decl .. "%s*([%w_]+)%s*=%s*(.-)%((.-)%)%s*(.-)%s*=>%s*(.*)")
    local replace_fn
    local function _6_(name, before_args, args, after_args, body)
      local async_kw
      if before_args:find("async") then
        async_kw = "async "
      else
        async_kw = ""
      end
      local final_body
      if body:find("^%s*%{") then
        final_body = (" " .. body)
      else
        final_body = (" { return " .. body .. " }")
      end
      return (async_kw .. "function " .. name .. "(" .. args .. ")" .. after_args .. final_body)
    end
    replace_fn = _6_
    local replace, _ = s:gsub(pattern, replace_fn)
    return replace
  end
end
local function not_declaration_3f(ln)
  return (not (text["starts-with"](ln, "let") or text["starts-with"](ln, "const")) and (string.match(ln, ".-%&%&.-") or text["starts-with"](ln, "?") or text["starts-with"](ln, ":")))
end
local function add_semicolon(s)
  local spl = str.split(s, "\n")
  local sub_fn
  local function _10_(ln)
    local ln0 = str.trim(ln)
    if (text["starts-with"](ln0, ".") or string.match(ln0, "%s*@") or text["ends-with"](ln0, "{") or text["ends-with"](ln0, ";") or text["ends-with"](ln0, ",") or not_declaration_3f(ln0) or str["blank?"](ln0)) then
      return ln0
    else
      return (ln0 .. ";")
    end
  end
  sub_fn = _10_
  local sub = a.map(sub_fn, spl)
  return str.join(" ", sub)
end
M["manage-semicolons"] = function(s)
  if (string.match(s, ".*function.*%(") or text["starts-with"](s, "namespace") or text["starts-with"](s, "class") or text["starts-with"](s, "@") or string.match(s, "%(.*%{") or string.match(s, ".-%s*:%s*%[.-%]%s*=%s*.-")) then
    return add_semicolon(s)
  else
    return s
  end
end
local function flat_dot_lines(s)
  return string.gsub(s, "%s+", " ")
end
M.transform = function(s)
  return M["replace-arrows"](flat_dot_lines(M["manage-semicolons"](M["remove-comments"](s))))
end
return M
