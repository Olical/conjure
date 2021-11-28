local _2afile_2a = "fnl/conjure/client/clojure/nrepl/action.fnl"
local _2amodule_name_2a = "conjure.client.clojure.nrepl.action"
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
local a, client, config, editor, eval, extract, fs, ll, log, nrepl, nvim, parse, process, server, state, str, text, ui, view = autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.config"), autoload("conjure.editor"), autoload("conjure.aniseed.eval"), autoload("conjure.extract"), autoload("conjure.fs"), autoload("conjure.linked-list"), autoload("conjure.log"), autoload("conjure.remote.nrepl"), autoload("conjure.aniseed.nvim"), autoload("conjure.client.clojure.nrepl.parse"), autoload("conjure.process"), autoload("conjure.client.clojure.nrepl.server"), autoload("conjure.client.clojure.nrepl.state"), autoload("conjure.aniseed.string"), autoload("conjure.text"), autoload("conjure.client.clojure.nrepl.ui"), autoload("conjure.aniseed.view")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["config"] = config
_2amodule_locals_2a["editor"] = editor
_2amodule_locals_2a["eval"] = eval
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["ll"] = ll
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nrepl"] = nrepl
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["parse"] = parse
_2amodule_locals_2a["process"] = process
_2amodule_locals_2a["server"] = server
_2amodule_locals_2a["state"] = state
_2amodule_locals_2a["str"] = str
_2amodule_locals_2a["text"] = text
_2amodule_locals_2a["ui"] = ui
_2amodule_locals_2a["view"] = view
local function require_ns(ns)
  if ns then
    local function _1_()
    end
    return server.eval({code = ("(require '" .. ns .. ")")}, _1_)
  else
    return nil
  end
end
_2amodule_locals_2a["require-ns"] = require_ns
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
do end (_2amodule_locals_2a)["cfg"] = cfg
local function passive_ns_require()
  if (cfg({"eval", "auto_require"}) and server["connected?"]()) then
    return require_ns(extract.context())
  else
    return nil
  end
end
_2amodule_2a["passive-ns-require"] = passive_ns_require
local function delete_auto_repl_port_file()
  local port_file = cfg({"connection", "auto_repl", "port_file"})
  local port = cfg({"connection", "auto_repl", "port"})
  if (port_file and port and (a.slurp(port_file) == port)) then
    return nvim.fn.delete(port_file)
  else
    return nil
  end
end
_2amodule_2a["delete-auto-repl-port-file"] = delete_auto_repl_port_file
local function upsert_auto_repl_proc()
  local cmd = cfg({"connection", "auto_repl", "cmd"})
  local port_file = cfg({"connection", "auto_repl", "port_file"})
  local port = cfg({"connection", "auto_repl", "port"})
  local enabled_3f = cfg({"connection", "auto_repl", "enabled"})
  local hidden_3f = cfg({"connection", "auto_repl", "hidden"})
  if (enabled_3f and not process["running?"](state.get("auto-repl-proc")) and process["executable?"](cmd)) then
    local proc = process.execute(cmd, {["hidden?"] = hidden_3f, ["on-exit"] = client.wrap(delete_auto_repl_port_file)})
    a.assoc(state.get(), "auto-repl-proc", proc)
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
_2amodule_locals_2a["upsert-auto-repl-proc"] = upsert_auto_repl_proc
local function connect_port_file(opts)
  local resolved
  do
    local _7_ = cfg({"connection", "port_files"})
    if (_7_ ~= nil) then
      local _8_ = a.map(fs["resolve-above"], _7_)
      if (_8_ ~= nil) then
        local function _9_(path)
          local port = a.slurp(path)
          if port then
            return {path = path, port = tonumber(port)}
          else
            return nil
          end
        end
        resolved = a.some(_9_, _8_)
      else
        resolved = _8_
      end
    else
      resolved = _7_
    end
  end
  if resolved then
    local _14_
    do
      local t_13_ = resolved
      if (nil ~= t_13_) then
        t_13_ = (t_13_).path
      else
      end
      _14_ = t_13_
    end
    local _17_
    do
      local t_16_ = resolved
      if (nil ~= t_16_) then
        t_16_ = (t_16_).port
      else
      end
      _17_ = t_16_
    end
    local function _19_()
      do
        local cb = a.get(opts, "cb")
        if cb then
          cb()
        else
        end
      end
      return passive_ns_require()
    end
    return server.connect({host = cfg({"connection", "default_host"}), port_file_path = _14_, port = _17_, cb = _19_})
  else
    if not a.get(opts, "silent?") then
      log.append({"; No nREPL port file found"}, {["break?"] = true})
      return upsert_auto_repl_proc()
    else
      return nil
    end
  end
