local _0_0 = nil
do
  local name_23_0_ = "conjure.client.clojure.nrepl"
  local loaded_23_0_ = package.loaded[name_23_0_]
  local module_23_0_ = nil
  if ("table" == type(loaded_23_0_)) then
    module_23_0_ = loaded_23_0_
  else
    module_23_0_ = {}
  end
  module_23_0_["aniseed/module"] = name_23_0_
  module_23_0_["aniseed/locals"] = (module_23_0_["aniseed/locals"] or {})
  module_23_0_["aniseed/local-fns"] = (module_23_0_["aniseed/local-fns"] or {})
  package.loaded[name_23_0_] = module_23_0_
  _0_0 = module_23_0_
end
local function _1_(...)
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", action = "conjure.client.clojure.nrepl.action", bridge = "conjure.bridge", config = "conjure.client.clojure.nrepl.config", eval = "conjure.eval", mapping = "conjure.mapping", nvim = "conjure.aniseed.nvim", str = "conjure.aniseed.string"}}
  return {require("conjure.aniseed.core"), require("conjure.client.clojure.nrepl.action"), require("conjure.bridge"), require("conjure.client.clojure.nrepl.config"), require("conjure.eval"), require("conjure.mapping"), require("conjure.aniseed.nvim"), require("conjure.aniseed.string")}
