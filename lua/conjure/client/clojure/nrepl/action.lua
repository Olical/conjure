-- [nfnl] fnl/conjure/client/clojure/nrepl/action.fnl
local _local_1_ = require("conjure.nfnl.module")
local autoload = _local_1_.autoload
local define = _local_1_.define
local core = autoload("conjure.nfnl.core")
local auto_repl = autoload("conjure.client.clojure.nrepl.auto-repl")
local config = autoload("conjure.config")
local editor = autoload("conjure.editor")
local extract = autoload("conjure.extract")
local fs = autoload("conjure.fs")
local hook = autoload("conjure.hook")
local ll = autoload("conjure.linked-list")
local log = autoload("conjure.log")
local nrepl = autoload("conjure.remote.nrepl")
local parse = autoload("conjure.client.clojure.nrepl.parse")
local server = autoload("conjure.client.clojure.nrepl.server")
local str = autoload("conjure.nfnl.string")
local text = autoload("conjure.text")
local ui = autoload("conjure.client.clojure.nrepl.ui")
local M = define("conjure.client.clojure.nrepl.action")
local function require_ns(ns)
  if ns then
    local function _2_()
    end
    return server.eval({code = ("(require '" .. ns .. ")")}, _2_)
  else
    return nil
  end
end
local cfg = config["get-in-fn"]({"client", "clojure", "nrepl"})
M["passive-ns-require"] = function()
  if (cfg({"eval", "auto_require"}) and server["connected?"]()) then
    return require_ns(extract.context())
  else
    return nil
  end
end
M["connect-port-file"] = function(opts)
  local resolved_path
  do
    local tmp_6_ = cfg({"connection", "port_files"})
    if (tmp_6_ ~= nil) then
      resolved_path = fs["resolve-above"](tmp_6_)
    else
      resolved_path = nil
    end
  end
  local resolved
  if resolved_path then
    local port = core.slurp(resolved_path)
    if port then
      resolved = {path = resolved_path, port = tonumber(port)}
    else
      resolved = nil
    end
  else
    resolved = nil
  end
  if resolved then
    local _9_
    do
      local t_8_ = resolved
      if (nil ~= t_8_) then
        t_8_ = t_8_.path
      else
      end
      _9_ = t_8_
    end
    local _12_
    do
      local t_11_ = resolved
      if (nil ~= t_11_) then
        t_11_ = t_11_.port
      else
      end
      _12_ = t_11_
    end
    local function _14_()
      do
        local cb = core.get(opts, "cb")
        if cb then
          cb()
        else
        end
      end
      return M["passive-ns-require"]()
    end
    return server.connect({host = cfg({"connection", "default_host"}), port_file_path = _9_, port = _12_, cb = _14_, ["connect-opts"] = core.get(opts, "connect-opts")})
  else
    if not core.get(opts, "silent?") then
      log.append({"; No nREPL port file found"}, {["break?"] = true})
      return auto_repl["upsert-auto-repl-proc"]()
    else
      return nil
    end
  end
end
local function _18_(cb)
  return M["connect-port-file"]({["silent?"] = true, cb = cb})
end
hook.define("client-clojure-nrepl-passive-connect", _18_)
local function try_ensure_conn(cb)
  if not server["connected?"]() then
    return hook.exec("client-clojure-nrepl-passive-connect", cb)
  else
    if cb then
      return cb()
    else
      return nil
    end
  end
end
M["connect-host-port"] = function(opts)
  if (not opts.host and not opts.port) then
    return M["connect-port-file"]()
  else
    local parsed_port
    if ("string" == type(opts.port)) then
      parsed_port = tonumber(opts.port)
    else
      parsed_port = nil
    end
    if parsed_port then
      return server.connect({host = (opts.host or cfg({"connection", "default_host"})), port = parsed_port, cb = M["passive-ns-require"]})
    else
      return log.append({str.join({"; Could not parse '", (opts.port or "nil"), "' as a port number"})})
    end
  end
end
local function eval_cb_fn(opts)
  local function _24_(resp)
    if (core.get(opts, "on-result") and core.get(resp, "value")) then
      opts["on-result"](resp.value)
    else
    end
    local cb = core.get(opts, "cb")
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
  return _24_