end
_2amodule_2a["connect-port-file"] = connect_port_file
local function try_ensure_conn(cb)
  if not server["connected?"]() then
    return connect_port_file({["silent?"] = true, cb = cb})
  else
    if cb then
      return cb()
    else
      return nil
    end
  end
end
_2amodule_locals_2a["try-ensure-conn"] = try_ensure_conn
local function connect_host_port(opts)
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
      return server.connect({host = (opts.host or cfg({"connection", "default_host"})), port = parsed_port, cb = passive_ns_require})
    else
      return log.append({("; Could not parse '" .. opts.port .. "' as a port number")})
    end
  end
end
_2amodule_2a["connect-host-port"] = connect_host_port
local function eval_cb_fn(opts)
  local function _28_(resp)
    if (a.get(opts, "on-result") and a.get(resp, "value")) then
      opts["on-result"](resp.value)
    else
    end
    local cb = a.get(opts, "cb")
    if cb then
      return cb(resp)
    else
      if not opts["passive?"] then
        return ui["display-result"](resp, opts)
      else
        return nil
      end
    end
  end
  return _28_
end
_2amodule_locals_2a["eval-cb-fn"] = eval_cb_fn
local function eval_str(opts)
  local function _32_()
    local function _33_(conn)
      if (opts.context and not a["get-in"](conn, {"seen-ns", opts.context})) then
        local function _34_()
        end
        server.eval({code = ("(ns " .. opts.context .. ")")}, _34_)
        a["assoc-in"](conn, {"seen-ns", opts.context}, true)
      else
      end
      return server.eval(opts, eval_cb_fn(opts))
    end
    return server["with-conn-or-warn"](_33_)
  end
  return try_ensure_conn(_32_)
end
_2amodule_2a["eval-str"] = eval_str
local function with_info(opts, f)
  local function _36_(conn)
    local function _37_(msg)
      local function _38_()
        if not msg.status["no-info"] then
          return msg
        else
          return nil
        end
      end
      return f(_38_())
    end
    return server.send({op = "info", ns = (opts.context or "user"), symbol = opts.code, session = conn.session}, _37_)
  end
  return server["with-conn-and-op-or-warn"]("info", _36_)
end
_2amodule_locals_2a["with-info"] = with_info
local function java_info__3elines(_39_)
  local _arg_40_ = _39_
  local arglists_str = _arg_40_["arglists-str"]
  local class = _arg_40_["class"]
  local member = _arg_40_["member"]
  local javadoc = _arg_40_["javadoc"]
  local function _41_()
    if member then
      return {"/", member}
    else
      return nil
    end
  end
  local _42_
  if not a["empty?"](arglists_str) then
    _42_ = {("; (" .. str.join(" ", text["split-lines"](arglists_str)) .. ")")}
  else
    _42_ = nil
  end
  local function _44_()
    if javadoc then
      return {("; " .. javadoc)}
    else
      return nil
    end
  end
  return a.concat({str.join(a.concat({"; ", class}, _41_()))}, _42_, _44_())
