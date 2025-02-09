-- [nfnl] Compiled from fnl/conjure/client/fennel/nfnl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local ts = autoload("conjure.tree-sitter")
local config = autoload("conjure.config")
local nfnl_config = autoload("conjure.nfnl.config")
local text = autoload("conjure.text")
local log = autoload("conjure.log")
local core = autoload("conjure.nfnl.core")
local fennel = autoload("conjure.nfnl.fennel")
local str = autoload("conjure.nfnl.string")
local repl = autoload("conjure.nfnl.repl")
local fs = autoload("conjure.nfnl.fs")
local M = define("conjure.client.fennel.nfnl", {["comment-node?"] = ts["lisp-comment-node?"], ["buf-suffix"] = ".fnl", ["comment-prefix"] = "; "})
M["form-node?"] = function(node)
  return ts["node-surrounded-by-form-pair-chars?"](node, {{"#(", ")"}})
end
config.merge({client = {fennel = {nfnl = {}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {fennel = {nfnl = {mapping = {}}}}})
else
end
local cfg = config["get-in-fn"]({"client", "fennel", "nfnl"})
M.repls = (M.repls or {})
M["repl-for-path"] = function(path)
  local _4_
  do
    local t_3_ = M.repls
    if (nil ~= t_3_) then
      t_3_ = t_3_[path]
    else
    end
    _4_ = t_3_
  end
  if _4_ then
    return M.repls[path]
  else
    local r
    local function _6_(err_type, err)
      return log.append(text["prefixed-lines"](str.trim(text["strip-ansi-escape-sequences"](str.join({"[", err_type, "] ", err}))), "; "))
    end
    local _7_
    do
      local config_map = nfnl_config["find-and-load"](fs["file-name-root"](path))
      if config_map then
        _7_ = nfnl_config["cfg-fn"](config_map)
      else
        _7_ = nil
      end
    end
    r = repl.new({["on-error"] = _6_, cfg = _7_})
    M.repls[path] = r
    return r
  end
end
M["module-path"] = function(path)
  if path then
    local parts = fs["split-path"](fs["file-name-root"](path))
    local fnl_and_below
    local function _10_(_241)
      return (_241 ~= "fnl")
    end
    fnl_and_below = core["drop-while"](_10_, parts)
    if ("fnl" == core.first(fnl_and_below)) then
      return str.join(".", core.rest(fnl_and_below))
    else
      return nil
    end
  else
    return nil
  end
end
--[[ (M.module-path "~/repos/Olical/conjure/fnl/conjure/client/fennel/nfnl.fnl") ]]
M["eval-str"] = function(opts)
  local repl0 = M["repl-for-path"](opts["file-path"])
  local results = repl0((opts.code .. "\n"))
  local result_strs = core.map(fennel.view, results)
  local mod_path = M["module-path"](opts["file-path"])
  if (mod_path and (("buf" == opts.origin) or ("file" == opts.origin)) and core["table?"](core.last(results))) then
    local mod = core.get(package.loaded, mod_path)
    package.loaded[mod_path] = core["merge!"](mod, core.last(results))
  else
  end
  if not core["empty?"](result_strs) then
    return log.append(text["split-lines"](str.join("\n", result_strs)))
  else
    return nil
  end
end
M["eval-file"] = function(opts)
  opts.code = core.slurp(opts["file-path"])
  if opts.code then
    return M["eval-str"](opts)
  else
    return nil
  end
end
M["doc-str"] = function(opts)
  core.assoc(opts, "code", (",doc " .. opts.code))
  return M["eval-str"](opts)
end
return M
