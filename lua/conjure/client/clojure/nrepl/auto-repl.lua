-- [nfnl] fnl/conjure/client/clojure/nrepl/auto-repl.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_["autoload"]
local define = _local_1_["define"]
local core = autoload("conjure.nfnl.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local process = autoload("conjure.process")
local state = autoload("conjure.client.clojure.nrepl.state")
local M = define("conjure.client.clojure.nrepl.auto-repl")
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
M.enportify = function(subject)
  if subject:find("$port") then
    local server = vim.fn.serverstart("localhost:0")
    local _ = vim.fn.serverstop(server)
    local port = server:gsub("localhost:", "")
    return {subject = subject:gsub("$port", port), port = port}
  else
    return {subject = subject}
  end
end
M["delete-auto-repl-port-file"] = function()
  local port_file = cfg({"connection", "auto_repl", "port_file"})
  local port = state.get("auto-repl-port")
  if (port_file and port and (core.slurp(port_file) == port)) then
    return vim.fn.delete(port_file)
  else
    return nil
  end
end
M["upsert-auto-repl-proc"] = function()
  local _let_4_ = M.enportify(cfg({"connection", "auto_repl", "cmd"}))
  local cmd = _let_4_["subject"]
  local port = _let_4_["port"]
  local port_file = cfg({"connection", "auto_repl", "port_file"})
  local enabled_3f = cfg({"connection", "auto_repl", "enabled"})
  local hidden_3f = cfg({"connection", "auto_repl", "hidden"})
  if (enabled_3f and not process["running?"](state.get("auto-repl-proc")) and process["executable?"](cmd)) then
    local proc = process.execute(cmd, {["hidden?"] = hidden_3f, ["on-exit"] = client.wrap(M["delete-auto-repl-port-file"])})
    core.assoc(state.get(), "auto-repl-proc", proc)
    core.assoc(state.get(), "auto-repl-port", port)
    if (port_file and port) then
      core.spit(port_file, port)
    else
    end
    log.append({("; Starting auto-repl: " .. cmd)})
    return proc
  else
    return nil
  end
end
return M