end
M["eval-str"] = function(opts)
  local function _28_()
    local function _29_(conn)
      local send_eval_21
      local function _30_()
        return server.eval(opts, eval_cb_fn(opts))
      end
      send_eval_21 = _30_
      if (opts.context and not core["get-in"](conn, {"seen-ns", opts.context})) then
        local function _31_(_msgs)
          return send_eval_21()
        end
        server.eval({code = ("(ns " .. opts.context .. ")"), session = core.get(opts, "session")}, nrepl["with-all-msgs-fn"](_31_))
        return core["assoc-in"](conn, {"seen-ns", opts.context}, true)
      else
        return send_eval_21()
      end
    end
    return server["with-conn-or-warn"](_29_)
  end
  return try_ensure_conn(_28_)
end
local function with_info(opts, f)
  local function _33_(conn, ops)
    local _34_
    if ops.info then
      _34_ = {op = "info", ns = (opts.context or "user"), symbol = opts.code, session = conn.session, ["download-sources-jar"] = 1}
    elseif ops.lookup then
      _34_ = {op = "lookup", ns = (opts.context or "user"), sym = opts.code, session = conn.session}
    else
      _34_ = nil
    end
    local function _36_(msg)
      local function _37_()
        if not msg.status["no-info"] then
          return (msg.info or msg)
        else
          return nil
        end
      end
      return f(_37_())
    end
    return server.send(_34_, _36_)
  end
  return server["with-conn-and-ops-or-warn"]({"info", "lookup"}, _33_)
end
local function java_info__3elines(_38_)
  local arglists_str = _38_["arglists-str"]
  local class = _38_.class
  local member = _38_.member
  local javadoc = _38_.javadoc
  local function _39_()
    if member then
      return {"/", member}
    else
      return nil
    end
  end
  local _40_
  if not core["empty?"](arglists_str) then
    _40_ = {("; (" .. str.join(" ", text["split-lines"](arglists_str)) .. ")")}
  else
    _40_ = nil
  end
  local function _42_()
    if javadoc then
      return {("; " .. javadoc)}
    else
      return nil
    end
  end
  return core.concat({str.join(core.concat({"; ", class}, _39_()))}, _40_, _42_())
end
M["doc-str"] = function(opts)
  local function _43_()
    require_ns("clojure.repl")
    local function _44_(msgs)
      local function _45_(msg)
        return (core.get(msg, "out") or core.get(msg, "err"))
      end
      if core.some(_45_, msgs) then
        local function _46_(_241)
          return ui["display-result"](_241, {["simple-out?"] = true, ["ignore-nil?"] = true})
        end
        return core["run!"](_46_, msgs)
      else
        log.append({"; No results for (doc ...), checking nREPL info ops"})
        local function _47_(info)
          if core["nil?"](info) then
            return log.append({"; No information found, all I can do is wish you good luck and point you to https://duckduckgo.com/"})
          elseif ("string" == type(info.javadoc)) then
            return log.append(java_info__3elines(info))
          elseif ("string" == type(info.doc)) then
            return log.append(core.concat({str.join({"; ", info.ns, "/", info.name}), str.join({"; ", info["arglists-str"]})}, text["prefixed-lines"](info.doc, "; ")))
          else
            return log.append(core.concat({"; Unknown result, it may still be helpful"}, text["prefixed-lines"](core["pr-str"](info), "; ")))
          end
        end
        return with_info(opts, _47_)
      end
    end
    return server.eval(core.merge({}, opts, {code = ("(clojure.repl/doc " .. opts.code .. ")")}), nrepl["with-all-msgs-fn"](_44_))
  end
  return try_ensure_conn(_43_)
end
local function nrepl__3envim_path(path)
  if text["starts-with"](path, "jar:file:") then
    local function _50_(zip, file)
      if (tonumber(string.sub(vim.g.loaded_zipPlugin, 2)) > 31) then
        return ("zipfile://" .. zip .. "::" .. file)
      else
        return ("zipfile:" .. zip .. "::" .. file)
      end
    end
    return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _50_)
  elseif text["starts-with"](path, "file:") then
    local function _52_(file)
      return file
    end
    return string.gsub(path, "^file:(.+)$", _52_)
  else
    return path
  end
