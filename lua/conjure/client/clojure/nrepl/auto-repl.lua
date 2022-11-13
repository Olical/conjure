local _2afile_2a = "fnl/conjure/client/clojure/nrepl/auto-repl.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.auto-repl"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("conjure.aniseed.autoload")).autoload
local a, client, config, log, nvim, process, state, str = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.log"), autoload("conjure.aniseed.nvim"), autoload("conjure.process"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["process"] = process
_2amodule_locals_2a["state"] = state
_2amodule_locals_2a["str"] = str
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
do end (_2amodule_locals_2a)["cfg"] = cfg
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
_2amodule_2a["enportify"] = enportify
local function delete_auto_repl_port_file()
  local port_file = cfg({"connection", "auto_repl", "port_file"})
  local port = state.get("auto-repl-port")
  if (port_file and port and (a.slurp(port_file) == port)) then
    return nvim.fn.delete(port_file)
  else
    return nil
  end
end
_2amodule_2a["delete-auto-repl-port-file"] = delete_auto_repl_port_file
local function upsert_auto_repl_proc()
  local _let_3_ = enportify(cfg({"connection", "auto_repl", "cmd"}))
  local cmd = _let_3_["subject"]
  local port = _let_3_["port"]
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
_2amodule_2a["upsert-auto-repl-proc"] = upsert_auto_repl_proc
return _2amodule_2a