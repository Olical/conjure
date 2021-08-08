local _2afile_2a = "fnl/conjure/client/clojure/nrepl/init.fnl"
local _1_
do
  local name_4_auto = "conjure.client.clojure.nrepl"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.client.clojure.nrepl.action"), autoload("conjure.bridge"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.eval"), autoload("conjure.mapping"), autoload("conjure.aniseed.nvim"), autoload("conjure.client.clojure.nrepl.parse"), autoload("conjure.client.clojure.nrepl.server"), autoload("conjure.aniseed.string")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", action = "conjure.client.clojure.nrepl.action", bridge = "conjure.bridge", client = "conjure.client", config = "conjure.config", eval = "conjure.eval", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", parse = "conjure.client.clojure.nrepl.parse", server = "conjure.client.clojure.nrepl.server", str = "conjure.aniseed.string"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local server = _local_4_[10]
local str = _local_4_[11]
local action = _local_4_[2]
local bridge = _local_4_[3]
local client = _local_4_[4]
local config = _local_4_[5]
local eval = _local_4_[6]
local mapping = _local_4_[7]
local nvim = _local_4_[8]
local parse = _local_4_[9]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.client.clojure.nrepl"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local buf_suffix
do
  local v_23_auto
  do
    local v_25_auto = ".cljc"
    _1_["buf-suffix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["buf-suffix"] = v_23_auto
  buf_suffix = v_23_auto
end
local comment_prefix
do
  local v_23_auto
  do
    local v_25_auto = "; "
    _1_["comment-prefix"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["comment-prefix"] = v_23_auto
  comment_prefix = v_23_auto
end
local cfg
do
  local v_23_auto = config["get-in-fn"]({"client", "clojure", "nrepl"})
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["cfg"] = v_23_auto
  cfg = v_23_auto
end
config.merge({client = {clojure = {nrepl = {completion = {cljs = {use_suitable = true}, with_context = false}, connection = {auto_repl = {cmd = "bb nrepl-server localhost:8794", enabled = true, hidden = false, port = "8794", port_file = ".nrepl-port"}, default_host = "localhost", port_files = {".nrepl-port", ".shadow-cljs/nrepl.port"}}, eval = {auto_require = true, pretty_print = true, print_function = "conjure.internal/pprint", print_options = {length = 500, level = 50}, print_quota = nil, raw_out = false}, interrupt = {sample_limit = 0.3}, mapping = {connect_port_file = "cf", disconnect = "cd", interrupt = "ei", last_exception = "ve", refresh_all = "ra", refresh_changed = "rr", refresh_clear = "rc", result_1 = "v1", result_2 = "v2", result_3 = "v3", run_all_tests = "ta", run_alternate_ns_tests = "tN", run_current_ns_tests = "tn", run_current_test = "tc", session_clone = "sc", session_close = "sq", session_close_all = "sQ", session_fresh = "sf", session_list = "sl", session_next = "sn", session_prev = "sp", session_select = "ss", view_source = "vs"}, refresh = {after = nil, before = nil, dirs = nil}, test = {call_suffix = nil, current_form_names = {"deftest"}, runner = "clojure"}}}}})
local context
do
  local v_23_auto
  do
    local v_25_auto
    local function context0(header)
      local _8_ = header
      if _8_ then
        local _9_ = parse["strip-meta"](_8_)
        if _9_ then
          local _10_ = parse["strip-comments"](_9_)
          if _10_ then
            local _11_ = string.match(_10_, "%(%s*ns%s+([^)]*)")
            if _11_ then
              local _12_ = str.split(_11_, "%s+")
              if _12_ then
                return a.first(_12_)
              else
                return _12_
              end
            else
              return _11_
            end
          else
            return _10_
          end
        else
          return _9_
        end
      else
        return _8_
      end
    end
    v_25_auto = context0
    _1_["context"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["context"] = v_23_auto
  context = v_23_auto
end
local eval_file
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_file0(opts)
      return action["eval-file"](opts)
    end
    v_25_auto = eval_file0
    _1_["eval-file"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-file"] = v_23_auto
  eval_file = v_23_auto
end
local eval_str
do
  local v_23_auto
  do
    local v_25_auto
    local function eval_str0(opts)
      return action["eval-str"](opts)
    end
    v_25_auto = eval_str0
    _1_["eval-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["eval-str"] = v_23_auto
  eval_str = v_23_auto
end
local doc_str
do
  local v_23_auto
  do
    local v_25_auto
    local function doc_str0(opts)
      return action["doc-str"](opts)
    end
    v_25_auto = doc_str0
    _1_["doc-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["doc-str"] = v_23_auto
  doc_str = v_23_auto
end
local def_str
do
  local v_23_auto
  do
    local v_25_auto
    local function def_str0(opts)
      return action["def-str"](opts)
    end
    v_25_auto = def_str0
    _1_["def-str"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["def-str"] = v_23_auto
  def_str = v_23_auto
end
local completions
do
  local v_23_auto
  do
    local v_25_auto
    local function completions0(opts)
      return action.completions(opts)
    end
    v_25_auto = completions0
    _1_["completions"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["completions"] = v_23_auto
  completions = v_23_auto
end
local connect
do
  local v_23_auto
  do
    local v_25_auto
    local function connect0(opts)
      return action["connect-host-port"](opts)
    end
    v_25_auto = connect0
    _1_["connect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect"] = v_23_auto
  connect = v_23_auto
end
local on_filetype
do
  local v_23_auto
  do
    local v_25_auto
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
    v_25_auto = on_filetype0
    _1_["on-filetype"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-filetype"] = v_23_auto
  on_filetype = v_23_auto
end
local on_load
do
  local v_23_auto
  do
    local v_25_auto
    local function on_load0()
      return action["connect-port-file"]()
    end
    v_25_auto = on_load0
    _1_["on-load"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-load"] = v_23_auto
  on_load = v_23_auto
end
local on_exit
do
  local v_23_auto
  do
    local v_25_auto
    local function on_exit0()
      action["delete-auto-repl-port-file"]()
      return server.disconnect()
    end
    v_25_auto = on_exit0
    _1_["on-exit"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["on-exit"] = v_23_auto
  on_exit = v_23_auto
end
return nil