end
local _2_ = _1_(...)
local a = _2_[1]
local action = _2_[2]
local bridge = _2_[3]
local config = _2_[4]
local eval = _2_[5]
local mapping = _2_[6]
local nvim = _2_[7]
local str = _2_[8]
do local _ = ({nil, _0_0, {{}, nil}})[2] end
local buf_suffix = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = ".cljc"
    _0_0["buf-suffix"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["buf-suffix"] = v_23_0_
  buf_suffix = v_23_0_
end
local comment_prefix = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = "; "
    _0_0["comment-prefix"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["comment-prefix"] = v_23_0_
  comment_prefix = v_23_0_
end
local config0 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = config
    _0_0["config"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["config"] = v_23_0_
  config0 = v_23_0_
end
local context = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function context0(header)
      local _3_0 = header
      if _3_0 then
        local _4_0 = string.match(_3_0, "%(%s*ns%s+([^)]*)")
        if _4_0 then
          local _5_0 = string.gsub(_4_0, "%^:.-%s+", "")
          if _5_0 then
            local _6_0 = string.gsub(_5_0, "%^%b{}%s+", "")
            if _6_0 then
              local _7_0 = str.split(_6_0, "%s+")
              if _7_0 then
                return a.first(_7_0)
              else
                return _7_0
              end
            else
              return _6_0
            end
          else
            return _5_0
          end
        else
          return _4_0
        end
      else
        return _3_0
      end
    end
    v_23_0_0 = context0
    _0_0["context"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["context"] = v_23_0_
  context = v_23_0_
end
local eval_file = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_file0(opts)
      return action["eval-file"](opts)
    end
    v_23_0_0 = eval_file0
    _0_0["eval-file"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-file"] = v_23_0_
  eval_file = v_23_0_
end
local eval_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_str0(opts)
      return action["eval-str"](opts)
    end
    v_23_0_0 = eval_str0
    _0_0["eval-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-str"] = v_23_0_
  eval_str = v_23_0_
end
local doc_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function doc_str0(opts)
      return action["doc-str"](opts)
    end
    v_23_0_0 = doc_str0
    _0_0["doc-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_23_0_
  doc_str = v_23_0_
end
local def_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function def_str0(opts)
      return action["def-str"](opts)
    end
    v_23_0_0 = def_str0
    _0_0["def-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["def-str"] = v_23_0_
  def_str = v_23_0_
end
local completions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function completions0(opts)
      return action.completions(opts)
    end
    v_23_0_0 = completions0
    _0_0["completions"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["completions"] = v_23_0_
  completions = v_23_0_
end
local on_filetype = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function on_filetype0()
      mapping.buf("n", config0.mappings.disconnect, "conjure.client.clojure.nrepl.server", "disconnect")
      mapping.buf("n", config0.mappings["connect-port-file"], "conjure.client.clojure.nrepl.action", "connect-port-file")
      mapping.buf("n", config0.mappings.interrupt, "conjure.client.clojure.nrepl.action", "interrupt")
      mapping.buf("n", config0.mappings["last-exception"], "conjure.client.clojure.nrepl.action", "last-exception")
      mapping.buf("n", config0.mappings["result-1"], "conjure.client.clojure.nrepl.action", "result-1")
      mapping.buf("n", config0.mappings["result-2"], "conjure.client.clojure.nrepl.action", "result-2")
      mapping.buf("n", config0.mappings["result-3"], "conjure.client.clojure.nrepl.action", "result-3")
      mapping.buf("n", config0.mappings["view-source"], "conjure.client.clojure.nrepl.action", "view-source")
      mapping.buf("n", config0.mappings["session-clone"], "conjure.client.clojure.nrepl.action", "clone-current-session")
      mapping.buf("n", config0.mappings["session-fresh"], "conjure.client.clojure.nrepl.action", "clone-fresh-session")
      mapping.buf("n", config0.mappings["session-close"], "conjure.client.clojure.nrepl.action", "close-current-session")
      mapping.buf("n", config0.mappings["session-close-all"], "conjure.client.clojure.nrepl.action", "close-all-sessions")
      mapping.buf("n", config0.mappings["session-list"], "conjure.client.clojure.nrepl.action", "display-sessions")
      mapping.buf("n", config0.mappings["session-next"], "conjure.client.clojure.nrepl.action", "next-session")
      mapping.buf("n", config0.mappings["session-prev"], "conjure.client.clojure.nrepl.action", "prev-session")
      mapping.buf("n", config0.mappings["session-select"], "conjure.client.clojure.nrepl.action", "select-session-interactive")
      mapping.buf("n", config0.mappings["session-type"], "conjure.client.clojure.nrepl.action", "display-session-type")
      mapping.buf("n", config0.mappings["run-all-tests"], "conjure.client.clojure.nrepl.action", "run-all-tests")
      mapping.buf("n", config0.mappings["run-current-ns-tests"], "conjure.client.clojure.nrepl.action", "run-current-ns-tests")
      mapping.buf("n", config0.mappings["run-alternate-ns-tests"], "conjure.client.clojure.nrepl.action", "run-alternate-ns-tests")
      mapping.buf("n", config0.mappings["run-current-test"], "conjure.client.clojure.nrepl.action", "run-current-test")
      mapping.buf("n", config0.mappings["refresh-changed"], "conjure.client.clojure.nrepl.action", "refresh-changed")
      mapping.buf("n", config0.mappings["refresh-all"], "conjure.client.clojure.nrepl.action", "refresh-all")
      mapping.buf("n", config0.mappings["refresh-clear"], "conjure.client.clojure.nrepl.action", "refresh-clear")
      nvim.ex.command_("-nargs=+ -buffer ConjureConnect", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "connect-host-port", {args = "<f-args>"}))
      nvim.ex.command_("-nargs=1 -buffer ConjureShadowSelect", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "shadow-select", {args = "<f-args>"}))
      nvim.ex.command_("-nargs=1 -buffer ConjurePiggieback", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "piggieback", {args = "<f-args>"}))
      nvim.ex.command_("-nargs=0 -buffer ConjureOutSubscribe", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "out-subscribe", {}))
      nvim.ex.command_("-nargs=0 -buffer ConjureOutUnsubscribe", bridge["viml->lua"]("conjure.client.clojure.nrepl.action", "out-unsubscribe", {}))
      return action["passive-ns-require"]()
    end
    v_23_0_0 = on_filetype0
    _0_0["on-filetype"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["on-filetype"] = v_23_0_
  on_filetype = v_23_0_
end
local on_load = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function on_load0()
      nvim.ex.augroup("conjure_clojure_nrepl_cleanup")
      nvim.ex.autocmd_()
      nvim.ex.autocmd("VimLeavePre *", bridge["viml->lua"]("conjure.client.clojure.nrepl.server", "disconnect", {}))
      nvim.ex.augroup("END")
      return action["connect-port-file"]()
    end
    v_23_0_0 = on_load0
    _0_0["on-load"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["on-load"] = v_23_0_
  on_load = v_23_0_
end
return nil