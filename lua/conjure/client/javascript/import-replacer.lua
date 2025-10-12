-- [nfnl] fnl/conjure/client/javascript/import-replacer.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local tsc = autoload("conjure.client.javascript.ts-common")
local text = autoload("conjure.text")
local M = define("conjure.client.javascript.import-replacer")
local function parse_import_source(node, code)
  local source_node = tsc["get-child"](node, "source")
  local source_text = (source_node and tsc["get-text"](source_node, code))
  local source_path = (source_text and string.match(source_text, "^['\"`](.+)['\"`]$"))
  local resolved_path = (source_path and tsc["resolve-path"](source_path))
  return {text = source_text, path = source_path, ["resolved-path"] = resolved_path}
end
local function is_type_import_3f(node, code)
  local first_child = node:child(0)
  local second_child = node:child(1)
  local contains_type = string.find(tsc["get-text"](second_child, code), "type")
  return ((first_child and (tsc["get-text"](first_child, code) == "import") and second_child and (tsc["get-text"](second_child, code) == "type")) or contains_type)
end
local function clean_named_imports(node, code)
  local text0 = tsc["get-text"](node, code)
  return tsc["transform-as-syntax"](string.gsub(string.gsub(text0, "^{%s*", ""), "%s*}$", ""))
end
local function transform_type_import(node, code, source)
  if (source["resolved-path"] and source.text) then
    return (string.gsub(tsc["get-text"](node, code), vim.pesc(source.text), string.format("\"%s\"", source["resolved-path"])) .. ";")
  else
    return tsc["get-text"](node, code)
  end
end
local function transform_plain_import(source)
  if source["resolved-path"] then
    return string.format("require(\"%s\");", source["resolved-path"])
  else
    return nil
  end
end
local function transform_namespace_import(namespace_import, code, source)
  if source["resolved-path"] then
    local ident = tsc["find-child-by-type"](namespace_import, "identifier")
    local alias = tsc["get-text"](ident, code)
    return string.format("const %s = require(\"%s\");", alias, source["resolved-path"])
  else
    return nil
  end
end
local function transform_default_import(default_import, code, source)
  if source["resolved-path"] then
    local name = tsc["get-text"](default_import, code)
    return string.format("const %s = require(\"%s\");", name, source["resolved-path"])
  else
    return nil
  end
end
local function transform_named_import(named_imports, code, source)
  if source["resolved-path"] then
    return string.format("const {%s} = require(\"%s\");", clean_named_imports(named_imports, code), source["resolved-path"])
  else
    return nil
  end
end
local function transform_mixed_import(default_import, named_imports, code, source)
  local default_name = tsc["get-text"](default_import, code)
  local clean_imports = clean_named_imports(named_imports, code)
  if source["resolved-path"] then
    return (string.format("const %s = require(\"%s\");", default_name, source["resolved-path"]) .. " " .. string.format("const {%s} = require(\"%s\");", clean_imports, source["resolved-path"]))
  else
    return nil
  end
end
M["import-statement"] = function(handle_statement)
  local function _8_(node, code)
    local source = parse_import_source(node, code)
    local import_clause = tsc["find-child-by-type"](node, "import_clause")
    local fallback
    local function _9_()
      return handle_statement(node, code)
    end
    fallback = _9_
    if is_type_import_3f(node, code) then
      return transform_type_import(node, code, source)
    elseif not import_clause then
      return (transform_plain_import(source) or fallback())
    else
      local default_import = tsc["find-child-by-type"](import_clause, "identifier")
      local namespace_import = tsc["find-child-by-type"](import_clause, "namespace_import")
      local named_imports = tsc["find-child-by-type"](import_clause, "named_imports")
      if namespace_import then
        return (transform_namespace_import(namespace_import, code, source) or fallback())
      elseif (default_import and not named_imports) then
        return (transform_default_import(default_import, code, source) or fallback())
      elseif (named_imports and not default_import) then
        return (transform_named_import(named_imports, code, source) or fallback())
      elseif (default_import and named_imports) then
        return (transform_mixed_import(default_import, named_imports, code, source) or fallback())
      else
        return fallback()
      end
    end
  end
  return _8_
end
M["call-expression"] = function(default)
  local function _12_(node, code)
    local function_node = tsc["get-child"](node, "function")
    local function_text = (function_node and tsc["get-text"](function_node, code))
    local arguments_node = tsc["get-child"](node, "arguments")
    if ((function_text == "require") and arguments_node) then
      local first_arg = (arguments_node and arguments_node:child(1))
      local arg_text = (first_arg and tsc["get-text"](first_arg, code))
      local arg_path = (arg_text and string.match(arg_text, "^['\"`](.+)['\"`]$"))
      if (arg_path and text["starts-with"](arg_path, ".")) then
        local resolved_path = tsc["resolve-path"](arg_path)
        local quote_char = string.match(arg_text, "^(['\"`])")
        local new_arg = string.format("%s%s%s", quote_char, resolved_path, quote_char)
        return string.gsub(tsc["get-text"](node, code), vim.pesc(arg_text), new_arg)
      else
        return default(node, code)
      end
    else
      return default(node, code)
    end
  end
  return _12_
end
return M
