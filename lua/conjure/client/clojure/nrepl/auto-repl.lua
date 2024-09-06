-- [nfnl] Compiled from fnl/conjure/client/clojure/nrepl/auto-repl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local client = autoload("conjure.client")
local config = autoload("conjure.config")
local log = autoload("conjure.log")
local nvim = autoload("conjure.aniseed.nvim")
local process = autoload("conjure.process")
local state = autoload("conjure.client.clojure.nrepl.state")
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
local function enportify(subject)
  if subject:find("$port") then
    local server = nvim.fn.serverstart("localhost:0")
    local _ = nvim.fn.serverstop(server)
    local port = server:gsub("localhost:", "")
    return {subject = subject:gsub("$port", port), port = port}
  else
    return {subject = subject}
  end
end
local function delete_auto_repl_port_file()
  local port_file = cfg({"connection", "auto_repl", "port_file"})
  local port = state.get("auto-repl-port")
  if (port_file and port and (a.slurp(port_file) == port)) then
    return nvim.fn.delete(port_file)
  else
    return nil
  end
end
local function upsert_auto_repl_proc()
  local _let_4_ = enportify(cfg({"connection", "auto_repl", "cmd"}))
  local cmd = _let_4_["subject"]
  local port = _let_4_["port"]
  local port_file = cfg({"connection", "auto_repl", "port_file"})
  local enabled_3f = cfg({"connection", "auto_repl", "enabled"})
  local hidden_3f = cfg({"connection", "auto_repl", "hidden"})
  if (enabled_3f and not process["running?"](state.get("auto-repl-proc")) and process["executable?"](cmd)) then
    local proc = process.execute(cmd, {["hidden?"] = hidden_3f, ["on-exit"] = client.wrap(delete_auto_repl_port_file)})
    a.assoc(state.get(), "auto-repl-proc", proc)
    a.assoc(state.get(), "auto-repl-port", port)
    if (port_file and port) then
      a.spit(port_file, port)
    else
    end
    log.append({("; Starting auto-repl: " .. cmd)})
    return proc
  else
    return nil
  end
end
return {["delete-auto-repl-port-file"] = delete_auto_repl_port_file, enportify = enportify, ["upsert-auto-repl-proc"] = upsert_auto_repl_proc}
