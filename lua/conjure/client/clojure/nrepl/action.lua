local _0_0 = nil
do
  local name_23_0_ = "conjure.client.clojure.nrepl.action"
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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.client.clojure.nrepl.config", editor = "conjure.editor", eval = "conjure.aniseed.eval", extract = "conjure.extract", fs = "conjure.fs", ll = "conjure.linked-list", log = "conjure.log", nvim = "conjure.aniseed.nvim", server = "conjure.client.clojure.nrepl.server", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", text = "conjure.text", ui = "conjure.client.clojure.nrepl.ui", view = "conjure.aniseed.view"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.client.clojure.nrepl.config"), require("conjure.editor"), require("conjure.aniseed.eval"), require("conjure.extract"), require("conjure.fs"), require("conjure.linked-list"), require("conjure.log"), require("conjure.aniseed.nvim"), require("conjure.client.clojure.nrepl.server"), require("conjure.client.clojure.nrepl.state"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.client.clojure.nrepl.ui"), require("conjure.aniseed.view")}
end
local _2_ = _1_(...)
local a = _2_[1]
local client = _2_[2]
local config = _2_[3]
local editor = _2_[4]
local eval = _2_[5]
local extract = _2_[6]
local fs = _2_[7]
local ll = _2_[8]
local log = _2_[9]
local nvim = _2_[10]
local server = _2_[11]
local state = _2_[12]
local str = _2_[13]
local text = _2_[14]
local ui = _2_[15]
local view = _2_[16]
do local _ = ({nil, _0_0, nil})[2] end
local display_session_type = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_session_type0()
      local function _3_(msgs)
        return ui.display(text["prefixed-lines"](("Session type: " .. a.get(a.first(msgs), "value")), "; "), {["break?"] = true})
      end
      return server.eval({code = ("#?(" .. str.join(" ", {":clj 'Clojure", ":cljs 'ClojureScript", ":cljr 'ClojureCLR", ":default 'Unknown"}) .. ")")}, server["with-all-msgs-fn"](_3_))
    end
    v_23_0_0 = display_session_type0
    _0_0["display-session-type"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-session-type"] = v_23_0_
  display_session_type = v_23_0_
end
local passive_ns_require = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function passive_ns_require0()
      if config.eval["auto-require?"] then
        local function _3_(conn)
          local ns = extract.context()
          if ns then
            local function _4_()
            end
            return server.eval({code = ("(clojure.core/require '" .. ns .. ")")}, _4_)
          end
        end
        return server["with-conn-or-warn"](_3_, {["silent?"] = true})
      end
    end
    v_23_0_0 = passive_ns_require0
    _0_0["passive-ns-require"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["passive-ns-require"] = v_23_0_
  passive_ns_require = v_23_0_
end
local connect_port_file = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function connect_port_file0()
      local port = nil
      do
        local _3_0 = config.connection["port-files"]
        if _3_0 then
          local _4_0 = a.map(fs.resolve, _3_0)
          if _4_0 then
            local _5_0 = a.some(a.slurp, _4_0)
            if _5_0 then
              port = tonumber(_5_0)
            else
              port = _5_0
            end
          else
            port = _4_0
          end
        else
          port = _3_0
        end
      end
      if port then
        server.connect({host = config.connection["default-host"], port = port})
        return passive_ns_require()
      else
        return ui.display({"; No nREPL port file found"}, {["break?"] = true})
      end
    end
    v_23_0_0 = connect_port_file0
    _0_0["connect-port-file"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connect-port-file"] = v_23_0_
  connect_port_file = v_23_0_
end
local connect_host_port = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function connect_host_port0(...)
      local args = {...}
      local _3_
      if (1 == a.count(args)) then
        _3_ = config.connection["default-host"]
      else
        _3_ = a.first(args)
      end
      server.connect({host = _3_, port = tonumber(a.last(args))})
      return passive_ns_require()
    end
    v_23_0_0 = connect_host_port0
    _0_0["connect-host-port"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connect-host-port"] = v_23_0_
  connect_host_port = v_23_0_
end
local eval_cb_fn = nil
do
  local v_23_0_ = nil
  local function eval_cb_fn0(opts)
    local function _3_(resp)
      if (a.get(opts, "on-result") and a.get(resp, "value")) then
        opts["on-result"](resp.value)
      end
      do
        local cb = a.get(opts, "cb")
        if cb then
          return cb(resp)
        else
          return ui["display-result"](resp, opts)
        end
      end
    end
    return _3_
  end
  v_23_0_ = eval_cb_fn0
  _0_0["aniseed/locals"]["eval-cb-fn"] = v_23_0_
  eval_cb_fn = v_23_0_
end
local in_ns = nil
do
  local v_23_0_ = nil
  local function in_ns0(ns)
    local function _3_()
    end
    return server.eval({code = ("(in-ns '" .. (ns or "#?(:cljs cljs.user, :default user)") .. ")")}, _3_)
  end
  v_23_0_ = in_ns0
  _0_0["aniseed/locals"]["in-ns"] = v_23_0_
  in_ns = v_23_0_
end
local eval_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_str0(opts)
      local function _3_(_)
        in_ns(opts.context)
        return server.eval(opts, eval_cb_fn(opts))
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = eval_str0
    _0_0["eval-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-str"] = v_23_0_
  eval_str = v_23_0_
end
local with_info = nil
do
  local v_23_0_ = nil
  local function with_info0(opts, f)
    local function _3_(conn)
      local function _4_(msg)
        local function _5_()
          if not msg.status["no-info"] then
            return msg
          end
        end
        return f(_5_())
      end
      return server.send({ns = (opts.context or "user"), op = "info", session = conn.session, symbol = opts.code}, _4_)
    end
    return server["with-conn-and-op-or-warn"]("info", _3_)
  end
  v_23_0_ = with_info0
  _0_0["aniseed/locals"]["with-info"] = v_23_0_
  with_info = v_23_0_
end
local java_info__3elines = nil
do
  local v_23_0_ = nil
  local function java_info__3elines0(_3_0)
    local _4_ = _3_0
    local arglists_str = _4_["arglists-str"]
    local class = _4_["class"]
    local member = _4_["member"]
    local javadoc = _4_["javadoc"]
    local function _5_()
      if member then
        return {"/", member}
      end
    end
    local _6_
    if not a["empty?"](arglists_str) then
      _6_ = {("; (" .. str.join(" ", text["split-lines"](arglists_str)) .. ")")}
    else
    _6_ = nil
    end
    local function _8_()
      if javadoc then
        return {("; " .. javadoc)}
      end
    end
    return a.concat({str.join(a.concat({"; ", class}, _5_()))}, _6_, _8_())
  end
  v_23_0_ = java_info__3elines0
  _0_0["aniseed/locals"]["java-info->lines"] = v_23_0_
  java_info__3elines = v_23_0_
end
local doc_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function doc_str0(opts)
      in_ns(opts.context)
      local function _3_(msgs)
        local function _4_(msg)
          return (a.get(msg, "out") or a.get(msg, "err"))
        end
        if a.some(_4_, msgs) then
          local function _5_(_241)
            return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
          end
          return a["run!"](_5_, msgs)
        else
          ui.display({"; No results, checking CIDER's info op"})
          local function _5_(info)
            if a["nil?"](info) then
              return ui.display({"; Nothing found via CIDER's info either"})
            elseif info.javadoc then
              return ui.display(java_info__3elines(info))
            else
              return ui.display(a.concat({"; Unknown result, it may still be helpful"}, text["prefixed-lines"](view.serialise(info), "; ")))
            end
          end
          return with_info(opts, _5_)
        end
      end
      return server.eval(a.merge({}, opts, {code = ("(do (require 'clojure.repl)" .. "(clojure.repl/doc " .. opts.code .. "))")}), server["with-all-msgs-fn"](_3_))
    end
    v_23_0_0 = doc_str0
    _0_0["doc-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_23_0_
  doc_str = v_23_0_
end
local nrepl__3envim_path = nil
do
  local v_23_0_ = nil
  local function nrepl__3envim_path0(path)
    if text["starts-with"](path, "jar:file:") then
      local function _3_(zip, file)
        return ("zipfile:" .. zip .. "::" .. file)
      end
      return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _3_)
    elseif text["starts-with"](path, "file:") then
      local function _3_(file)
        return file
      end
      return string.gsub(path, "^file:(.+)$", _3_)
    else
      return path
    end
  end
  v_23_0_ = nrepl__3envim_path0
  _0_0["aniseed/locals"]["nrepl->nvim-path"] = v_23_0_
  nrepl__3envim_path = v_23_0_
end
local def_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function def_str0(opts)
      local function _3_(info)
        if a["nil?"](info) then
          return ui.display({"; No definition information found"})
        elseif info.candidates then
          local function _4_(_241)
            return (_241 .. "/" .. opts.code)
          end
          return ui.display(a.concat({"; Multiple candidates found"}, a.map(_4_, a.keys(info.candidates))))
        elseif info.javadoc then
          return ui.display({"; Can't open source, it's Java", ("; " .. info.javadoc)})
        elseif info["special-form"] then
          local function _4_()
            if info.url then
              return ("; " .. info.url)
            end
          end
          return ui.display({"; Can't open source, it's a special form", _4_()})
        elseif (info.file and info.line) then
          local column = (info.column or 1)
          local path = nrepl__3envim_path(info.file)
          editor["go-to"](path, info.line, column)
          return ui.display({("; " .. path .. " [" .. info.line .. " " .. column .. "]")}, {["suppress-hud?"] = true})
        else
          return ui.display({"; Unsupported target", ("; " .. a["pr-str"](info))})
        end
      end
      return with_info(opts, _3_)
    end
    v_23_0_0 = def_str0
    _0_0["def-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["def-str"] = v_23_0_
  def_str = v_23_0_
end
local eval_file = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_file0(opts)
      return server.eval(a.assoc(opts, "code", ("(clojure.core/load-file \"" .. opts["file-path"] .. "\")")), eval_cb_fn(opts))
    end
    v_23_0_0 = eval_file0
    _0_0["eval-file"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval-file"] = v_23_0_
  eval_file = v_23_0_
end
local interrupt = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function interrupt0()
      local function _3_(conn)
        local msgs = nil
        local function _4_(msg)
          return ("eval" == msg.msg.op)
        end
        msgs = a.filter(_4_, a.vals(conn.msgs))
        local order_66 = nil
        local function _5_(_6_0)
          local _7_ = _6_0
          local id = _7_["id"]
          local code = _7_["code"]
          local session = _7_["session"]
          server.send({["interrupt-id"] = id, op = "interrupt", session = session})
          local function _8_()
            if code then
              return text["left-sample"](code, editor["percent-width"](config.interrupt["sample-limit"]))
            else
              return ("session (" .. session .. ")")
            end
          end
          return ui.display({("; Interrupted: " .. _8_())}, {["break?"] = true})
        end
        order_66 = _5_
        if a["empty?"](msgs) then
          return order_66({session = conn.session})
        else
          local function _7_(a0, b)
            return (a0["sent-at"] < b["sent-at"])
          end
          table.sort(msgs, _7_)
          return order_66(a.get(a.first(msgs), "msg"))
        end
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = interrupt0
    _0_0["interrupt"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["interrupt"] = v_23_0_
  interrupt = v_23_0_
end
local eval_str_fn = nil
do
  local v_23_0_ = nil
  local function eval_str_fn0(code)
    local function _3_()
      return nvim.ex.ConjureEval(code)
    end
    return _3_
  end
  v_23_0_ = eval_str_fn0
  _0_0["aniseed/locals"]["eval-str-fn"] = v_23_0_
  eval_str_fn = v_23_0_
end
local last_exception = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = eval_str_fn("*e")
    _0_0["last-exception"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["last-exception"] = v_23_0_
  last_exception = v_23_0_
end
local result_1 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = eval_str_fn("*1")
    _0_0["result-1"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["result-1"] = v_23_0_
  result_1 = v_23_0_
end
local result_2 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = eval_str_fn("*2")
    _0_0["result-2"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["result-2"] = v_23_0_
  result_2 = v_23_0_
end
local result_3 = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = eval_str_fn("*3")
    _0_0["result-3"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["result-3"] = v_23_0_
  result_3 = v_23_0_
end
local view_source = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function view_source0()
      local word = a.get(extract.word(), "content")
      if not a["empty?"](word) then
        ui.display({("; source (word): " .. word)}, {["break?"] = true})
        local function _3_(_241)
          return ui["display-result"](_241, {["ignore-nil?"] = true, ["raw-out?"] = true})
        end
        return eval_str({cb = _3_, code = ("(require 'clojure.repl)" .. "(clojure.repl/source " .. word .. ")"), context = extract.context()})
      end
    end
    v_23_0_0 = view_source0
    _0_0["view-source"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["view-source"] = v_23_0_
  view_source = v_23_0_
end
local clone_current_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function clone_current_session0()
      local function _3_(conn)
        return server["clone-session"](a.get(conn, "session"))
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = clone_current_session0
    _0_0["clone-current-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["clone-current-session"] = v_23_0_
  clone_current_session = v_23_0_
end
local clone_fresh_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function clone_fresh_session0()
      local function _3_(conn)
        return server["clone-session"]()
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = clone_fresh_session0
    _0_0["clone-fresh-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["clone-fresh-session"] = v_23_0_
  clone_fresh_session = v_23_0_
end
local close_current_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function close_current_session0()
      local function _3_(conn)
        local session = a.get(conn, "session")
        a.assoc(conn, "session", nil)
        ui.display({("; Closed current session: " .. session)}, {["break?"] = true})
        return server["close-session"](session, server["assume-or-create-session"])
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = close_current_session0
    _0_0["close-current-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["close-current-session"] = v_23_0_
  close_current_session = v_23_0_
end
local display_sessions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_sessions0(cb)
      local function _3_(sessions)
        return ui["display-given-sessions"](sessions, cb)
      end
      return server["with-sessions"](_3_)
    end
    v_23_0_0 = display_sessions0
    _0_0["display-sessions"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["display-sessions"] = v_23_0_
  display_sessions = v_23_0_
end
local close_all_sessions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function close_all_sessions0()
      local function _3_(sessions)
        a["run!"](server["close-session"], sessions)
        ui.display({("; Closed all sessions (" .. a.count(sessions) .. ")")}, {["break?"] = true})
        return server["clone-session"]()
      end
      return server["with-sessions"](_3_)
    end
    v_23_0_0 = close_all_sessions0
    _0_0["close-all-sessions"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["close-all-sessions"] = v_23_0_
  close_all_sessions = v_23_0_
end
local cycle_session = nil
do
  local v_23_0_ = nil
  local function cycle_session0(f)
    local function _3_(conn)
      local function _4_(sessions)
        if (1 == a.count(sessions)) then
          return ui.display({"; No other sessions"}, {["break?"] = true})
        else
          local session = a.get(conn, "session")
          local function _5_(_241)
            return f(session, _241)
          end
          return server["assume-session"](ll.val(ll["until"](_5_, ll.cycle(ll.create(sessions)))))
        end
      end
      return server["with-sessions"](_4_)
    end
    return server["with-conn-or-warn"](_3_)
  end
  v_23_0_ = cycle_session0
  _0_0["aniseed/locals"]["cycle-session"] = v_23_0_
  cycle_session = v_23_0_
end
local next_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function next_session0()
      local function _3_(current, node)
        return (current == ll.val(ll.prev(node)))
      end
      return cycle_session(_3_)
    end
    v_23_0_0 = next_session0
    _0_0["next-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["next-session"] = v_23_0_
  next_session = v_23_0_
end
local prev_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function prev_session0()
      local function _3_(current, node)
        return (current == ll.val(ll.next(node)))
      end
      return cycle_session(_3_)
    end
    v_23_0_0 = prev_session0
    _0_0["prev-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["prev-session"] = v_23_0_
  prev_session = v_23_0_
end
local select_session_interactive = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function select_session_interactive0()
      local function _3_(sessions)
        if (1 == a.count(sessions)) then
          return ui.display({"; No other sessions"}, {["break?"] = true})
        else
          local function _4_()
            nvim.ex.redraw_()
            do
              local n = nvim.fn.str2nr(extract.prompt("Session number: "))
              local _5_ = a.count(sessions)
              if ((1 <= n) and (n <= _5_)) then
                return server["assume-session"](a.get(sessions, n))
              else
                return ui.display({"; Invalid session number."})
              end
            end
          end
          return ui["display-given-sessions"](sessions, _4_)
        end
      end
      return server["with-sessions"](_3_)
    end
    v_23_0_0 = select_session_interactive0
    _0_0["select-session-interactive"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["select-session-interactive"] = v_23_0_
  select_session_interactive = v_23_0_
end
local run_all_tests = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_all_tests0()
      ui.display({"; run-all-tests"}, {["break?"] = true})
      local function _3_(_241)
        return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
      end
      return server.eval({code = "(require 'clojure.test) (clojure.test/run-all-tests)"}, _3_)
    end
    v_23_0_0 = run_all_tests0
    _0_0["run-all-tests"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-all-tests"] = v_23_0_
  run_all_tests = v_23_0_
end
local run_ns_tests = nil
do
  local v_23_0_ = nil
  local function run_ns_tests0(ns)
    if ns then
      ui.display({("; run-ns-tests: " .. ns)}, {["break?"] = true})
      local function _3_(_241)
        return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
      end
      return server.eval({code = ("(require 'clojure.test)" .. "(clojure.test/run-tests '" .. ns .. ")")}, _3_)
    end
  end
  v_23_0_ = run_ns_tests0
  _0_0["aniseed/locals"]["run-ns-tests"] = v_23_0_
  run_ns_tests = v_23_0_
end
local run_current_ns_tests = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_current_ns_tests0()
      return run_ns_tests(extract.context())
    end
    v_23_0_0 = run_current_ns_tests0
    _0_0["run-current-ns-tests"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-current-ns-tests"] = v_23_0_
  run_current_ns_tests = v_23_0_
end
local run_alternate_ns_tests = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_alternate_ns_tests0()
      local current_ns = extract.context()
      local function _3_()
        if text["ends-with"](current_ns, "-test") then
          return string.sub(current_ns, 1, -6)
        else
          return (current_ns .. "-test")
        end
      end
      return run_ns_tests(_3_())
    end
    v_23_0_0 = run_alternate_ns_tests0
    _0_0["run-alternate-ns-tests"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-alternate-ns-tests"] = v_23_0_
  run_alternate_ns_tests = v_23_0_
end
local run_current_test = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function run_current_test0()
      local form = extract.form({["root?"] = true})
      if form then
        local test_name, sub_count = string.gsub(form.content, ".*deftest%s+(.-)%s+.*", "%1")
        if (not a["empty?"](test_name) and (1 == sub_count)) then
          ui.display({("; run-current-test: " .. test_name)}, {["break?"] = true})
          local function _3_(msgs)
            if ((2 == a.count(msgs)) and ("nil" == a.get(a.first(msgs), "value"))) then
              return ui.display({"; Success!"})
            else
              local function _4_(_241)
                return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
              end
              return a["run!"](_4_, msgs)
            end
          end
          return server.eval({code = ("(do (require 'clojure.test)" .. "    (clojure.test/test-var" .. "      (resolve '" .. test_name .. ")))")}, server["with-all-msgs-fn"](_3_))
        end
      end
    end
    v_23_0_0 = run_current_test0
    _0_0["run-current-test"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["run-current-test"] = v_23_0_
  run_current_test = v_23_0_
end
local refresh_impl = nil
do
  local v_23_0_ = nil
  local function refresh_impl0(op)
    local function _3_(conn)
      local function _4_(msg)
        if msg.reloading then
          return ui.display(msg.reloading)
        elseif msg.error then
          return ui.display({("; Error while reloading " .. msg["error-ns"])})
        elseif msg.status.ok then
          return ui.display({"; Refresh complete"})
        elseif msg.status.done then
          return nil
        else
          return ui["display-result"](msg)
        end
      end
      return server.send(a.merge({op = op, session = conn.session}, a.get(config, "refresh")), _4_)
    end
    return server["with-conn-and-op-or-warn"](op, _3_)
  end
  v_23_0_ = refresh_impl0
  _0_0["aniseed/locals"]["refresh-impl"] = v_23_0_
  refresh_impl = v_23_0_
end
local refresh_changed = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function refresh_changed0()
      ui.display({"; Refreshing changed namespaces"}, {["break?"] = true})
      return refresh_impl("refresh")
    end
    v_23_0_0 = refresh_changed0
    _0_0["refresh-changed"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["refresh-changed"] = v_23_0_
  refresh_changed = v_23_0_
end
local refresh_all = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function refresh_all0()
      ui.display({"; Refreshing all namespaces"}, {["break?"] = true})
      return refresh_impl("refresh-all")
    end
    v_23_0_0 = refresh_all0
    _0_0["refresh-all"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["refresh-all"] = v_23_0_
  refresh_all = v_23_0_
end
local refresh_clear = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function refresh_clear0()
      ui.display({"; Clearing refresh state"}, {["break?"] = true})
      local function _3_(conn)
        local function _4_(msgs)
          return ui.display({"; Clearing complete"})
        end
        return server.send({op = "refresh-clear", session = conn.session}, server["with-all-msgs-fn"](_4_))
      end
      return server["with-conn-and-op-or-warn"]("refresh-clear", _3_)
    end
    v_23_0_0 = refresh_clear0
    _0_0["refresh-clear"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["refresh-clear"] = v_23_0_
  refresh_clear = v_23_0_
end
local shadow_select = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function shadow_select0(build)
      local function _3_(conn)
        ui.display({("; shadow-cljs (select): " .. build)}, {["break?"] = true})
        return server.eval({code = ("(shadow.cljs.devtools.api/nrepl-select :" .. build .. ")")}, ui["display-result"])
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = shadow_select0
    _0_0["shadow-select"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["shadow-select"] = v_23_0_
  shadow_select = v_23_0_
end
local piggieback = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function piggieback0(code)
      local function _3_(conn)
        ui.display({("; piggieback: " .. code)}, {["break?"] = true})
        return server.eval({code = ("(do (require 'cider.piggieback)" .. "(cider.piggieback/cljs-repl " .. code .. "))")}, ui["display-result"])
      end
      return server["with-conn-or-warn"](_3_)
    end
    v_23_0_0 = piggieback0
    _0_0["piggieback"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["piggieback"] = v_23_0_
  piggieback = v_23_0_
end
local clojure__3evim_completion = nil
do
  local v_23_0_ = nil
  local function clojure__3evim_completion0(_3_0)
    local _4_ = _3_0
    local word = _4_["candidate"]
    local kind = _4_["type"]
    local ns = _4_["ns"]
    local arglists = _4_["arglists"]
    local info = _4_["doc"]
    local _5_
    if not a["empty?"](kind) then
      _5_ = string.upper(string.sub(kind, 1, 1))
    else
    _5_ = nil
    end
    local function _7_()
      if arglists then
        return {str.join(" ", arglists)}
      end
    end
    return {info = info, kind = _5_, menu = str.join(" ", a.concat({ns}, _7_())), word = word}
  end
  v_23_0_ = clojure__3evim_completion0
  _0_0["aniseed/locals"]["clojure->vim-completion"] = v_23_0_
  clojure__3evim_completion = v_23_0_
end
local extract_completion_context = nil
do
  local v_23_0_ = nil
  local function extract_completion_context0(prefix)
    local root_form = extract.form({["root?"] = true})
    if root_form then
      local _3_ = root_form
      local range = _3_["range"]
      local content = _3_["content"]
      local lines = text["split-lines"](content)
      local _4_ = nvim.win_get_cursor(0)
      local row = _4_[1]
      local col = _4_[2]
      local lrow = (row - a["get-in"](range, {"start", 1}))
      local line_index = a.inc(lrow)
      local lcol = nil
      if (lrow == 0) then
        lcol = (col - a["get-in"](range, {"start", 2}))
      else
        lcol = col
      end
      local original = a.get(lines, line_index)
      local spliced = (string.sub(original, 1, lcol) .. "__prefix__" .. string.sub(original, a.inc(lcol)))
      return str.join("\n", a.assoc(lines, line_index, spliced))
    end
  end
  v_23_0_ = extract_completion_context0
  _0_0["aniseed/locals"]["extract-completion-context"] = v_23_0_
  extract_completion_context = v_23_0_
end
local completions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function completions0(opts)
      local function _3_(conn)
        local function _4_(msgs)
          return opts.cb(a.map(clojure__3evim_completion, a.get(a.last(msgs), "completions")))
        end
        return server.send({["enhanced-cljs-completion?"] = "t", ["extra-metadata"] = {"arglists", "doc"}, context = extract_completion_context(opts.prefix), ns = opts.context, op = "complete", symbol = opts.prefix}, server["with-all-msgs-fn"](_4_))
      end
      local function _4_()
        return opts.cb({})
      end
      return server["with-conn-and-op-or-warn"]("complete", _3_, {["else"] = _4_, ["silent?"] = true})
    end
    v_23_0_0 = completions0
    _0_0["completions"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["completions"] = v_23_0_
  completions = v_23_0_
end
local out_subscribe = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function out_subscribe0()
      ui.display({"; Subscribing to out"}, {["break?"] = true})
      local function _3_(conn)
        return server.send({op = "out-subscribe"})
      end
      return server["with-conn-and-op-or-warn"]("out-subscribe", _3_)
    end
    v_23_0_0 = out_subscribe0
    _0_0["out-subscribe"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["out-subscribe"] = v_23_0_
  out_subscribe = v_23_0_
end
local out_unsubscribe = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function out_unsubscribe0()
      ui.display({"; Unsubscribing from out"}, {["break?"] = true})
      local function _3_(conn)
        return server.send({op = "out-unsubscribe"})
      end
      return server["with-conn-and-op-or-warn"]("out-unsubscribe", _3_)
    end
    v_23_0_0 = out_unsubscribe0
    _0_0["out-unsubscribe"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["out-unsubscribe"] = v_23_0_
  out_unsubscribe = v_23_0_
end
return nil