end
M["def-str"] = function(opts)
  local function _54_()
    local function _55_(info)
      if core["nil?"](info) then
        return log.append({"; No definition information found"})
      elseif info.candidates then
        local function _56_(_241)
          return (_241 .. "/" .. opts.code)
        end
        return log.append(core.concat({"; Multiple candidates found"}, core.map(_56_, core.keys(info.candidates))))
      elseif (info.file and info.line) then
        local column = (info.column or 1)
        local path = nrepl__3envim_path(info.file)
        editor["go-to"](path, info.line, column)
        return log.append({("; " .. path .. " [" .. info.line .. " " .. column .. "]")}, {["suppress-hud?"] = true})
      elseif info.javadoc then
        return log.append({"; Can't open source, it's Java", ("; " .. info.javadoc)})
      elseif info["special-form"] then
        local function _57_()
          if info.url then
            return ("; " .. info.url)
          else
            return nil
          end
        end
        return log.append({"; Can't open source, it's a special form", _57_()})
      else
        return log.append({"; Unsupported target", ("; " .. core["pr-str"](info))})
      end
    end
    return with_info(opts, _55_)
  end
  return try_ensure_conn(_54_)
end
M["escape-backslashes"] = function(s)
  return s:gsub("\\", "\\\\")
end
M["eval-file"] = function(opts)
  local function _59_()
    local function _60_(conn)
      return server["load-file"](core.assoc(opts, "code", core.slurp(opts["file-path"])), eval_cb_fn(opts))
    end
    return server["with-conn-or-warn"](_60_)
  end
  return try_ensure_conn(_59_)
end
M.interrupt = function()
  local function _61_()
    local function _62_(conn)
      local msgs
      local function _63_(msg)
        return ("eval" == msg.msg.op)
      end
      msgs = core.filter(_63_, core.vals(conn.msgs))
      local order_66
      local function _65_(_64_)
        local id = _64_.id
        local session = _64_.session
        local code = _64_.code
        server.send({op = "interrupt", ["interrupt-id"] = id, session = session})
        local function _66_(sess)
          local _67_
          if code then
            _67_ = text["left-sample"](code, editor["percent-width"](cfg({"interrupt", "sample_limit"})))
          else
            _67_ = ("session: " .. sess.str() .. "")
          end
          return log.append({("; Interrupted: " .. _67_)}, {["break?"] = true})
        end
        return server["enrich-session-id"](session, _66_)
      end
      order_66 = _65_
      if core["empty?"](msgs) then
        return order_66({session = conn.session})
      else
        local function _69_(a, b)
          return (a["sent-at"] < b["sent-at"])
        end
        table.sort(msgs, _69_)
        return order_66(core.get(core.first(msgs), "msg"))
      end
    end
    return server["with-conn-or-warn"](_62_)
  end
  return try_ensure_conn(_61_)
end
local function eval_str_fn(code)
  local function _71_()
    return vim.api.nvim_exec2(("ConjureEval " .. code), {})
  end
  return _71_
end
M["last-exception"] = eval_str_fn("*e")
M["result-1"] = eval_str_fn("*1")
M["result-2"] = eval_str_fn("*2")
M["result-3"] = eval_str_fn("*3")
M["view-tap"] = eval_str_fn("(conjure.internal/dump-tap-queue!)")
M["view-source"] = function()
  local function _72_()
    local word = core.get(extract.word(), "content")
    if not core["empty?"](word) then
      log.append({("; source (word): " .. word)}, {["break?"] = true})
      require_ns("clojure.repl")
      local function _73_(_241)
        return ui["display-result"](_241, {["raw-out?"] = true, ["ignore-nil?"] = true})
      end
      return M["eval-str"]({code = ("(clojure.repl/source " .. word .. ")"), context = extract.context(), cb = _73_})
    else
      return nil
    end
  end
  return try_ensure_conn(_72_)
end
local function eval_macro_expand(expander)
  local function _75_()
    local form = core.get(extract.form({}), "content")
    if not core["empty?"](form) then
      log.append({("; " .. expander .. " (form): " .. form)}, {["break?"] = true})
      local _76_
      if ("clojure.walk/macroexpand-all" == expander) then
        _76_ = "(require 'clojure.walk) "
      else
        _76_ = ""
      end
      local function _78_(_241)
        return ui["display-result"](_241, {["raw-out?"] = true, ["ignore-nil?"] = true})
      end
      return M["eval-str"]({code = (_76_ .. "(" .. expander .. " '" .. form .. ")"), context = extract.context(), cb = _78_})
    else
      return nil
    end
  end
  return try_ensure_conn(_75_)
end
M["macro-expand-1"] = function()
  return eval_macro_expand("macroexpand-1")
end
M["macro-expand"] = function()
  return eval_macro_expand("macroexpand")
end
M["macro-expand-all"] = function()
  return eval_macro_expand("clojure.walk/macroexpand-all")
end
M["clone-current-session"] = function()
  local function _80_()
    local function _81_(conn)
      return server["enrich-session-id"](core.get(conn, "session"), server["clone-session"])
    end
    return server["with-conn-or-warn"](_81_)
  end
  return try_ensure_conn(_80_)
