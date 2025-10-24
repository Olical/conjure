-- [nfnl] fnl/conjure/client/javascript/ts-common.fnl
local _local_1_ = require("conjure.nfnl.module")
local define = _local_1_.define
local text = require("conjure.text")
local M = define("conjure.client.javascript.ts-common")
M["resolve-path"] = function(path)
  if text["starts-with"](path, ".") then
    return vim.fs.normalize(vim.fs.joinpath(vim.fn.expand("%:p:h"), path))
  else
    return path
  end
end
M["transform-as-syntax"] = function(binding_text)
  return string.gsub(binding_text, " as ", ": ")
end
M["get-text"] = function(node, code)
  return vim.treesitter.get_node_text(node, code)
end
M["get-tree"] = function(code)
  local parser = vim.treesitter.get_string_parser(code, vim.bo.filetype)
  return parser:parse()[1]
end
M["get-child"] = function(node, nm)
  return node:field(nm)[1]
end
M["find-child-by-type"] = function(node, type_str)
  local result = nil
  for child in node:iter_children() do
    if (child:type() == type_str) then
      result = child
    else
    end
  end
  return result
end
return M
