-- [nfnl] fnl/conjure/text.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local str = autoload("conjure.nfnl.string")
local M = define("conjure.text")
M["trailing-newline?"] = function(s)
  return string.match(s, "\r?\n$")
end
M["trim-last-newline"] = function(s)
  return string.gsub(s, "\r?\n$", "")
end
M["left-sample"] = function(s, limit)
  local flat = str.trim(string.gsub(string.gsub(s, "\n", " "), "%s+", " "))
  if (limit >= core.count(flat)) then
    return flat
  else
    return (string.sub(flat, 0, core.dec(limit)) .. "...")
  end
end
M["right-sample"] = function(s, limit)
  return string.reverse(M["left-sample"](string.reverse(s), limit))
end
M["split-lines"] = function(s)
  return str.split(s, "\r?\n")
end
M["prefixed-lines"] = function(s, prefix, opts)
  local function _4_(_3_)
    local n = _3_[1]
    local line = _3_[2]
    if ((1 == n) and core.get(opts, "skip-first?")) then
      return line
    else
      return (prefix .. line)
    end
  end
  return core["map-indexed"](_4_, M["split-lines"](s))
end
M["starts-with"] = function(str0, start)
  if (str0 and start) then
    return vim.startswith(str0, start)
  else
    return nil
  end
end
M["ends-with"] = function(str0, _end)
  if (str0 and _end) then
    return ((_end == "") or vim.endswith(str0, _end))
  else
    return nil
  end
end
M["first-and-last-chars"] = function(str0)
  if str0 then
    if (core.count(str0) > 1) then
      return (string.sub(str0, 1, 1) .. string.sub(str0, -1, -1))
    else
      return str0
    end
  else
    return nil
  end
end
M["strip-ansi-escape-sequences"] = function(s)
  return string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(s, "\27%[%d+;%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+;%d+m", ""), "\27%[%d+;%d+;%d+m", ""), "\27%[%d+;%d+m", ""), "\27%[%d+m", "")
end
M.chars = function(s)
  local res = {}
  if s then
    for c in string.gmatch(s, ".") do
      table.insert(res, c)
    end
  else
  end
  return res
end
M["upper-first"] = function(s)
  if s then
    return s:gsub("^%l", string.upper)
  else
    return nil
  end
end
return M