end
_2amodule_locals_2a["java-info->lines"] = java_info__3elines
local function doc_str(opts)
  local function _45_()
    require_ns("clojure.repl")
    local function _46_(msgs)
      local function _47_(msg)
        return (a.get(msg, "out") or a.get(msg, "err"))
      end
      if a.some(_47_, msgs) then
        local function _48_(_241)
          return ui["display-result"](_241, {["simple-out?"] = true, ["ignore-nil?"] = true})
        end
        return a["run!"](_48_, msgs)
      else
        log.append({"; No results, checking CIDER's info op"})
        local function _49_(info)
          if a["nil?"](info) then
            return log.append({"; Nothing found via CIDER's info either"})
          elseif ("table" == type(info.javadoc)) then
            return log.append(java_info__3elines(info))
          elseif ("string" == type(info.doc)) then
            return log.append(a.concat({("; " .. info.ns .. "/" .. info.name), ("; (" .. info["arglists-str"] .. ")")}, text["prefixed-lines"](info.doc, "; ")))
          else
            return log.append(a.concat({"; Unknown result, it may still be helpful"}, text["prefixed-lines"](view.serialise(info), "; ")))
          end
        end
        return with_info(opts, _49_)
      end
    end
    return server.eval(a.merge({}, opts, {code = ("(clojure.repl/doc " .. opts.code .. ")")}), nrepl["with-all-msgs-fn"](_46_))
  end
  return try_ensure_conn(_45_)
end
_2amodule_2a["doc-str"] = doc_str
local function nrepl__3envim_path(path)
  if text["starts-with"](path, "jar:file:") then
    local function _52_(zip, file)
      return ("zipfile:" .. zip .. "::" .. file)
    end
    return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _52_)
  elseif text["starts-with"](path, "file:") then
    local function _53_(file)
      return file
    end
    return string.gsub(path, "^file:(.+)$", _53_)
  else
    return path
  end
end
_2amodule_locals_2a["nrepl->nvim-path"] = nrepl__3envim_path
local function def_str(opts)
  local function _55_()
    local function _56_(info)
      if a["nil?"](info) then
        return log.append({"; No definition information found"})
      elseif info.candidates then
        local function _57_(_241)
          return (_241 .. "/" .. opts.code)
        end
        return log.append(a.concat({"; Multiple candidates found"}, a.map(_57_, a.keys(info.candidates))))
      elseif info.javadoc then
        return log.append({"; Can't open source, it's Java", ("; " .. info.javadoc)})
      elseif info["special-form"] then
        local function _58_()
          if info.url then
            return ("; " .. info.url)
          else
            return nil
          end
        end
        return log.append({"; Can't open source, it's a special form", _58_()})
      elseif (info.file and info.line) then
        local column = (info.column or 1)
        local path = nrepl__3envim_path(info.file)
        editor["go-to"](path, info.line, column)
        return log.append({("; " .. path .. " [" .. info.line .. " " .. column .. "]")}, {["suppress-hud?"] = true})
      else
        return log.append({"; Unsupported target", ("; " .. a["pr-str"](info))})
      end
    end
    return with_info(opts, _56_)
  end
  return try_ensure_conn(_55_)
end
_2amodule_2a["def-str"] = def_str
local function eval_file(opts)
  local function _60_()
    return server.eval(a.assoc(opts, "code", ("(#?(:cljs cljs.core/load-file" .. " :default clojure.core/load-file)" .. " \"" .. opts["file-path"] .. "\")")), eval_cb_fn(opts))
  end
  return try_ensure_conn(_60_)
