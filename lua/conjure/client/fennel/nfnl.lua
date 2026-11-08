-- [nfnl] fnl/conjure/client/fennel/nfnl.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
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
local def_str_util = autoload("conjure.client.fennel.def-str-util")
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
      local dir = fs.basename(path)
      local config_map = nfnl_config["find-and-load"](dir)
      _7_ = (config_map.cfg or nfnl_config["cfg-fn"]({}, {["root-dir"] = dir}))
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
    local function _9_(_241)
      return (_241 ~= "fnl")
    end
    fnl_and_below = core["drop-while"](_9_, parts)
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
local function whole_file_origin_3f(origin)
  return (("buf" == origin) or ("file" == origin))
end
M["eval-str"] = function(opts)
  if whole_file_origin_3f(opts.origin) then
    core["clear-table!"](fennel["macro-loaded"])
  else
  end
  local repl0 = M["repl-for-path"](opts["file-path"])
  local results = repl0((opts.code .. "\n"))
  local result_strs = core.map(fennel.view, results)
  local mod_path = M["module-path"](opts["file-path"])
  if (mod_path and whole_file_origin_3f(opts.origin) and core["table?"](core.last(results))) then
    local mod = core.get(package.loaded, mod_path)
    package.loaded[mod_path] = core["merge!"](mod, core.last(results))
  else
  end
  if not core["empty?"](result_strs) then
    local result = str.join("\n", result_strs)
    if opts["on-result"] then
      opts["on-result"](result)
    else
    end
    return log.append(text["split-lines"](result))
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
M["def-str"] = function(opts)
  if ts["enabled?"]() then
    return def_str_util["search-and-jump"](opts.code, opts.range.start[1])
  else
    return log.append({"jump to def is not supported because treesitter is not enabled or installed"})
  end
end
return M
