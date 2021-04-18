local _0_0
do
  local module_0_ = {}
  package.loaded["conjure.client.clojure.nrepl.action"] = module_0_
  _0_0 = module_0_
end
local _local_0_ = {require("conjure.aniseed.core"), require("conjure.config"), require("conjure.editor"), require("conjure.aniseed.eval"), require("conjure.extract"), require("conjure.fs"), require("conjure.linked-list"), require("conjure.log"), require("conjure.remote.nrepl"), require("conjure.aniseed.nvim"), require("conjure.client.clojure.nrepl.parse"), require("conjure.client.clojure.nrepl.server"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.client.clojure.nrepl.ui"), require("conjure.aniseed.view")}
local a = _local_0_[1]
local nvim = _local_0_[10]
local parse = _local_0_[11]
local server = _local_0_[12]
local str = _local_0_[13]
local text = _local_0_[14]
local ui = _local_0_[15]
local view = _local_0_[16]
local config = _local_0_[2]
local editor = _local_0_[3]
local eval = _local_0_[4]
local extract = _local_0_[5]
local fs = _local_0_[6]
local ll = _local_0_[7]
local log = _local_0_[8]
local nrepl = _local_0_[9]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "conjure.client.clojure.nrepl.action"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local function require_ns(ns)
  if ns then
    local function _1_()
    end
    return server.eval({code = ("(require '" .. ns .. ")")}, _1_)
  end
end
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
local passive_ns_require
do
  local v_0_
  local function passive_ns_require0()
    if (cfg({"eval", "auto_require"}) and server["connected?"]()) then
      return require_ns(extract.context())
    end
  end
  v_0_ = passive_ns_require0
  _0_0["passive-ns-require"] = v_0_
  passive_ns_require = v_0_
end
local connect_port_file
do
  local v_0_
  local function connect_port_file0(opts)
    local port
    do
      local _1_0 = cfg({"connection", "port_files"})
      if _1_0 then
        local _2_0 = a.map(fs["resolve-above"], _1_0)
        if _2_0 then
          local _3_0 = a.some(a.slurp, _2_0)
          if _3_0 then
            port = tonumber(_3_0)
          else
            port = _3_0
          end
        else
          port = _2_0
        end
      else
        port = _1_0
      end
    end
    if port then
      local function _2_()
        do
          local cb = a.get(opts, "cb")
          if cb then
            cb()
          end
        end
        return passive_ns_require()
      end
      return server.connect({cb = _2_, host = cfg({"connection", "default_host"}), port = port})
    else
      if not a.get(opts, "silent?") then
        return log.append({"; No nREPL port file found"}, {["break?"] = true})
      end
    end
  end
  v_0_ = connect_port_file0
  _0_0["connect-port-file"] = v_0_
  connect_port_file = v_0_
end
local function try_ensure_conn(cb)
  if not server["connected?"]() then
    return connect_port_file({["silent?"] = true, cb = cb})
  else
    if cb then
      return cb()
    end
  end
end
local connect_host_port
do
  local v_0_
  local function connect_host_port0(opts)
    if (not opts.host and not opts.port) then
      return connect_port_file()
    else
      local parsed_port
      if ("string" == type(opts.port)) then
        parsed_port = tonumber(opts.port)
      else
      parsed_port = nil
      end
      if parsed_port then
        return server.connect({cb = passive_ns_require, host = (opts.host or cfg({"connection", "default_host"})), port = parsed_port})
      else
        return log.append({("; Could not parse '" .. opts.port .. "' as a port number")})
      end
    end
  end
  v_0_ = connect_host_port0
  _0_0["connect-host-port"] = v_0_
  connect_host_port = v_0_
end
local function eval_cb_fn(opts)
  local function _1_(resp)
    if (a.get(opts, "on-result") and a.get(resp, "value")) then
      opts["on-result"](resp.value)
    end
    local cb = a.get(opts, "cb")
    if cb then
      return cb(resp)
    else
      if not opts["passive?"] then
        return ui["display-result"](resp, opts)
      end
    end
  end
  return _1_
end
local eval_str
do
  local v_0_
  local function eval_str0(opts)
    local function _1_()
      local function _2_(conn)
        if (opts.context and not a["get-in"](conn, {"seen-ns", opts.context})) then
          local function _3_()
          end
          server.eval({code = ("(ns " .. opts.context .. ")")}, _3_)
          a["assoc-in"](conn, {"seen-ns", opts.context}, true)
        end
        return server.eval(opts, eval_cb_fn(opts))
      end
      return server["with-conn-or-warn"](_2_)
    end
    return try_ensure_conn(_1_)
  end
  v_0_ = eval_str0
  _0_0["eval-str"] = v_0_
  eval_str = v_0_
end
local function with_info(opts, f)
  local function _1_(conn)
    local function _2_(msg)
      local function _3_()
        if not msg.status["no-info"] then
          return msg
        end
      end
      return f(_3_())
    end
    return server.send({ns = (opts.context or "user"), op = "info", session = conn.session, symbol = opts.code}, _2_)
  end
  return server["with-conn-and-op-or-warn"]("info", _1_)
end
local function java_info__3elines(_1_0)
  local _arg_0_ = _1_0
  local arglists_str = _arg_0_["arglists-str"]
  local class = _arg_0_["class"]
  local javadoc = _arg_0_["javadoc"]
  local member = _arg_0_["member"]
  local function _2_()
    if member then
      return {"/", member}
    end
  end
  local _3_
  if not a["empty?"](arglists_str) then
    _3_ = {("; (" .. str.join(" ", text["split-lines"](arglists_str)) .. ")")}
  else
  _3_ = nil
  end
  local function _5_()
    if javadoc then
      return {("; " .. javadoc)}
    end
  end
  return a.concat({str.join(a.concat({"; ", class}, _2_()))}, _3_, _5_())
end
local doc_str
do
  local v_0_
  local function doc_str0(opts)
    local function _2_()
      require_ns("clojure.repl")
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
          log.append({"; No results, checking CIDER's info op"})
          local function _5_(info)
            if a["nil?"](info) then
              return log.append({"; Nothing found via CIDER's info either"})
            elseif info.javadoc then
              return log.append(java_info__3elines(info))
            elseif info.doc then
              return log.append(a.concat({("; " .. info.ns .. "/" .. info.name), ("; (" .. info["arglists-str"] .. ")")}, text["prefixed-lines"](info.doc, "; ")))
            else
              return log.append(a.concat({"; Unknown result, it may still be helpful"}, text["prefixed-lines"](view.serialise(info), "; ")))
            end
          end
          return with_info(opts, _5_)
        end
      end
      return server.eval(a.merge({}, opts, {code = ("(clojure.repl/doc " .. opts.code .. ")")}), nrepl["with-all-msgs-fn"](_3_))
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = doc_str0
  _0_0["doc-str"] = v_0_
  doc_str = v_0_
end
local function nrepl__3envim_path(path)
  if text["starts-with"](path, "jar:file:") then
    local function _2_(zip, file)
      return ("zipfile:" .. zip .. "::" .. file)
    end
    return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _2_)
  elseif text["starts-with"](path, "file:") then
    local function _2_(file)
      return file
    end
    return string.gsub(path, "^file:(.+)$", _2_)
  else
    return path
  end
end
local def_str
do
  local v_0_
  local function def_str0(opts)
    local function _2_()
      local function _3_(info)
        if a["nil?"](info) then
          return log.append({"; No definition information found"})
        elseif info.candidates then
          local function _4_(_241)
            return (_241 .. "/" .. opts.code)
          end
          return log.append(a.concat({"; Multiple candidates found"}, a.map(_4_, a.keys(info.candidates))))
        elseif info.javadoc then
          return log.append({"; Can't open source, it's Java", ("; " .. info.javadoc)})
        elseif info["special-form"] then
          local function _4_()
            if info.url then
              return ("; " .. info.url)
            end
          end
          return log.append({"; Can't open source, it's a special form", _4_()})
        elseif (info.file and info.line) then
          local column = (info.column or 1)
          local path = nrepl__3envim_path(info.file)
          editor["go-to"](path, info.line, column)
          return log.append({("; " .. path .. " [" .. info.line .. " " .. column .. "]")}, {["suppress-hud?"] = true})
        else
          return log.append({"; Unsupported target", ("; " .. a["pr-str"](info))})
        end
      end
      return with_info(opts, _3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = def_str0
  _0_0["def-str"] = v_0_
  def_str = v_0_
end
local eval_file
do
  local v_0_
  local function eval_file0(opts)
    local function _2_()
      return server.eval(a.assoc(opts, "code", ("(#?(:cljs cljs.core/load-file" .. " :default clojure.core/load-file)" .. " \"" .. opts["file-path"] .. "\")")), eval_cb_fn(opts))
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = eval_file0
  _0_0["eval-file"] = v_0_
  eval_file = v_0_
end
local interrupt
do
  local v_0_
  local function interrupt0()
    local function _2_()
      local function _3_(conn)
        local msgs
        local function _4_(msg)
          return ("eval" == msg.msg.op)
        end
        msgs = a.filter(_4_, a.vals(conn.msgs))
        local order_66
        local function _6_(_5_0)
          local _arg_0_ = _5_0
          local code = _arg_0_["code"]
          local id = _arg_0_["id"]
          local session = _arg_0_["session"]
          server.send({["interrupt-id"] = id, op = "interrupt", session = session})
          local function _7_(sess)
            local function _8_()
              if code then
                return text["left-sample"](code, editor["percent-width"](cfg({"interrupt", "sample_limit"})))
              else
                return ("session: " .. sess.str() .. "")
              end
            end
            return log.append({("; Interrupted: " .. _8_())}, {["break?"] = true})
          end
          return server["enrich-session-id"](session, _7_)
        end
        order_66 = _6_
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
    return try_ensure_conn(_2_)
  end
  v_0_ = interrupt0
  _0_0["interrupt"] = v_0_
  interrupt = v_0_
end
local function eval_str_fn(code)
  local function _2_()
    return nvim.ex.ConjureEval(code)
  end
  return _2_
end
local last_exception
do
  local v_0_ = eval_str_fn("*e")
  _0_0["last-exception"] = v_0_
  last_exception = v_0_
end
local result_1
do
  local v_0_ = eval_str_fn("*1")
  _0_0["result-1"] = v_0_
  result_1 = v_0_
end
local result_2
do
  local v_0_ = eval_str_fn("*2")
  _0_0["result-2"] = v_0_
  result_2 = v_0_
end
local result_3
do
  local v_0_ = eval_str_fn("*3")
  _0_0["result-3"] = v_0_
  result_3 = v_0_
end
local view_source
do
  local v_0_
  local function view_source0()
    local function _2_()
      local word = a.get(extract.word(), "content")
      if not a["empty?"](word) then
        log.append({("; source (word): " .. word)}, {["break?"] = true})
        require_ns("clojure.repl")
        local function _3_(_241)
          return ui["display-result"](_241, {["ignore-nil?"] = true, ["raw-out?"] = true})
        end
        return eval_str({cb = _3_, code = ("(clojure.repl/source " .. word .. ")"), context = extract.context()})
      end
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = view_source0
  _0_0["view-source"] = v_0_
  view_source = v_0_
end
local clone_current_session
do
  local v_0_
  local function clone_current_session0()
    local function _2_()
      local function _3_(conn)
        return server["enrich-session-id"](a.get(conn, "session"), server["clone-session"])
      end
      return server["with-conn-or-warn"](_3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = clone_current_session0
  _0_0["clone-current-session"] = v_0_
  clone_current_session = v_0_
end
local clone_fresh_session
do
  local v_0_
  local function clone_fresh_session0()
    local function _2_()
      local function _3_(conn)
        return server["clone-session"]()
      end
      return server["with-conn-or-warn"](_3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = clone_fresh_session0
  _0_0["clone-fresh-session"] = v_0_
  clone_fresh_session = v_0_
end
local close_current_session
do
  local v_0_
  local function close_current_session0()
    local function _2_()
      local function _3_(conn)
        local function _4_(sess)
          a.assoc(conn, "session", nil)
          log.append({("; Closed current session: " .. sess.str())}, {["break?"] = true})
          local function _5_()
            return server["assume-or-create-session"]()
          end
          return server["close-session"](sess, _5_)
        end
        return server["enrich-session-id"](a.get(conn, "session"), _4_)
      end
      return server["with-conn-or-warn"](_3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = close_current_session0
  _0_0["close-current-session"] = v_0_
  close_current_session = v_0_
end
local display_sessions
do
  local v_0_
  local function display_sessions0(cb)
    local function _2_()
      local function _3_(sessions)
        return ui["display-sessions"](sessions, cb)
      end
      return server["with-sessions"](_3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = display_sessions0
  _0_0["display-sessions"] = v_0_
  display_sessions = v_0_
end
local close_all_sessions
do
  local v_0_
  local function close_all_sessions0()
    local function _2_()
      local function _3_(sessions)
        a["run!"](server["close-session"], sessions)
        log.append({("; Closed all sessions (" .. a.count(sessions) .. ")")}, {["break?"] = true})
        return server["clone-session"]()
      end
      return server["with-sessions"](_3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = close_all_sessions0
  _0_0["close-all-sessions"] = v_0_
  close_all_sessions = v_0_
end
local function cycle_session(f)
  local function _2_()
    local function _3_(conn)
      local function _4_(sessions)
        if (1 == a.count(sessions)) then
          return log.append({"; No other sessions"}, {["break?"] = true})
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
  return try_ensure_conn(_2_)
end
local next_session
do
  local v_0_
  local function next_session0()
    local function _2_(current, node)
      return (current == a.get(ll.val(ll.prev(node)), "id"))
    end
    return cycle_session(_2_)
  end
  v_0_ = next_session0
  _0_0["next-session"] = v_0_
  next_session = v_0_
end
local prev_session
do
  local v_0_
  local function prev_session0()
    local function _2_(current, node)
      return (current == a.get(ll.val(ll.next(node)), "id"))
    end
    return cycle_session(_2_)
  end
  v_0_ = prev_session0
  _0_0["prev-session"] = v_0_
  prev_session = v_0_
end
local select_session_interactive
do
  local v_0_
  local function select_session_interactive0()
    local function _2_()
      local function _3_(sessions)
        if (1 == a.count(sessions)) then
          return log.append({"; No other sessions"}, {["break?"] = true})
        else
          local function _4_()
            nvim.ex.redraw_()
            local n = nvim.fn.str2nr(extract.prompt("Session number: "))
            if (function(_5_,_6_,_7_) return (_5_ <= _6_) and (_6_ <= _7_) end)(1,n,a.count(sessions)) then
              return server["assume-session"](a.get(sessions, n))
            else
              return log.append({"; Invalid session number."})
            end
          end
          return ui["display-sessions"](sessions, _4_)
        end
      end
      return server["with-sessions"](_3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = select_session_interactive0
  _0_0["select-session-interactive"] = v_0_
  select_session_interactive = v_0_
end
local test_runners = {clojure = {["all-fn"] = "run-all-tests", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", namespace = "clojure.test"}, kaocha = {["all-fn"] = "run-all", ["default-call-suffix"] = "{:kaocha/color? false}", ["name-prefix"] = "#'", ["name-suffix"] = "", ["ns-fn"] = "run", ["single-fn"] = "run", namespace = "kaocha.repl"}}
local function test_cfg(k)
  local runner = cfg({"test", "runner"})
  return (a["get-in"](test_runners, {runner, k}) or error(str.join({"No test-runners configuration for ", runner, " / ", k})))
end
local function require_test_runner()
  return require_ns(test_cfg("namespace"))
end
local function test_runner_code(fn_config_name, ...)
  return ("(" .. str.join(" ", {(test_cfg("namespace") .. "/" .. test_cfg((fn_config_name .. "-fn"))), ...}) .. (cfg({"test", "call_suffix"}) or test_cfg("default-call-suffix")) .. ")")
end
local run_all_tests
do
  local v_0_
  local function run_all_tests0()
    local function _2_()
      log.append({"; run-all-tests"}, {["break?"] = true})
      require_test_runner()
      local function _3_(_241)
        return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
      end
      return server.eval({code = test_runner_code("all")}, _3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = run_all_tests0
  _0_0["run-all-tests"] = v_0_
  run_all_tests = v_0_
end
local function run_ns_tests(ns)
  local function _2_()
    if ns then
      log.append({("; run-ns-tests: " .. ns)}, {["break?"] = true})
      require_test_runner()
      local function _3_(_241)
        return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
      end
      return server.eval({code = test_runner_code("ns", ("'" .. ns))}, _3_)
    end
  end
  return try_ensure_conn(_2_)
end
local run_current_ns_tests
do
  local v_0_
  local function run_current_ns_tests0()
    return run_ns_tests(extract.context())
  end
  v_0_ = run_current_ns_tests0
  _0_0["run-current-ns-tests"] = v_0_
  run_current_ns_tests = v_0_
end
local run_alternate_ns_tests
do
  local v_0_
  local function run_alternate_ns_tests0()
    local current_ns = extract.context()
    local function _2_()
      if text["ends-with"](current_ns, "-test") then
        return string.sub(current_ns, 1, -6)
      else
        return (current_ns .. "-test")
      end
    end
    return run_ns_tests(_2_())
  end
  v_0_ = run_alternate_ns_tests0
  _0_0["run-alternate-ns-tests"] = v_0_
  run_alternate_ns_tests = v_0_
end
local extract_test_name_from_form
do
  local v_0_
  local function extract_test_name_from_form0(form)
    local seen_deftest_3f = false
    local function _2_(part)
      local function _3_(config_current_form_name)
        return text["ends-with"](part, config_current_form_name)
      end
      if a.some(_3_, cfg({"test", "current_form_names"})) then
        seen_deftest_3f = true
        return false
      elseif seen_deftest_3f then
        return part
      end
    end
    return a.some(_2_, str.split(parse["strip-meta"](form), "%s+"))
  end
  v_0_ = extract_test_name_from_form0
  _0_0["extract-test-name-from-form"] = v_0_
  extract_test_name_from_form = v_0_
end
local run_current_test
do
  local v_0_
  local function run_current_test0()
    local function _2_()
      local form = extract.form({["root?"] = true})
      if form then
        local test_name = extract_test_name_from_form(form.content)
        if test_name then
          log.append({("; run-current-test: " .. test_name)}, {["break?"] = true})
          require_test_runner()
          local function _3_(msgs)
            if ((2 == a.count(msgs)) and ("nil" == a.get(a.first(msgs), "value"))) then
              return log.append({"; Success!"})
            else
              local function _4_(_241)
                return ui["display-result"](_241, {["ignore-nil?"] = true, ["simple-out?"] = true})
              end
              return a["run!"](_4_, msgs)
            end
          end
          return server.eval({code = test_runner_code("single", (test_cfg("name-prefix") .. test_name .. test_cfg("name-suffix"))), context = extract.context()}, nrepl["with-all-msgs-fn"](_3_))
        end
      end
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = run_current_test0
  _0_0["run-current-test"] = v_0_
  run_current_test = v_0_
end
local function refresh_impl(op)
  local function _2_(conn)
    local function _3_(msg)
      if msg.reloading then
        return log.append(msg.reloading)
      elseif msg.error then
        return log.append({str.join(" ", {"; Error while reloading", msg["error-ns"]})})
      elseif msg.status.ok then
        return log.append({"; Refresh complete"})
      elseif msg.status.done then
        return nil
      else
        return ui["display-result"](msg)
      end
    end
    return server.send(a.merge({after = cfg({"refresh", "after"}), before = cfg({"refresh", "before"}), dirs = cfg({"refresh", "dirs"}), op = op, session = conn.session}), _3_)
  end
  return server["with-conn-and-op-or-warn"](op, _2_)
end
local refresh_changed
do
  local v_0_
  local function refresh_changed0()
    local function _2_()
      log.append({"; Refreshing changed namespaces"}, {["break?"] = true})
      return refresh_impl("refresh")
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = refresh_changed0
  _0_0["refresh-changed"] = v_0_
  refresh_changed = v_0_
end
local refresh_all
do
  local v_0_
  local function refresh_all0()
    local function _2_()
      log.append({"; Refreshing all namespaces"}, {["break?"] = true})
      return refresh_impl("refresh-all")
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = refresh_all0
  _0_0["refresh-all"] = v_0_
  refresh_all = v_0_
end
local refresh_clear
do
  local v_0_
  local function refresh_clear0()
    local function _2_()
      log.append({"; Clearing refresh cache"}, {["break?"] = true})
      local function _3_(conn)
        local function _4_(msgs)
          return log.append({"; Clearing complete"})
        end
        return server.send({op = "refresh-clear", session = conn.session}, nrepl["with-all-msgs-fn"](_4_))
      end
      return server["with-conn-and-op-or-warn"]("refresh-clear", _3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = refresh_clear0
  _0_0["refresh-clear"] = v_0_
  refresh_clear = v_0_
end
local shadow_select
do
  local v_0_
  local function shadow_select0(build)
    local function _2_()
      local function _3_(conn)
        log.append({("; shadow-cljs (select): " .. build)}, {["break?"] = true})
        server.eval({code = ("(shadow.cljs.devtools.api/nrepl-select :" .. build .. ")")}, ui["display-result"])
        return passive_ns_require()
      end
      return server["with-conn-or-warn"](_3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = shadow_select0
  _0_0["shadow-select"] = v_0_
  shadow_select = v_0_
end
local piggieback
do
  local v_0_
  local function piggieback0(code)
    local function _2_()
      local function _3_(conn)
        log.append({("; piggieback: " .. code)}, {["break?"] = true})
        require_ns("cider.piggieback")
        server.eval({code = ("(cider.piggieback/cljs-repl " .. code .. ")")}, ui["display-result"])
        return passive_ns_require()
      end
      return server["with-conn-or-warn"](_3_)
    end
    return try_ensure_conn(_2_)
  end
  v_0_ = piggieback0
  _0_0["piggieback"] = v_0_
  piggieback = v_0_
end
local function clojure__3evim_completion(_2_0)
  local _arg_0_ = _2_0
  local arglists = _arg_0_["arglists"]
  local word = _arg_0_["candidate"]
  local info = _arg_0_["doc"]
  local ns = _arg_0_["ns"]
  local kind = _arg_0_["type"]
  local _3_
  if not a["empty?"](kind) then
    _3_ = string.upper(string.sub(kind, 1, 1))
  else
  _3_ = nil
  end
  local function _5_()
    if arglists then
      return table.concat(arglists, " ")
    end
  end
  return {info = info, kind = _3_, menu = table.concat({ns, _5_()}, " "), word = word}
end
local function extract_completion_context(prefix)
  local root_form = extract.form({["root?"] = true})
  if root_form then
    local _let_0_ = root_form
    local content = _let_0_["content"]
    local range = _let_0_["range"]
    local lines = text["split-lines"](content)
    local _let_1_ = nvim.win_get_cursor(0)
    local row = _let_1_[1]
    local col = _let_1_[2]
    local lrow = (row - a["get-in"](range, {"start", 1}))
    local line_index = a.inc(lrow)
    local lcol
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
local function enhanced_cljs_completion_3f()
  return cfg({"completion", "cljs", "use_suitable"})
end
local completions
do
  local v_0_
  local function completions0(opts)
    local function _3_(conn)
      local _4_
      if enhanced_cljs_completion_3f() then
        _4_ = "t"
      else
      _4_ = nil
      end
      local _6_
      if cfg({"completion", "with_context"}) then
        _6_ = extract_completion_context(opts.prefix)
      else
      _6_ = nil
      end
      local function _8_(msgs)
        return opts.cb(a.map(clojure__3evim_completion, a.get(a.last(msgs), "completions")))
      end
      return server.send({["enhanced-cljs-completion?"] = _4_, ["extra-metadata"] = {"arglists", "doc"}, context = _6_, ns = opts.context, op = "complete", session = conn.session, symbol = opts.prefix}, nrepl["with-all-msgs-fn"](_8_))
    end
    return server["with-conn-and-op-or-warn"]("complete", _3_, {["else"] = opts.cb, ["silent?"] = true})
  end
  v_0_ = completions0
  _0_0["completions"] = v_0_
  completions = v_0_
end
local out_subscribe
do
  local v_0_
  local function out_subscribe0()
    try_ensure_conn()
    log.append({"; Subscribing to out"}, {["break?"] = true})
    local function _3_(conn)
      return server.send({op = "out-subscribe"})
    end
    return server["with-conn-and-op-or-warn"]("out-subscribe", _3_)
  end
  v_0_ = out_subscribe0
  _0_0["out-subscribe"] = v_0_
  out_subscribe = v_0_
end
local out_unsubscribe
do
  local v_0_
  local function out_unsubscribe0()
    try_ensure_conn()
    log.append({"; Unsubscribing from out"}, {["break?"] = true})
    local function _3_(conn)
      return server.send({op = "out-unsubscribe"})
    end
    return server["with-conn-and-op-or-warn"]("out-unsubscribe", _3_)
  end
  v_0_ = out_unsubscribe0
  _0_0["out-unsubscribe"] = v_0_
  out_unsubscribe = v_0_
end
return nil