end
_2amodule_2a["eval-file"] = eval_file
local function interrupt()
  local function _61_()
    local function _62_(conn)
      local msgs
      local function _63_(msg)
        return ("eval" == msg.msg.op)
      end
      msgs = a.filter(_63_, a.vals(conn.msgs))
      local order_66
      local function _66_(_64_)
        local _arg_65_ = _64_
        local id = _arg_65_["id"]
        local session = _arg_65_["session"]
        local code = _arg_65_["code"]
        server.send({op = "interrupt", ["interrupt-id"] = id, session = session})
        local function _67_(sess)
          local function _68_()
            if code then
              return text["left-sample"](code, editor["percent-width"](cfg({"interrupt", "sample_limit"})))
            else
              return ("session: " .. sess.str() .. "")
            end
          end
          return log.append({("; Interrupted: " .. _68_())}, {["break?"] = true})
        end
        return server["enrich-session-id"](session, _67_)
      end
      order_66 = _66_
      if a["empty?"](msgs) then
        return order_66({session = conn.session})
      else
        local function _69_(a0, b)
          return (a0["sent-at"] < b["sent-at"])
        end
        table.sort(msgs, _69_)
        return order_66(a.get(a.first(msgs), "msg"))
      end
    end
    return server["with-conn-or-warn"](_62_)
  end
  return try_ensure_conn(_61_)
end
_2amodule_2a["interrupt"] = interrupt
local function eval_str_fn(code)
  local function _71_()
    return nvim.ex.ConjureEval(code)
  end
  return _71_
end
_2amodule_locals_2a["eval-str-fn"] = eval_str_fn
local last_exception = eval_str_fn("*e")
do end (_2amodule_2a)["last-exception"] = last_exception
local result_1 = eval_str_fn("*1")
do end (_2amodule_2a)["result-1"] = result_1
local result_2 = eval_str_fn("*2")
do end (_2amodule_2a)["result-2"] = result_2
local result_3 = eval_str_fn("*3")
do end (_2amodule_2a)["result-3"] = result_3
local function view_source()
  local function _72_()
    local word = a.get(extract.word(), "content")
    if not a["empty?"](word) then
      log.append({("; source (word): " .. word)}, {["break?"] = true})
      require_ns("clojure.repl")
      local function _73_(_241)
        return ui["display-result"](_241, {["raw-out?"] = true, ["ignore-nil?"] = true})
      end
      return eval_str({code = ("(clojure.repl/source " .. word .. ")"), context = extract.context(), cb = _73_})
    else
      return nil
    end
  end
  return try_ensure_conn(_72_)
end
_2amodule_2a["view-source"] = view_source
local function clone_current_session()
  local function _75_()
    local function _76_(conn)
      return server["enrich-session-id"](a.get(conn, "session"), server["clone-session"])
    end
    return server["with-conn-or-warn"](_76_)
  end
  return try_ensure_conn(_75_)
end
_2amodule_2a["clone-current-session"] = clone_current_session
local function clone_fresh_session()
  local function _77_()
    local function _78_(conn)
      return server["clone-session"]()
    end
    return server["with-conn-or-warn"](_78_)
  end
  return try_ensure_conn(_77_)
end
_2amodule_2a["clone-fresh-session"] = clone_fresh_session
local function close_current_session()
  local function _79_()
    local function _80_(conn)
      local function _81_(sess)
        a.assoc(conn, "session", nil)
        log.append({("; Closed current session: " .. sess.str())}, {["break?"] = true})
        local function _82_()
          return server["assume-or-create-session"]()
        end
        return server["close-session"](sess, _82_)
      end
      return server["enrich-session-id"](a.get(conn, "session"), _81_)
    end
    return server["with-conn-or-warn"](_80_)
  end
  return try_ensure_conn(_79_)
end
_2amodule_2a["close-current-session"] = close_current_session
local function display_sessions(cb)
  local function _83_()
    local function _84_(sessions)
      return ui["display-sessions"](sessions, cb)
    end
    return server["with-sessions"](_84_)
  end
  return try_ensure_conn(_83_)
end
_2amodule_2a["display-sessions"] = display_sessions
local function close_all_sessions()
  local function _85_()
    local function _86_(sessions)
      a["run!"](server["close-session"], sessions)
      log.append({("; Closed all sessions (" .. a.count(sessions) .. ")")}, {["break?"] = true})
      return server["clone-session"]()
    end
    return server["with-sessions"](_86_)
  end
  return try_ensure_conn(_85_)
