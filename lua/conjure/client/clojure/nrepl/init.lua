-- [nfnl] Compiled from fnl/conjure/client/clojure/nrepl/init.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local mapping = autoload("conjure.mapping")
local eval = autoload("conjure.eval")
local str = autoload("conjure.aniseed.string")
local text = autoload("conjure.text")
local config = autoload("conjure.config")
local action = autoload("conjure.client.clojure.nrepl.action")
local server = autoload("conjure.client.clojure.nrepl.server")
local parse = autoload("conjure.client.clojure.nrepl.parse")
local debugger = autoload("conjure.client.clojure.nrepl.debugger")
local auto_repl = autoload("conjure.client.clojure.nrepl.auto-repl")
local client = autoload("conjure.client")
local util = autoload("conjure.util")
local ts = autoload("conjure.tree-sitter")
local buf_suffix = ".cljc"
local comment_prefix = "; "
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
local reader_macro_pairs = {{"#{", "}"}, {"#(", ")"}, {"#?(", ")"}, {"'(", ")"}, {"'[", "]"}, {"'{", "}"}, {"`(", ")"}, {"`[", "]"}, {"`{", "}"}}
local reader_macros = {"@", "^{", "^:"}
local function form_node_3f(node)
  return (ts["node-surrounded-by-form-pair-chars?"](node, reader_macro_pairs) or ts["node-prefixed-by-chars?"](node, reader_macros))
end
local function symbol_node_3f(node)
  return string.find(node:type(), "kwd")
end
local comment_node_3f = ts["lisp-comment-node?"]
config.merge({client = {clojure = {nrepl = {connection = {default_host = "localhost", port_files = {".nrepl-port", ".shadow-cljs/nrepl.port"}, auto_repl = {enabled = true, cmd = "bb nrepl-server localhost:$port", port_file = ".nrepl-port", hidden = false}}, eval = {pretty_print = true, auto_require = true, print_quota = nil, print_function = "conjure.internal/pprint", print_options = {length = 500, level = 50, right_margin = 72}, raw_out = false}, interrupt = {sample_limit = 0.3}, refresh = {after = nil, before = nil, dirs = nil, backend = "tools.namespace"}, test = {current_form_names = {"deftest"}, runner = "clojure", call_suffix = nil, raw_out = false}, completion = {cljs = {use_suitable = true}, with_context = false}, tap = {queue_size = 16}}}}})
if config["get-in"]({"mapping", "enable_defaults"}) then
  config.merge({client = {clojure = {nrepl = {mapping = {disconnect = "cd", connect_port_file = "cf", interrupt = "ei", last_exception = "ve", result_1 = "v1", result_2 = "v2", result_3 = "v3", view_source = "vs", view_tap = "vt", session_clone = "sc", session_fresh = "sf", session_close = "sq", session_close_all = "sQ", session_list = "sl", session_next = "sn", session_prev = "sp", session_select = "ss", run_all_tests = "ta", run_current_ns_tests = "tn", run_alternate_ns_tests = "tN", run_current_test = "tc", refresh_changed = "rr", refresh_all = "ra", refresh_clear = "rc"}}}}})
else
end
local function context(header)
  if (nil ~= header) then
    local tmp_3_auto = parse["strip-shebang"](header)
    if (nil ~= tmp_3_auto) then
      local tmp_3_auto0 = parse["strip-meta"](tmp_3_auto)
      if (nil ~= tmp_3_auto0) then
        local tmp_3_auto1 = parse["strip-comments"](tmp_3_auto0)
        if (nil ~= tmp_3_auto1) then
          local tmp_3_auto2 = string.match(tmp_3_auto1, "%(%s*ns%s+([^)]*)")
          if (nil ~= tmp_3_auto2) then
            local tmp_3_auto3 = str.split(tmp_3_auto2, "%s+")
            if (nil ~= tmp_3_auto3) then
              return a.first(tmp_3_auto3)
            else
              return nil
            end
          else
            return nil
          end
        else
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end
local function eval_file(opts)
  return action["eval-file"](opts)
end
local function eval_str(opts)
  return action["eval-str"](opts)
end
local function doc_str(opts)
  return action["doc-str"](opts)
end
local function def_str(opts)
  return action["def-str"](opts)
end
local function completions(opts)
  return action.completions(opts)
end
local function connect(opts)
  return action["connect-host-port"](opts)
