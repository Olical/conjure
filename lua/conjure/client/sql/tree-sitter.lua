-- [nfnl] fnl/conjure/client/sql/tree-sitter.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local config = autoload("conjure.config")
local ts = autoload("conjure.tree-sitter")
local cfg = config["get-in-fn"]({"client", "sql", "stdio"})
local M = define("conjure.client.sql.tree-sitter")
M["statement-types"] = {statement = true}
M["command-wrapper-types"] = {statement = true, transaction = true}
M["ancestor-of-type"] = function(_3fnode, types)
  local or_2_ = (nil == _3fnode)
  if not or_2_ then
    local t_3_ = types
    if (nil ~= t_3_) then
      t_3_ = t_3_[_3fnode:type()]
    else
    end
    or_2_ = t_3_
  end
  if or_2_ then
    return _3fnode
  else
    return M["ancestor-of-type"](_3fnode:parent(), types)
  end
end
M.relations = function(node)
  local rels = {}
  local function go(node0)
    for child in node0:iter_children() do
      if ("relation" == child:type()) then
        table.insert(rels, child)
      else
      end
      go(child)
    end
    return nil
  end
  go(node)
  return rels
end
M["relation-parts"] = function(relation)
  local parts = {}
  for child in relation:iter_children() do
    local case_7_ = child:type()
    if (case_7_ == "object_reference") then
      parts.ref = child
    elseif (case_7_ == "identifier") then
      parts.alias = child
    else
    end
  end
  return parts
end
M["alias->object-reference"] = function(_3fstatement, word)
  if _3fstatement then
    local found = nil
    for _, relation in ipairs(M.relations(_3fstatement)) do
      if found then break end
      local case_9_ = M["relation-parts"](relation)
      local and_10_ = ((_G.type(case_9_) == "table") and (nil ~= case_9_.ref) and (nil ~= case_9_.alias))
      if and_10_ then
        local ref = case_9_.ref
        local alias = case_9_.alias
        and_10_ = (word == ts["node->str"](alias))
      end
      if and_10_ then
        local ref = case_9_.ref
        local alias = case_9_.alias
        found = ts["node->str"](ref)
      else
        found = nil
      end
    end
    return found
  else
    return nil
  end
end
M["node-type"] = function(_3fnode)
  if _3fnode then
    return _3fnode:type()
  else
    return nil
  end
end
M["child-of-type"] = function(node, type)
  local found = nil
  for child in node:iter_children() do
    if found then break end
    if (type == child:type()) then
      found = child
    else
      found = nil
    end
  end
  return found
end
M["reference-node"] = function(leaf)
  local parent = leaf:parent()
  local case_16_ = M["node-type"](parent)
  if (case_16_ == "object_reference") then
    return parent
  elseif (case_16_ == "field") then
    return M["child-of-type"](parent, "object_reference")
  else
    local _ = case_16_
    return leaf
  end
end
local function_parents = {create_function = true, drop_function = true, invocation = true}
M["function-reference?"] = function(node)
  local t_18_ = function_parents
  if (nil ~= t_18_) then
    t_18_ = t_18_[M["node-type"](node:parent())]
  else
  end
  return t_18_
end
M["relation-name"] = function(leaf, name)
  local and_20_ = (nil ~= name)
  if and_20_ then
    local dotted = name
    and_20_ = dotted:find("%.")
  end
  if and_20_ then
    local dotted = name
    return dotted
  elseif (nil ~= name) then
    local bare = name
    return (M["alias->object-reference"](M["ancestor-of-type"](leaf, M["statement-types"]), bare) or bare)
  else
    return nil
  end
end
M["command-node"] = function(leaf)
  local case_23_ = M["ancestor-of-type"](leaf, M["command-wrapper-types"])
  if (nil ~= case_23_) then
    local wrapper = case_23_
    if wrapper:equal(leaf:parent()) then
      return leaf
    else
      return wrapper:named_child(0)
    end
  else
    return nil
  end
end
M["doc-topic"] = function(node)
  return (string.gsub(string.gsub(string.gsub(node:type(), "^keyword_", ""), "_statement$", ""), "_", " "))
end
M["describe-at-cursor"] = function()
  local case_26_ = ts["get-leaf"]()
  local and_27_ = (nil ~= case_26_)
  if and_27_ then
    local leaf = case_26_
    and_27_ = vim.startswith(leaf:type(), "keyword_")
  end
  if and_27_ then
    local leaf = case_26_
    local case_29_ = M["command-node"](leaf)
    if (nil ~= case_29_) then
      local node = case_29_
      return {command = cfg({"doc_statement"}), target = M["doc-topic"](node)}
    else
      return nil
    end
  else
    local and_31_ = (nil ~= case_26_)
    if and_31_ then
      local leaf = case_26_
      and_31_ = ("identifier" == leaf:type())
    end
    if and_31_ then
      local leaf = case_26_
      local case_33_ = M["reference-node"](leaf)
      if (nil ~= case_33_) then
        local node = case_33_
        local name = ts["node->str"](node)
        if M["function-reference?"](node) then
          return {command = cfg({"doc_function"}), target = name}
        else
          return {command = cfg({"doc_table"}), target = M["relation-name"](leaf, name)}
        end
      else
        return nil
      end
    else
      return nil
    end
  end
end
return M