end
M["clone-fresh-session"] = function()
  local function _82_()
    local function _83_(conn)
      return server["clone-session"]()
    end
    return server["with-conn-or-warn"](_83_)
  end
  return try_ensure_conn(_82_)
end
M["close-current-session"] = function()
  local function _84_()
    local function _85_(conn)
      local function _86_(sess)
        core.assoc(conn, "session", nil)
        log.append({("; Closed current session: " .. sess.str())}, {["break?"] = true})
        local function _87_()
          return server["assume-or-create-session"]()
        end
        return server["close-session"](sess, _87_)
      end
      return server["enrich-session-id"](core.get(conn, "session"), _86_)
    end
    return server["with-conn-or-warn"](_85_)
  end
  return try_ensure_conn(_84_)
end
M["display-sessions"] = function(cb)
  local function _88_()
    local function _89_(sessions)
      return ui["display-sessions"](sessions, cb)
    end
    return server["with-sessions"](_89_)
  end
  return try_ensure_conn(_88_)
end
M["close-all-sessions"] = function()
  local function _90_()
    local function _91_(sessions)
      core["run!"](server["close-session"], sessions)
      log.append({("; Closed all sessions (" .. core.count(sessions) .. ")")}, {["break?"] = true})
      return server["clone-session"]()
    end
    return server["with-sessions"](_91_)
  end
  return try_ensure_conn(_90_)
end
local function cycle_session(f)
  local function _92_()
    local function _93_(conn)
      local function _94_(sessions)
        if (1 == core.count(sessions)) then
          return log.append({"; No other sessions"}, {["break?"] = true})
        else
          local session = core.get(conn, "session")
          local function _95_(_241)
            return f(session, _241)
          end
          return server["assume-session"](ll.val(ll["until"](_95_, ll.cycle(ll.create(sessions)))))
        end
      end
      return server["with-sessions"](_94_)
    end
    return server["with-conn-or-warn"](_93_)
  end
  return try_ensure_conn(_92_)
end
M["next-session"] = function()
  local function _97_(current, node)
    return (current == core.get(ll.val(ll.prev(node)), "id"))
  end
  return cycle_session(_97_)
end
M["prev-session"] = function()
  local function _98_(current, node)
    return (current == core.get(ll.val(ll.next(node)), "id"))
  end
  return cycle_session(_98_)
end
M["select-session-interactive"] = function()
  local function _99_()
    local function _100_(sessions)
      if (1 == core.count(sessions)) then
        return log.append({"; No other sessions"}, {["break?"] = true})
      else
        local function _101_(_241)
          return (_241.name .. " (" .. _241["pretty-type"] .. ", " .. _241.id .. ")")
        end
        local function _102_(session)
          return server["assume-session"](session)
        end
        return vim.ui.select(sessions, {prompt = "Select an nREPL session:", format_item = _101_}, _102_)
      end
    end
    return server["with-sessions"](_100_)
  end
  return try_ensure_conn(_99_)
end
M["test-runners"] = {clojure = {namespace = "clojure.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]"}, clojurescript = {namespace = "cljs.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]"}, kaocha = {namespace = "kaocha.repl", ["all-fn"] = "run-all", ["ns-fn"] = "run", ["single-fn"] = "run", ["default-call-suffix"] = "{:kaocha/color? false}", ["name-prefix"] = "#'", ["name-suffix"] = ""}}
local function test_cfg(k)
  local runner = cfg({"test", "runner"})
  return (core["get-in"](M["test-runners"], {runner, k}) or error(str.join({"No test-runners configuration for ", runner, " / ", k})))
end
local function require_test_runner()
  return require_ns(test_cfg("namespace"))
end
local function test_runner_code(fn_config_name, ...)
  return ("(" .. str.join(" ", {(test_cfg("namespace") .. "/" .. test_cfg((fn_config_name .. "-fn"))), ...}) .. (cfg({"test", "call_suffix"}) or test_cfg("default-call-suffix")) .. ")")
end
M["run-all-tests"] = function()
  local function _104_()
    log.append({"; run-all-tests"}, {["break?"] = true})
    require_test_runner()
    local function _105_(_241)
      return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
    end
    return server.eval({code = test_runner_code("all")}, _105_)
  end
  return try_ensure_conn(_104_)