end
_2amodule_2a["close-all-sessions"] = close_all_sessions
local function cycle_session(f)
  local function _87_()
    local function _88_(conn)
      local function _89_(sessions)
        if (1 == a.count(sessions)) then
          return log.append({"; No other sessions"}, {["break?"] = true})
        else
          local session = a.get(conn, "session")
          local function _90_(_241)
            return f(session, _241)
          end
          return server["assume-session"](ll.val(ll["until"](_90_, ll.cycle(ll.create(sessions)))))
        end
      end
      return server["with-sessions"](_89_)
    end
    return server["with-conn-or-warn"](_88_)
  end
  return try_ensure_conn(_87_)
end
_2amodule_locals_2a["cycle-session"] = cycle_session
local function next_session()
  local function _92_(current, node)
    return (current == a.get(ll.val(ll.prev(node)), "id"))
  end
  return cycle_session(_92_)
end
_2amodule_2a["next-session"] = next_session
local function prev_session()
  local function _93_(current, node)
    return (current == a.get(ll.val(ll.next(node)), "id"))
  end
  return cycle_session(_93_)
end
_2amodule_2a["prev-session"] = prev_session
local function select_session_interactive()
  local function _94_()
    local function _95_(sessions)
      if (1 == a.count(sessions)) then
        return log.append({"; No other sessions"}, {["break?"] = true})
      else
        local function _96_()
          nvim.ex.redraw_()
          local n = nvim.fn.str2nr(extract.prompt("Session number: "))
          if (function(_97_,_98_,_99_) return (_97_ <= _98_) and (_98_ <= _99_) end)(1,n,a.count(sessions)) then
            return server["assume-session"](a.get(sessions, n))
          else
            return log.append({"; Invalid session number."})
          end
        end
        return ui["display-sessions"](sessions, _96_)
      end
    end
    return server["with-sessions"](_95_)
  end
  return try_ensure_conn(_94_)
end
_2amodule_2a["select-session-interactive"] = select_session_interactive
local test_runners = {clojure = {namespace = "clojure.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]"}, kaocha = {namespace = "kaocha.repl", ["all-fn"] = "run-all", ["ns-fn"] = "run", ["single-fn"] = "run", ["default-call-suffix"] = "{:kaocha/color? false}", ["name-prefix"] = "#'", ["name-suffix"] = ""}}
_2amodule_locals_2a["test-runners"] = test_runners
local function test_cfg(k)
  local runner = cfg({"test", "runner"})
  return (a["get-in"](test_runners, {runner, k}) or error(str.join({"No test-runners configuration for ", runner, " / ", k})))
end
_2amodule_locals_2a["test-cfg"] = test_cfg
local function require_test_runner()
  return require_ns(test_cfg("namespace"))
end
_2amodule_locals_2a["require-test-runner"] = require_test_runner
local function test_runner_code(fn_config_name, ...)
  return ("(" .. str.join(" ", {(test_cfg("namespace") .. "/" .. test_cfg((fn_config_name .. "-fn"))), ...}) .. (cfg({"test", "call_suffix"}) or test_cfg("default-call-suffix")) .. ")")
end
_2amodule_locals_2a["test-runner-code"] = test_runner_code
local function run_all_tests()
  local function _102_()
    log.append({"; run-all-tests"}, {["break?"] = true})
    require_test_runner()
    local function _103_(_241)
      return ui["display-result"](_241, {["simple-out?"] = true, ["ignore-nil?"] = true, ["raw-out?"] = cfg({"eval", "raw_out"})})
    end
    return server.eval({code = test_runner_code("all")}, _103_)
  end
  return try_ensure_conn(_102_)
end
_2amodule_2a["run-all-tests"] = run_all_tests
local function run_ns_tests(ns)
  local function _104_()
    if ns then
      log.append({("; run-ns-tests: " .. ns)}, {["break?"] = true})
      require_test_runner()
      local function _105_(_241)
        return ui["display-result"](_241, {["simple-out?"] = true, ["ignore-nil?"] = true, ["raw-out?"] = cfg({"eval", "raw_out"})})
      end
      return server.eval({code = test_runner_code("ns", ("'" .. ns))}, _105_)
    else
      return nil
    end
  end
  return try_ensure_conn(_104_)
