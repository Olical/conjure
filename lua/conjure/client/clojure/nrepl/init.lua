local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.clojure.nrepl"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.client.clojure.nrepl.action"), require("conjure.bridge"), require("conjure.client"), require("conjure.config"), require("conjure.eval"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.client.clojure.nrepl.parse"), require("conjure.client.clojure.nrepl.server"), require("conjure.aniseed.string")}
local a = _local_0_[1]
local server = _local_0_[10]
local str = _local_0_[11]
local action = _local_0_[2]
local bridge = _local_0_[3]
local client = _local_0_[4]
local config = _local_0_[5]
local eval = _local_0_[6]
local mapping = _local_0_[7]
local nvim = _local_0_[8]
local parse = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local buf_suffix
do
  local v_0_ = ".cljc"
  _0_0["buf-suffix"] = v_0_
  buf_suffix = v_0_
end
local comment_prefix
do
  local v_0_ = "; "
  _0_0["comment-prefix"] = v_0_
  comment_prefix = v_0_
end
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
config.merge({client = {clojure = {nrepl = {completion = {cljs = {use_suitable = true}, with_context = false}, connection = {default_host = "localhost", port_files = {".nrepl-port", ".shadow-cljs/nrepl.port"}}, eval = {auto_require = true, pretty_print = true, print_function = "conjure.internal/pprint", print_options = {length = 500, level = 50}, print_quota = nil}, interrupt = {sample_limit = 0.3}, mapping = {connect_port_file = "cf", disconnect = "cd", interrupt = "ei", last_exception = "ve", refresh_all = "ra", refresh_changed = "rr", refresh_clear = "rc", result_1 = "v1", result_2 = "v2", result_3 = "v3", run_all_tests = "ta", run_alternate_ns_tests = "tN", run_current_ns_tests = "tn", run_current_test = "tc", session_clone = "sc", session_close = "sq", session_close_all = "sQ", session_fresh = "sf", session_list = "sl", session_next = "sn", session_prev = "sp", session_select = "ss", view_source = "vs"}, refresh = {after = nil, before = nil, dirs = nil}, test = {call_suffix = nil, current_form_names = {"deftest"}, runner = "clojure"}}}}})
local context
do
  local v_0_
  local function context0(header)
    local _1_0 = header
    if _1_0 then
      local _2_0 = string.match(_1_0, "%(%s*ns%s+([^)]*)")
      if _2_0 then
        local _3_0 = parse["strip-meta"](_2_0)
        if _3_0 then
          local _4_0 = str.split(_3_0, "%s+")
          if _4_0 then
            return a.first(_4_0)
          else
            return _4_0
          end
        else
          return _3_0
        end
      else
        return _2_0
      end
    else
      return _1_0
    end
  end
  v_0_ = context0
  _0_0["context"] = v_0_
  context = v_0_
end
local eval_file
do
  local v_0_
  local function eval_file0(opts)
    return action["eval-file"](opts)
  end
  v_0_ = eval_file0
  _0_0["eval-file"] = v_0_
  eval_file = v_0_
end
local eval_str
do
  local v_0_
  local function eval_str0(opts)
    return action["eval-str"](opts)
  end
  v_0_ = eval_str0
  _0_0["eval-str"] = v_0_
  eval_str = v_0_
end
local doc_str
do
  local v_0_
  local function doc_str0(opts)
    return action["doc-str"](opts)
  end
  v_0_ = doc_str0
  _0_0["doc-str"] = v_0_
  doc_str = v_0_
end
local def_str
do
  local v_0_
  local function def_str0(opts)
    return action["def-str"](opts)
  end
  v_0_ = def_str0
  _0_0["def-str"] = v_0_
  def_str = v_0_
end
local completions
do
  local v_0_
  local function completions0(opts)
    return action.completions(opts)
  end
  v_0_ = completions0
  _0_0["completions"] = v_0_
  completions = v_0_
end
local connect
do
  local v_0_
  local function connect0(opts)
    return action["connect-host-port"](opts)
  end
  v_0_ = connect0
  _0_0["connect"] = v_0_
  connect = v_0_
end
local on_filetype
do
  local v_0_
  local function on_filetype0()
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
  v_0_ = on_filetype0
  _0_0["on-filetype"] = v_0_
  on_filetype = v_0_
end
local on_load
do
  local v_0_
  local function on_load0()
    return action["connect-port-file"]()
  end
  v_0_ = on_load0
  _0_0["on-load"] = v_0_
  on_load = v_0_
end
local on_exit
do
  local v_0_
  local function on_exit0()
    return server.disconnect()
  end
  v_0_ = on_exit0
  _0_0["on-exit"] = v_0_
  on_exit = v_0_
end
return nil