end
local function on_filetype()
  mapping.buf("CljDisconnect", cfg({"mapping", "disconnect"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.server", "disconnect"), {desc = "Disconnect from the current REPL"})
  mapping.buf("CljConnectPortFile", cfg({"mapping", "connect_port_file"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "connect-port-file"), {desc = "Connect to port specified in .nrepl-port etc"})
  mapping.buf("CljInterrupt", cfg({"mapping", "interrupt"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "interrupt"), {desc = "Interrupt the current evaluation"})
  mapping.buf("CljLastException", cfg({"mapping", "last_exception"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "last-exception"), {desc = "Display the last exception in the log"})
  mapping.buf("CljResult1", cfg({"mapping", "result_1"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "result-1"), {desc = "Display the most recent result"})
  mapping.buf("CljResult2", cfg({"mapping", "result_2"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "result-2"), {desc = "Display the second most recent result"})
  mapping.buf("CljResult3", cfg({"mapping", "result_3"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "result-3"), {desc = "Display the third most recent result"})
  mapping.buf("CljViewSource", cfg({"mapping", "view_source"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "view-source"), {desc = "View the source of the function under the cursor"})
  mapping.buf("CljSessionClone", cfg({"mapping", "session_clone"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "clone-current-session"), {desc = "Clone the current nREPL session"})
  mapping.buf("CljSessionFresh", cfg({"mapping", "session_fresh"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "clone-fresh-session"), {desc = "Create a fresh nREPL session"})
  mapping.buf("CljSessionClose", cfg({"mapping", "session_close"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "close-current-session"), {desc = "Close the current nREPL session"})
  mapping.buf("CljSessionCloseAll", cfg({"mapping", "session_close_all"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "close-all-sessions"), {desc = "Close all nREPL sessions"})
  mapping.buf("CljSessionList", cfg({"mapping", "session_list"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "display-sessions"), {desc = "List the current nREPL sessions"})
  mapping.buf("CljSessionNext", cfg({"mapping", "session_next"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "next-session"), {desc = "Activate the next nREPL session"})
  mapping.buf("CljSessionPrev", cfg({"mapping", "session_prev"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "prev-session"), {desc = "Activate the previous nREPL session"})
  mapping.buf("CljSessionSelect", cfg({"mapping", "session_select"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "select-session-interactive"), {desc = "Prompt to select a nREPL session"})
  mapping.buf("CljRunAllTests", cfg({"mapping", "run_all_tests"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "run-all-tests"), {desc = "Run all loaded tests"})
  mapping.buf("CljRunCurrentNsTests", cfg({"mapping", "run_current_ns_tests"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "run-current-ns-tests"), {desc = "Run loaded tests in the current namespace"})
  mapping.buf("CljRunAlternateNsTests", cfg({"mapping", "run_alternate_ns_tests"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "run-alternate-ns-tests"), {desc = "Run the tests in the *-test variant of your current namespace"})
  mapping.buf("CljRunCurrentTest", cfg({"mapping", "run_current_test"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "run-current-test"), {desc = "Run the test under the cursor"})
  mapping.buf("CljRefreshChanged", cfg({"mapping", "refresh_changed"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "refresh-changed"), {desc = "Refresh changed namespaces"})
  mapping.buf("CljRefreshAll", cfg({"mapping", "refresh_all"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "refresh-all"), {desc = "Refresh all namespaces"})
  mapping.buf("CljRefreshClear", cfg({"mapping", "refresh_clear"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "refresh-clear"), {desc = "Clear the refresh cache"})
  mapping.buf("CljViewTap", cfg({"mapping", "view_tap"}), util["wrap-require-fn-call"]("conjure.client.clojure.nrepl.action", "view-tap"), {desc = "Show all tapped values and clear the queue"})
  local function _9_(_241)
    return action["shadow-select"](a.get(_241, "args"))
  end
  vim.api.nvim_buf_create_user_command(0, "ConjureShadowSelect", _9_, {force = true, nargs = 1})
  local function _10_(_241)
    return action.piggieback(a.get(_241, "args"))
  end
  vim.api.nvim_buf_create_user_command(0, "ConjurePiggieback", _10_, {force = true, nargs = 1})
  vim.api.nvim_buf_create_user_command(0, "ConjureOutSubscribe", action["out-subscribe"], {force = true, nargs = 0})
  vim.api.nvim_buf_create_user_command(0, "ConjureOutUnsubscribe", action["out-unsubscribe"], {force = true, nargs = 0})
  vim.api.nvim_buf_create_user_command(0, "ConjureCljDebugInit", debugger.init, {force = true})
  vim.api.nvim_buf_create_user_command(0, "ConjureCljDebugInput", debugger["debug-input"], {force = true, nargs = 1})
  return action["passive-ns-require"]()
end
local function on_load()
  return action["connect-port-file"]()
end
local function on_exit()
  auto_repl["delete-auto-repl-port-file"]()
  return server.disconnect()
end
return {["buf-suffix"] = buf_suffix, ["comment-prefix"] = comment_prefix, ["form-node?"] = form_node_3f, ["symbol-node?"] = symbol_node_3f, ["comment-node?"] = comment_node_3f, context = context, ["eval-file"] = eval_file, ["eval-str"] = eval_str, ["doc-str"] = doc_str, ["def-str"] = def_str, completions = completions, connect = connect, ["on-filetype"] = on_filetype, ["on-load"] = on_load, ["on-exit"] = on_exit}