end
_2amodule_locals_2a["run-ns-tests"] = run_ns_tests
local function run_current_ns_tests()
  return run_ns_tests(extract.context())
end
_2amodule_2a["run-current-ns-tests"] = run_current_ns_tests
local function run_alternate_ns_tests()
  local current_ns = extract.context()
  local function _107_()
    if text["ends-with"](current_ns, "-test") then
      return string.sub(current_ns, 1, -6)
    else
      return (current_ns .. "-test")
    end
  end
  return run_ns_tests(_107_())
end
_2amodule_2a["run-alternate-ns-tests"] = run_alternate_ns_tests
local function extract_test_name_from_form(form)
  local seen_deftest_3f = false
  local function _108_(part)
    local function _109_(config_current_form_name)
      return text["ends-with"](part, config_current_form_name)
    end
    if a.some(_109_, cfg({"test", "current_form_names"})) then
      seen_deftest_3f = true
      return false
    elseif seen_deftest_3f then
      return part
    else
      return nil
    end
  end
  return a.some(_108_, str.split(parse["strip-meta"](form), "%s+"))
end
_2amodule_2a["extract-test-name-from-form"] = extract_test_name_from_form
local function run_current_test()
  local function _111_()
    local form = extract.form({["root?"] = true})
    if form then
      local test_name = extract_test_name_from_form(form.content)
      if test_name then
        log.append({("; run-current-test: " .. test_name)}, {["break?"] = true})
        require_test_runner()
        local function _112_(_241)
          return ui["display-result"](_241, {["simple-out?"] = true, ["ignore-nil?"] = false, ["raw-out?"] = cfg({"eval", "raw_out"})})
        end
        return server.eval({code = test_runner_code("single", (test_cfg("name-prefix") .. test_name .. test_cfg("name-suffix"))), context = extract.context()}, _112_)
      else
        return nil
      end
    else
      return nil
    end
  end
  return try_ensure_conn(_111_)
end
_2amodule_2a["run-current-test"] = run_current_test
local function refresh_impl(op)
  local function _115_(conn)
    local function _116_(msg)
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
    return server.send(a.merge({op = op, session = conn.session, after = cfg({"refresh", "after"}), before = cfg({"refresh", "before"}), dirs = cfg({"refresh", "dirs"})}), _116_)
  end
  return server["with-conn-and-op-or-warn"](op, _115_)
end
_2amodule_locals_2a["refresh-impl"] = refresh_impl
local function refresh_changed()
  local function _118_()
    log.append({"; Refreshing changed namespaces"}, {["break?"] = true})
    return refresh_impl("refresh")
  end
  return try_ensure_conn(_118_)
end
_2amodule_2a["refresh-changed"] = refresh_changed
local function refresh_all()
  local function _119_()
    log.append({"; Refreshing all namespaces"}, {["break?"] = true})
    return refresh_impl("refresh-all")
  end
  return try_ensure_conn(_119_)
end
_2amodule_2a["refresh-all"] = refresh_all
local function refresh_clear()
  local function _120_()
    log.append({"; Clearing refresh cache"}, {["break?"] = true})
    local function _121_(conn)
      local function _122_(msgs)
        return log.append({"; Clearing complete"})
      end
      return server.send({op = "refresh-clear", session = conn.session}, nrepl["with-all-msgs-fn"](_122_))
    end
    return server["with-conn-and-op-or-warn"]("refresh-clear", _121_)
  end
  return try_ensure_conn(_120_)
end
_2amodule_2a["refresh-clear"] = refresh_clear
local function shadow_select(build)
  local function _123_()
    local function _124_(conn)
      log.append({("; shadow-cljs (select): " .. build)}, {["break?"] = true})
      server.eval({code = ("(shadow.cljs.devtools.api/nrepl-select :" .. build .. ")")}, ui["display-result"])
      return passive_ns_require()
    end
    return server["with-conn-or-warn"](_124_)
  end
  return try_ensure_conn(_123_)
