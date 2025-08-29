-- [nfnl] fnl/conjure/client/javascript/import-replacer.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local a = autoload("conjure.nfnl.core")
local text = autoload("conjure.text")
local str = autoload("conjure.nfnl.string")
local M = define("conjure.client.javascript.import-replacer")
local function get_absolute_path(f)
  return string.format("%q", vim.fs.normalize(vim.fs.joinpath(vim.fn.expand("%:p:h"), f)))
end
local function replace_imports_path(s)
  if (string.find(s, "import") or string.find(s, "require")) then
    local function _2_(m)
      if text["starts-with"](m, ".") then
        return get_absolute_path(m)
      else
        return ("\"" .. m .. "\"")
      end
    end
    return string.gsub(s, "[\"'](.-)[\"']", _2_)
  else
    return s
  end
end
local function curly_replacer(bd)
  local spl = str.split(bd, ",")
  local spl__3enms
  local function _5_(el)
    return el:gsub(" as ", ": ")
  end
  spl__3enms = str.join(",", a.map(_5_, spl))
  return spl__3enms
end
local patterns_replacements
local function _6_(bd, path)
  return string.format("const {%s} = require(\"%s\")", curly_replacer(bd), path)
end
local function _7_(default, curly, _, mod)
  return string.format("const {%s,%s} = require(\"%s\")", default, curly_replacer(curly), mod)
end
local function _8_(default, nm, mod)
  return string.format("const %s = require(\"%s\");\nconst %s = %s.default", nm, mod, default, nm)
end
local function _9_(alias, _, mod)
  return string.format("const %s = require(\"%s\")", alias, mod)
end
patterns_replacements = {{"^%s*import%s+([\"'])(.-)%1%s*", "require(\"%2\")"}, {"^%s*import%s+([^%s{]+)%s+from%s+([\"'])(.-)%2%s*", "const %1 = require(\"%3\")"}, {"import%s+%{(.-)%}%s+from%s+[\"'](.-)[\"']", _6_}, {"^%s*import%s+([^%s{,]+)%s*,%s*%{([^}]+)%}%s+from%s+([\"'])(.-)%3%s*", _7_}, {"^%s*import%s+(.-)%s*%,%s*%*%s*as%s+(.-)%s*from%s+[\"'](.-)[\"']%s*", _8_}, {"^%s*import%s+%*%s+as%s+([^%s]+)%s+from%s+([\"'])(.-)%2%s*", _9_}}
M["replace-imports-regex"] = function(s)
  local initial_acc = {result = s, ["applied?"] = false}
  local r_fn
  local function _11_(acc, _10_)
    local pat = _10_[1]
    local repl = _10_[2]
    if acc["applied?"] then
      return acc
    else
      local r, c = string.gsub(acc.result, pat, repl)
      if (c > 0) then
        return {["applied?"] = true, result = r}
      else
        return acc
      end
    end
  end
  r_fn = _11_
  local final_acc = a.reduce(r_fn, initial_acc, patterns_replacements)
  return final_acc.result
end
M["replace-imports"] = function(s)
  local s0 = replace_imports_path(s)
  if (text["starts-with"](s0, "import") and not text["starts-with"](s0, "import type")) then
    return M["replace-imports-regex"](s0)
  else
    return s0
  end
end
return M