end
local function run_ns_tests(ns)
  local function _106_()
    if ns then
      log.append({("; run-ns-tests: " .. ns)}, {["break?"] = true})
      require_test_runner()
      local function _107_(_241)
        return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
      end
      return server.eval({code = test_runner_code("ns", ("'" .. ns))}, _107_)
    else
      return nil
    end
  end
  return try_ensure_conn(_106_)
end
M["run-current-ns-tests"] = function()
  return run_ns_tests(extract.context())
end
M["run-alternate-ns-tests"] = function()
  local current_ns = extract.context()
  local function _109_()
    if text["ends-with"](current_ns, "-test") then
      return current_ns
    else
      return (current_ns .. "-test")
    end
  end
  return run_ns_tests(_109_())
end
M["extract-test-name-from-form"] = function(form)
  local seen_deftest_3f = false
  local function _110_(part)
    local function _111_(config_current_form_name)
      return text["ends-with"](part, config_current_form_name)
    end
    if core.some(_111_, cfg({"test", "current_form_names"})) then
      seen_deftest_3f = true
      return false
    elseif seen_deftest_3f then
      return part
    else
      return nil
    end
  end
  return core.some(_110_, str.split(parse["strip-meta"](form), "%s+"))
end
M["run-current-test"] = function()
  local function _113_()
    local form = extract.form({["root?"] = true})
    if form then
      local test_name = M["extract-test-name-from-form"](form.content)
      if test_name then
        log.append({("; run-current-test: " .. test_name)}, {["break?"] = true})
        require_test_runner()
        local function _114_(msgs)
          if ((2 == core.count(msgs)) and ("nil" == core.get(core.first(msgs), "value"))) then
            return log.append({"; Success!"})
          else
            local function _115_(_241)
              return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
            end
            return core["run!"](_115_, msgs)
          end
        end
        return server.eval({code = test_runner_code("single", (test_cfg("name-prefix") .. test_name .. test_cfg("name-suffix"))), context = extract.context()}, nrepl["with-all-msgs-fn"](_114_))
      else
        return nil
      end
    else
      return nil
    end
  end
  return try_ensure_conn(_113_)
end
local function refresh_impl(op)
  local function _119_(conn)
    local function _120_(msg)
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
    return server.send(core.merge({op = op, session = conn.session, after = cfg({"refresh", "after"}), before = cfg({"refresh", "before"}), dirs = cfg({"refresh", "dirs"})}), _120_)
  end
  return server["with-conn-and-ops-or-warn"]({op}, _119_)
end
local function use_clj_reload_backend_3f()
  return (cfg({"refresh", "backend"}) == "clj-reload")
end
M["refresh-changed"] = function()
  local use_clj_reload_3f = use_clj_reload_backend_3f()
  local function _122_()
    local _123_
    if use_clj_reload_3f then
      _123_ = "clj-reload"
    else
      _123_ = "tools.namespace"
    end
    log.append({str.join({"; Refreshing changed namespaces using '", _123_, "'"})}, {["break?"] = true})
    local function _125_()
      if use_clj_reload_3f then
        return "cider.clj-reload/reload"
      else
        return "refresh"
      end
    end
    return refresh_impl(_125_())
  end
  return try_ensure_conn(_122_)
end
M["refresh-all"] = function()
  local use_clj_reload_3f = use_clj_reload_backend_3f()
  local function _126_()
    local _127_
    if use_clj_reload_3f then
      _127_ = "clj-reload"
    else
      _127_ = "tools.namespace"
    end
    log.append({str.join({"; Refreshing all namespaces using '", _127_, "'"})}, {["break?"] = true})
    local function _129_()
      if use_clj_reload_3f then
        return "cider.clj-reload/reload-all"
      else
        return "refresh-all"
      end
    end
    return refresh_impl(_129_())
  end
  return try_ensure_conn(_126_)
end
M["refresh-clear"] = function()
  local use_clj_reload_3f = use_clj_reload_backend_3f()
  local function _130_()
    local _131_
    if use_clj_reload_3f then
      _131_ = "clj-reload"
    else
      _131_ = "tools.namespace"
    end
    log.append({str.join({"; Clearning reload cache using '", _131_, "'"})}, {["break?"] = true})
    local function _133_(conn)
      local _134_
      if use_clj_reload_3f then
        _134_ = "cider.clj-reload/reload-clear"
      else
        _134_ = "refresh-clear"
      end
      local function _136_(msgs)
        return log.append({"; Clearing complete"})
      end
      return server.send({op = _134_, session = conn.session}, nrepl["with-all-msgs-fn"](_136_))
    end
    return server["with-conn-and-ops-or-warn"]({"refresh-clear"}, _133_)
  end
  return try_ensure_conn(_130_)
