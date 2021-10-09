local _2afile_2a = "fnl/conjure/client/clojure/nrepl/init.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl"
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
local a, action, bridge, client, config, eval, mapping, nvim, parse, server, str = autoload("conjure.aniseed.core"), autoload("conjure.client.clojure.nrepl.action"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.eval"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.client.clojure.nrepl.parse"), autoload("conjure.client.clojure.nrepl.server"), autoload("conjure.aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["action"] = action
_2amodule_locals_2a["bridge"] = bridge
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["eval"] = eval
_2amodule_locals_2a["mapping"] = mapping
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["parse"] = parse
_2amodule_locals_2a["server"] = server
_2amodule_locals_2a["str"] = str
local buf_suffix = ".cljc"
_2amodule_2a["buf-suffix"] = buf_suffix
local comment_prefix = "; "
_2amodule_2a["comment-prefix"] = comment_prefix
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
do end (_2amodule_locals_2a)["cfg"] = cfg
config.merge({client = {clojure = {nrepl = {connection = {default_host = "localhost", port_files = {".nrepl-port", ".shadow-cljs/nrepl.port"}, auto_repl = {enabled = true, hidden = false, cmd = "bb nrepl-server localhost:8794", port_file = ".nrepl-port", port = "8794"}}, eval = {pretty_print = true, raw_out = false, auto_require = true, print_quota = nil, print_function = "conjure.internal/pprint", print_options = {length = 500, level = 50}}, interrupt = {sample_limit = 0.3}, refresh = {after = nil, before = nil, dirs = nil}, test = {current_form_names = {"deftest"}, runner = "clojure", call_suffix = nil}, mapping = {disconnect = "cd", connect_port_file = "cf", interrupt = "ei", last_exception = "ve", result_1 = "v1", result_2 = "v2", result_3 = "v3", view_source = "vs", session_clone = "sc", session_fresh = "sf", session_close = "sq", session_close_all = "sQ", session_list = "sl", session_next = "sn", session_prev = "sp", session_select = "ss", run_all_tests = "ta", run_current_ns_tests = "tn", run_alternate_ns_tests = "tN", run_current_test = "tc", refresh_changed = "rr", refresh_all = "ra", refresh_clear = "rc"}, completion = {cljs = {use_suitable = true}, with_context = false}}}}})
local function context(header)
  local _1_ = header
  if (nil ~= _1_) then
    local _2_ = parse["strip-meta"](_1_)
    if (nil ~= _2_) then
      local _3_ = parse["strip-comments"](_2_)
      if (nil ~= _3_) then
        local _4_ = string.match(_3_, "%(%s*ns%s+([^)]*)")
        if (nil ~= _4_) then
          local _5_ = str.split(_4_, "%s+")
          if (nil ~= _5_) then
            return a.first(_5_)
          else
            return _5_
          end
        else
          return _4_
        end
      else
        return _3_
      end
    else
      return _2_
    end
  else
    return _1_
  end
end
_2amodule_2a["context"] = context
local function eval_file(opts)
  return action["eval-file"](opts)
end
_2amodule_2a["eval-file"] = eval_file
local function eval_str(opts)
  return action["eval-str"](opts)
end
_2amodule_2a["eval-str"] = eval_str
local function doc_str(opts)
  return action["doc-str"](opts)
end
_2amodule_2a["doc-str"] = doc_str
local function def_str(opts)
  return action["def-str"](opts)
end
_2amodule_2a["def-str"] = def_str
local function completions(opts)
  return action.completions(opts)
end
_2amodule_2a["completions"] = completions
local function connect(opts)
  return action["connect-host-port"](opts)
end
_2amodule_2a["connect"] = connect
local function on_filetype()
  mapping.buf("n", "CljDisconnect", cfg({"mapping", "disconnect"}), "conjure.client.clojure.nrepl.server", "disconnect")
  mapping.buf("n", "CljConnectPortFile", cfg({"mapping", "connect_port_file"}), "conjure.client.clojure.nrepl.action", "connect-port-file")
  mapping.buf("n", "CljInterrupt", cfg({"mapping", "interrupt"}), "conjure.client.clojure.nrepl.action", "interrupt")
  mapping.buf("n", "CljLastException", cfg({"mapping", "last_exception"}), "conjure.client.clojure.nrepl.action", "last-exception")
  mapping.buf("n", "CljResult1", cfg({"mapping", "result_1"}), "conjure.client.clojure.nrepl.action", "result-1")
  mapping.buf("n", "CljResult2", cfg({"mapping", "result_2"}), "conjure.client.clojure.nrepl.action", "result-2")
  mapping.buf("n", "CljResult3", cfg({"mapping", "result_3"}), "conjure.client.clojure.nrepl.action", "result-3")
  mapping.buf("n", "CljViewSource", cfg({"mapping", "view_source"}), "conjure.client.clojure.nrepl.action", "view-source")
  mapping.buf("n", "CljSessionClone", cfg({"mapping", "session_clone"}), "conjure.client.clojure.nrepl.action", "clone-current-session")
  mapping.buf("n", "CljSessionFresh", cfg({"mapping", "session_fresh"}), "conjure.client.clojure.nrepl.action", "clone-fresh-session")
  mapping.buf("n", "CljSessionClose", cfg({"mapping", "session_close"}), "conjure.client.clojure.nrepl.action", "close-current-session")
  mapping.buf("n", "CljSessionCloseAll", cfg({"mapping", "session_close_all"}), "conjure.client.clojure.nrepl.action", "close-all-sessions")
  mapping.buf("n", "CljSessionList", cfg({"mapping", "session_list"}), "conjure.client.clojure.nrepl.action", "display-sessions")
  mapping.buf("n", "CljSessionNext", cfg({"mapping", "session_next"}), "conjure.client.clojure.nrepl.action", "next-session")
  mapping.buf("n", "CljSessionPrev", cfg({"mapping", "session_prev"}), "conjure.client.clojure.nrepl.action", "prev-session")
  mapping.buf("n", "CljSessionSelect", cfg({"mapping", "session_select"}), "conjure.client.clojure.nrepl.action", "select-session-interactive")
  mapping.buf("n", "CljRunAllTests", cfg({"mapping", "run_all_tests"}), "conjure.client.clojure.nrepl.action", "run-all-tests")
  mapping.buf("n", "CljRunCurrentNsTests", cfg({"mapping", "run_current_ns_tests"}), "conjure.client.clojure.nrepl.action", "run-current-ns-tests")
  mapping.buf("n", "CljRunAlternateNsTests", cfg({"mapping", "run_alternate_ns_tests"}), "conjure.client.clojure.nrepl.action", "run-alternate-ns-tests")
  mapping.buf("n", "CljRunCurrentTest", cfg({"mapping", "run_current_test"}), "conjure.client.clojure.nrepl.action", "run-current-test")
  mapping.buf("n", "CljRefreshChanged", cfg({"mapping", "refresh_changed"}), "conjure.client.clojure.nrepl.action", "refresh-changed")
  mapping.buf("n", "CljRefreshAll", cfg({"mapping", "refresh_all"}), "conjure.client.clojure.nrepl.action", "refresh-all")
  mapping.buf("n", "CljRefreshClear", cfg({"mapping", "refresh_clear"}), "conjure.client.clojure.nrepl.action", "refresh-clear")
  nvim.ex.command_("-nargs=1 -buffer ConjureShadowSelect", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "shadow-select", {args = "<f-args>"}))
  nvim.ex.command_("-nargs=1 -buffer ConjurePiggieback", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "piggieback", {args = "<f-args>"}))
  nvim.ex.command_("-nargs=0 -buffer ConjureOutSubscribe", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "out-subscribe", {}))
  nvim.ex.command_("-nargs=0 -buffer ConjureOutUnsubscribe", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "out-unsubscribe", {}))
  return action["passive-ns-require"]()
end
_2amodule_2a["on-filetype"] = on_filetype
local function on_load()
  return action["connect-port-file"]()
end
_2amodule_2a["on-load"] = on_load
local function on_exit()
  action["delete-auto-repl-port-file"]()
  return server.disconnect()
end
_2amodule_2a["on-exit"] = on_exit