end
_2amodule_2a["shadow-select"] = shadow_select
local function piggieback(code)
  local function _125_()
    local function _126_(conn)
      log.append({("; piggieback: " .. code)}, {["break?"] = true})
      require_ns("cider.piggieback")
      server.eval({code = ("(cider.piggieback/cljs-repl " .. code .. ")")}, ui["display-result"])
      return passive_ns_require()
    end
    return server["with-conn-or-warn"](_126_)
  end
  return try_ensure_conn(_125_)
end
_2amodule_2a["piggieback"] = piggieback
local function clojure__3evim_completion(_127_)
  local _arg_128_ = _127_
  local word = _arg_128_["candidate"]
  local kind = _arg_128_["type"]
  local ns = _arg_128_["ns"]
  local info = _arg_128_["doc"]
  local arglists = _arg_128_["arglists"]
  local function _129_()
    if arglists then
      return table.concat(arglists, " ")
    else
      return nil
    end
  end
  local _130_
  if ("string" == type(info)) then
    _130_ = info
  else
    _130_ = nil
  end
  local _132_
  if not a["empty?"](kind) then
    _132_ = string.upper(string.sub(kind, 1, 1))
  else
    _132_ = nil
  end
  return {word = word, menu = table.concat({ns, _129_()}, " "), info = _130_, kind = _132_}
end
_2amodule_locals_2a["clojure->vim-completion"] = clojure__3evim_completion
local function extract_completion_context(prefix)
  local root_form = extract.form({["root?"] = true})
  if root_form then
    local _let_134_ = root_form
    local content = _let_134_["content"]
    local range = _let_134_["range"]
    local lines = text["split-lines"](content)
    local _let_135_ = nvim.win_get_cursor(0)
    local row = _let_135_[1]
    local col = _let_135_[2]
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
  else
    return nil
  end
end
_2amodule_locals_2a["extract-completion-context"] = extract_completion_context
local function enhanced_cljs_completion_3f()
  return cfg({"completion", "cljs", "use_suitable"})
end
_2amodule_locals_2a["enhanced-cljs-completion?"] = enhanced_cljs_completion_3f
local function completions(opts)
  local function _138_(conn)
    local _139_
    if cfg({"completion", "with_context"}) then
      _139_ = extract_completion_context(opts.prefix)
    else
      _139_ = nil
    end
    local _141_
    if enhanced_cljs_completion_3f() then
      _141_ = "t"
    else
      _141_ = nil
    end
    local function _143_(msgs)
      return opts.cb(a.map(clojure__3evim_completion, a.get(a.last(msgs), "completions")))
    end
    return server.send({op = "complete", session = conn.session, ns = opts.context, symbol = opts.prefix, context = _139_, ["extra-metadata"] = {"arglists", "doc"}, ["enhanced-cljs-completion?"] = _141_}, nrepl["with-all-msgs-fn"](_143_))
  end
  return server["with-conn-and-op-or-warn"]("complete", _138_, {["silent?"] = true, ["else"] = opts.cb})
end
_2amodule_2a["completions"] = completions
local function out_subscribe()
  try_ensure_conn()
  log.append({"; Subscribing to out"}, {["break?"] = true})
  local function _144_(conn)
    return server.send({op = "out-subscribe"})
  end
  return server["with-conn-and-op-or-warn"]("out-subscribe", _144_)
end
_2amodule_2a["out-subscribe"] = out_subscribe
local function out_unsubscribe()
  try_ensure_conn()
  log.append({"; Unsubscribing from out"}, {["break?"] = true})
  local function _145_(conn)
    return server.send({op = "out-unsubscribe"})
  end
  return server["with-conn-and-op-or-warn"]("out-unsubscribe", _145_)
end
_2amodule_2a["out-unsubscribe"] = out_unsubscribe