end
M["shadow-select"] = function(build)
  local function _137_()
    local function _138_(conn)
      log.append({("; shadow-cljs (select): " .. build)}, {["break?"] = true})
      server.eval({code = ("#?(:clj (shadow.cljs.devtools.api/nrepl-select :" .. build .. ") :cljs :already-selected)")}, ui["display-result"])
      return M["passive-ns-require"]()
    end
    return server["with-conn-or-warn"](_138_)
  end
  return try_ensure_conn(_137_)
end
M.piggieback = function(code)
  local function _139_()
    local function _140_(conn)
      log.append({("; piggieback: " .. code)}, {["break?"] = true})
      require_ns("cider.piggieback")
      server.eval({code = ("(cider.piggieback/cljs-repl " .. code .. ")")}, ui["display-result"])
      return M["passive-ns-require"]()
    end
    return server["with-conn-or-warn"](_140_)
  end
  return try_ensure_conn(_139_)
end
local function clojure__3evim_completion(_141_)
  local word = _141_.candidate
  local kind = _141_.type
  local ns = _141_.ns
  local info = _141_.doc
  local arglists = _141_.arglists
  local function _142_()
    if arglists then
      return str.join(" ", arglists)
    else
      return nil
    end
  end
  local _143_
  if ("string" == type(info)) then
    _143_ = info
  else
    _143_ = nil
  end
  local _145_
  if not core["empty?"](kind) then
    _145_ = string.upper(string.sub(kind, 1, 1))
  else
    _145_ = nil
  end
  return {word = word, menu = str.join(" ", {ns, _142_()}), info = _143_, kind = _145_}
end
local function extract_completion_context(prefix)
  local root_form = extract.form({["root?"] = true})
  if root_form then
    local content = root_form.content
    local range = root_form.range
    local lines = text["split-lines"](content)
    local _let_147_ = vim.api.nvim_win_get_cursor(0)
    local row = _let_147_[1]
    local col = _let_147_[2]
    local lrow = (row - core["get-in"](range, {"start", 1}))
    local line_index = core.inc(lrow)
    local lcol
    if (lrow == 0) then
      lcol = (col - core["get-in"](range, {"start", 2}))
    else
      lcol = col
    end
    local original = core.get(lines, line_index)
    local spliced = (string.sub(original, 1, lcol) .. "__prefix__" .. string.sub(original, core.inc(lcol)))
    return str.join("\n", core.assoc(lines, line_index, spliced))
  else
    return nil
  end
end
local function enhanced_cljs_completion_3f()
  return cfg({"completion", "cljs", "use_suitable"})
end
M.completions = function(opts)
  local function _150_(conn, ops)
    local _151_
    if ops.complete then
      local _152_
      if cfg({"completion", "with_context"}) then
        _152_ = extract_completion_context(opts.prefix)
      else
        _152_ = nil
      end
      local _154_
      if enhanced_cljs_completion_3f() then
        _154_ = "t"
      else
        _154_ = nil
      end
      _151_ = {op = "complete", session = conn.session, ns = opts.context, symbol = opts.prefix, context = _152_, ["extra-metadata"] = {"arglists", "doc"}, ["enhanced-cljs-completion?"] = _154_}
    elseif ops.completions then
      _151_ = {op = "completions", session = conn.session, ns = opts.context, prefix = opts.prefix}
    else
      _151_ = nil
    end
    local function _157_(msgs)
      return opts.cb(core.map(clojure__3evim_completion, core.get(core.last(msgs), "completions")))
    end
    return server.send(_151_, nrepl["with-all-msgs-fn"](_157_))
  end
  return server["with-conn-and-ops-or-warn"]({"complete", "completions"}, _150_, {["silent?"] = true, ["else"] = opts.cb})
end
M["out-subscribe"] = function()
  try_ensure_conn()
  log.append({"; Subscribing to out"}, {["break?"] = true})
  local function _158_(conn)
    return server.send({op = "out-subscribe"})
  end
  return server["with-conn-and-ops-or-warn"]({"out-subscribe"}, _158_)
end
M["out-unsubscribe"] = function()
  try_ensure_conn()
  log.append({"; Unsubscribing from out"}, {["break?"] = true})
  local function _159_(conn)
    return server.send({op = "out-unsubscribe"})
  end
  return server["with-conn-and-ops-or-warn"]({"out-unsubscribe"}, _159_)
end
return M
