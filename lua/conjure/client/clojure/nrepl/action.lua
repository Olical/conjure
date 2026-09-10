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
      local function _19_(_conn)
        return cb()
      end
      return server["with-conn-ready-or-queue"](_19_)
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
  local function _25_(resp)
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
  return _25_
end
M["eval-str"] = function(opts)
  local function _29_()
    local function _30_(conn)
      local send_eval_21
      local function _31_()
        return server.eval(opts, eval_cb_fn(opts))
      end
      send_eval_21 = _31_
      if (opts.context and not core["get-in"](conn, {"seen-ns", opts.context})) then
        local function _32_(_msgs)
          return send_eval_21()
        end
        server.eval({code = ("(ns " .. opts.context .. ")"), session = core.get(opts, "session")}, nrepl["with-all-msgs-fn"](_32_))
        return core["assoc-in"](conn, {"seen-ns", opts.context}, true)
      else
        return send_eval_21()
      end
    end
    return server["with-conn-or-warn"](_30_)
  end
  return try_ensure_conn(_29_)
end
local function with_info(opts, f)
  local function _34_(conn, ops)
    local _35_
    if ops.info then
      _35_ = {op = "info", ns = (opts.context or "user"), symbol = opts.code, session = conn.session, ["download-sources-jar"] = 1}
    elseif ops.lookup then
      _35_ = {op = "lookup", ns = (opts.context or "user"), sym = opts.code, session = conn.session}
    else
      _35_ = nil
    end
    local function _37_(msg)
      local function _38_()
        if not msg.status["no-info"] then
          return (msg.info or msg)
        else
          return nil
        end
      end
      return f(_38_())
    end
    return server.send(_35_, _37_)
  end
  return server["with-conn-and-ops-or-warn"]({"info", "lookup"}, _34_)
end
local function java_info__3elines(_39_)
  local arglists_str = _39_["arglists-str"]
  local class = _39_.class
  local member = _39_.member
  local javadoc = _39_.javadoc
  local function _40_()
    if member then
      return {"/", member}
    else
      return nil
    end
  end
  local _41_
  if not core["empty?"](arglists_str) then
    _41_ = {("; (" .. str.join(" ", text["split-lines"](arglists_str)) .. ")")}
  else
    _41_ = nil
  end
  local function _43_()
    if javadoc then
      return {("; " .. javadoc)}
    else
      return nil
    end
  end
  return core.concat({str.join(core.concat({"; ", class}, _40_()))}, _41_, _43_())
end
M["doc-str"] = function(opts)
  local function _44_()
    require_ns("clojure.repl")
    local function _45_(msgs)
      local function _46_(msg)
        return (core.get(msg, "out") or core.get(msg, "err"))
      end
      if core.some(_46_, msgs) then
        local function _47_(_241)
          return ui["display-result"](_241, {["simple-out?"] = true, ["ignore-nil?"] = true})
        end
        core["run!"](_47_, msgs)
        if opts["on-result"] then
          local function _48_(_241)
            return (core.get(_241, "out") or core.get(_241, "err") or "")
          end
          return opts["on-result"](str.join("\n", core.map(_48_, msgs)))
        else
          return nil
        end
      else
        log.append({"; No results for (doc ...), checking nREPL info ops"})
        local function _50_(info)
          local lines
          if core["nil?"](info) then
            lines = {"; No information found, all I can do is wish you good luck and point you to https://duckduckgo.com/"}
          elseif ("string" == type(info.javadoc)) then
            lines = java_info__3elines(info)
          elseif ("string" == type(info.doc)) then
            lines = core.concat({str.join({"; ", info.ns, "/", info.name}), str.join({"; ", info["arglists-str"]})}, text["prefixed-lines"](info.doc, "; "))
          else
            lines = core.concat({"; Unknown result, it may still be helpful"}, text["prefixed-lines"](core["pr-str"](info), "; "))
          end
          log.append(lines)
          if opts["on-result"] then
            return opts["on-result"](str.join("\n", lines))
          else
            return nil
          end
        end
        return with_info(opts, _50_)
      end
    end
    return server.eval(core.merge({}, opts, {code = ("(clojure.repl/doc " .. opts.code .. ")")}), nrepl["with-all-msgs-fn"](_45_))
  end
  return try_ensure_conn(_44_)
end
local function nrepl__3envim_path(path)
  if text["starts-with"](path, "jar:file:") then
    local function _54_(zip, file)
      if (tonumber(string.sub(vim.g.loaded_zipPlugin, 2)) > 31) then
        return ("zipfile://" .. zip .. "::" .. file)
      else
        return ("zipfile:" .. zip .. "::" .. file)
      end
    end
    return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _54_)
  elseif text["starts-with"](path, "file:") then
    local function _56_(file)
      return file
    end
    return string.gsub(path, "^file:(.+)$", _56_)
  else
    return path
  end
end
M["def-str"] = function(opts)
  local function _58_()
    local function _59_(info)
      if core["nil?"](info) then
        return log.append({"; No definition information found"})
      elseif info.candidates then
        local function _60_(_241)
          return (_241 .. "/" .. opts.code)
        end
        return log.append(core.concat({"; Multiple candidates found"}, core.map(_60_, core.keys(info.candidates))))
      elseif (info.file and info.line) then
        local column = (info.column or 1)
        local path = nrepl__3envim_path(info.file)
        editor["go-to"](path, info.line, column)
        return log.append({("; " .. path .. " [" .. info.line .. " " .. column .. "]")}, {["suppress-hud?"] = true})
      elseif info.javadoc then
        return log.append({"; Can't open source, it's Java", ("; " .. info.javadoc)})
      elseif info["special-form"] then
        local function _61_()
          if info.url then
            return ("; " .. info.url)
          else
            return nil
          end
        end
        return log.append({"; Can't open source, it's a special form", _61_()})
      else
        return log.append({"; Unsupported target", ("; " .. core["pr-str"](info))})
      end
    end
    return with_info(opts, _59_)
  end
  return try_ensure_conn(_58_)
end
M["escape-backslashes"] = function(s)
  return s:gsub("\\", "\\\\")
end
M["eval-file"] = function(opts)
  local function _63_()
    local function _64_(conn)
      return server["load-file"](core.assoc(opts, "code", core.slurp(opts["file-path"])), eval_cb_fn(opts))
    end
    return server["with-conn-or-warn"](_64_)
  end
  return try_ensure_conn(_63_)
end
M.interrupt = function()
  local function _65_()
    local function _66_(conn)
      local msgs
      local function _67_(msg)
        return ("eval" == msg.msg.op)
      end
      msgs = core.filter(_67_, core.vals(conn.msgs))
      local order_66
      local function _69_(_68_)
        local id = _68_.id
        local session = _68_.session
        local code = _68_.code
        server.send({op = "interrupt", ["interrupt-id"] = id, session = session})
        local function _70_(sess)
          local _71_
          if code then
            _71_ = text["left-sample"](code, editor["percent-width"](cfg({"interrupt", "sample_limit"})))
          else
            _71_ = ("session: " .. sess.str() .. "")
          end
          return log.append({("; Interrupted: " .. _71_)}, {["break?"] = true})
        end
        return server["enrich-session-id"](session, _70_, server["session-type-timeout"])
      end
      order_66 = _69_
      if core["empty?"](msgs) then
        return order_66({session = conn.session})
      else
        local function _73_(a, b)
          return (a["sent-at"] < b["sent-at"])
        end
        table.sort(msgs, _73_)
        return order_66(core.get(core.first(msgs), "msg"))
      end
    end
    return server["with-conn-or-warn"](_66_)
  end
  return try_ensure_conn(_65_)
end
local function eval_str_fn(code)
  local function _75_()
    return vim.api.nvim_exec2(("ConjureEval " .. code), {})
  end
  return _75_
end
M["last-exception"] = eval_str_fn("*e")
M["result-1"] = eval_str_fn("*1")
M["result-2"] = eval_str_fn("*2")
M["result-3"] = eval_str_fn("*3")
M["view-tap"] = eval_str_fn("(conjure.internal/dump-tap-queue!)")
M["view-source"] = function()
  local function _76_()
    local word = core.get(extract.word(), "content")
    if not core["empty?"](word) then
      log.append({("; source (word): " .. word)}, {["break?"] = true})
      require_ns("clojure.repl")
      local function _77_(_241)
        return ui["display-result"](_241, {["raw-out?"] = true, ["ignore-nil?"] = true})
      end
      return M["eval-str"]({code = ("(clojure.repl/source " .. word .. ")"), context = extract.context(), cb = _77_})
    else
      return nil
    end
  end
  return try_ensure_conn(_76_)
end
local function eval_macro_expand(expander)
  local function _79_()
    local form = core.get(extract.form({}), "content")
    if not core["empty?"](form) then
      log.append({("; " .. expander .. " (form): " .. form)}, {["break?"] = true})
      local _80_
      if ("clojure.walk/macroexpand-all" == expander) then
        _80_ = "(require 'clojure.walk) "
      else
        _80_ = ""
      end
      local function _82_(_241)
        return ui["display-result"](_241, {["raw-out?"] = true, ["ignore-nil?"] = true})
      end
      return M["eval-str"]({code = (_80_ .. "(" .. expander .. " '" .. form .. ")"), context = extract.context(), cb = _82_})
    else
      return nil
    end
  end
  return try_ensure_conn(_79_)
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
  local function _84_()
    local function _85_(conn)
      return server["enrich-session-id"](core.get(conn, "session"), server["clone-session"], server["session-type-timeout"])
    end
    return server["with-conn-or-warn"](_85_)
  end
  return try_ensure_conn(_84_)
end
M["clone-fresh-session"] = function()
  local function _86_()
    local function _87_(conn)
      return server["clone-session"](nil, nil, server["session-type-timeout"])
    end
    return server["with-conn-or-warn"](_87_)
  end
  return try_ensure_conn(_86_)
end
M["close-current-session"] = function()
  local function _88_()
    local function _89_(conn)
      local function _90_(sess)
        core.assoc(conn, "session", nil)
        log.append({("; Closed current session: " .. sess.str())}, {["break?"] = true})
        local function _91_()
          return server["assume-or-create-session"](nil, {timeout = server["session-type-timeout"]})
        end
        return server["close-session"](sess, _91_)
      end
      return server["enrich-session-id"](core.get(conn, "session"), _90_, server["session-type-timeout"])
    end
    return server["with-conn-or-warn"](_89_)
  end
  return try_ensure_conn(_88_)
end
M["display-sessions"] = function(cb)
  local function _92_()
    local function _93_(sessions)
      return ui["display-sessions"](sessions, cb)
    end
    return server["with-sessions"](_93_, {timeout = server["session-type-timeout"]})
  end
  return try_ensure_conn(_92_)
end
M["close-all-sessions"] = function()
  local function _94_()
    local function _95_(sessions)
      core["run!"](server["close-session"], sessions)
      log.append({("; Closed all sessions (" .. core.count(sessions) .. ")")}, {["break?"] = true})
      return server["clone-session"](nil, nil, server["session-type-timeout"])
    end
    return server["with-sessions"](_95_, {timeout = server["session-type-timeout"]})
  end
  return try_ensure_conn(_94_)
end
local function cycle_session(f)
  local function _96_()
    local function _97_(conn)
      local function _98_(sessions)
        if (1 == core.count(sessions)) then
          return log.append({"; No other sessions"}, {["break?"] = true})
        else
          local session = core.get(conn, "session")
          local function _99_(_241)
            return f(session, _241)
          end
          return server["assume-session"](ll.val(ll["until"](_99_, ll.cycle(ll.create(sessions)))))
        end
      end
      return server["with-sessions"](_98_, {timeout = server["session-type-timeout"]})
    end
    return server["with-conn-or-warn"](_97_)
  end
  return try_ensure_conn(_96_)
end
M["next-session"] = function()
  local function _101_(current, node)
    return (current == core.get(ll.val(ll.prev(node)), "id"))
  end
  return cycle_session(_101_)
end
M["prev-session"] = function()
  local function _102_(current, node)
    return (current == core.get(ll.val(ll.next(node)), "id"))
  end
  return cycle_session(_102_)
end
M["select-session-interactive"] = function()
  local function _103_()
    local function _104_(sessions)
      if (1 == core.count(sessions)) then
        return log.append({"; No other sessions"}, {["break?"] = true})
      else
        local function _105_(_241)
          return (_241.name .. " (" .. _241["pretty-type"] .. ", " .. _241.id .. ")")
        end
        local function _106_(session)
          return server["assume-session"](session)
        end
        return vim.ui.select(sessions, {prompt = "Select an nREPL session:", format_item = _105_}, _106_)
      end
    end
    return server["with-sessions"](_104_, {timeout = server["session-type-timeout"]})
  end
  return try_ensure_conn(_103_)
end
M["test-runners"] = {clojure = {namespace = "clojure.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]", ["current-form-names"] = {"deftest"}}, clojurescript = {namespace = "cljs.test", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "test-vars", ["default-call-suffix"] = "", ["name-prefix"] = "[(resolve '", ["name-suffix"] = ")]", ["current-form-names"] = {"deftest"}}, kaocha = {namespace = "kaocha.repl", ["all-fn"] = "run-all", ["ns-fn"] = "run", ["single-fn"] = "run", ["default-call-suffix"] = "{:kaocha/color? false}", ["name-prefix"] = "#'", ["name-suffix"] = "", ["current-form-names"] = {"deftest"}}, lazytest = {namespace = "lazytest.repl", ["all-fn"] = "run-all-tests", ["ns-fn"] = "run-tests", ["single-fn"] = "run-test-var", ["default-call-suffix"] = "", ["name-prefix"] = "#'", ["name-suffix"] = "", ["current-form-names"] = {"defdescribe"}}}
local function test_cfg(k, opt)
  local runner = cfg({"test", "runner"})
  local or_108_ = core["get-in"](M["test-runners"], {runner, k})
  if not or_108_ then
    if (true == core.get(opt, "ignore-errors")) then
      or_108_ = nil
    else
      or_108_ = error(str.join({"No test-runners configuration for ", runner, " / ", k}))
    end
  end
  return or_108_
end
local function require_test_runner()
  return require_ns(test_cfg("namespace"))
end
local function test_runner_code(fn_config_name, ...)
  return ("(" .. str.join(" ", {(test_cfg("namespace") .. "/" .. test_cfg((fn_config_name .. "-fn"))), ...}) .. (cfg({"test", "call_suffix"}) or test_cfg("default-call-suffix")) .. ")")
end
M["run-all-tests"] = function()
  local function _110_()
    log.append({"; run-all-tests"}, {["break?"] = true})
    require_test_runner()
    local function _111_(_241)
      return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
    end
    return server.eval({code = test_runner_code("all")}, _111_)
  end
  return try_ensure_conn(_110_)
end
local function run_ns_tests(ns)
  local function _112_()
    if ns then
      log.append({("; run-ns-tests: " .. ns)}, {["break?"] = true})
      require_test_runner()
      local function _113_(_241)
        return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
      end
      return server.eval({code = test_runner_code("ns", ("'" .. ns))}, _113_)
    else
      return nil
    end
  end
  return try_ensure_conn(_112_)
end
M["run-current-ns-tests"] = function()
  return run_ns_tests(extract.context())
end
M["run-alternate-ns-tests"] = function()
  local current_ns = extract.context()
  local function _115_()
    if text["ends-with"](current_ns, "-test") then
      return current_ns
    else
      return (current_ns .. "-test")
    end
  end
  return run_ns_tests(_115_())
end
M["extract-test-name-from-form"] = function(form)
  local current_form_names = (test_cfg("current-form-names", {["ignore-errors"] = true}) or cfg({"test", "current_form_names"}))
  if (nil == current_form_names) then
    return error(str.join({"No value for current-form-names in test or runner configuration"}))
  else
    local seen_deftest_3f = false
    local function _116_(part)
      local function _117_(config_current_form_name)
        return text["ends-with"](part, config_current_form_name)
      end
      if core.some(_117_, current_form_names) then
        seen_deftest_3f = true
        return false
      elseif seen_deftest_3f then
        return part
      else
        return nil
      end
    end
    return core.some(_116_, str.split(parse["strip-meta"](form), "%s+"))
  end
end
M["run-current-test"] = function()
  local function _120_()
    local form = extract.form({["root?"] = true})
    if form then
      local test_name = M["extract-test-name-from-form"](form.content)
      if test_name then
        log.append({("; run-current-test: " .. test_name)}, {["break?"] = true})
        require_test_runner()
        local function _121_(msgs)
          if ((2 == core.count(msgs)) and ("nil" == core.get(core.first(msgs), "value"))) then
            return log.append({"; Success!"})
          else
            local function _122_(_241)
              return ui["display-result"](_241, {["simple-out?"] = true, ["raw-out?"] = cfg({"test", "raw_out"}), ["ignore-nil?"] = true})
            end
            return core["run!"](_122_, msgs)
          end
        end
        return server.eval({code = test_runner_code("single", (test_cfg("name-prefix") .. test_name .. test_cfg("name-suffix"))), context = extract.context()}, nrepl["with-all-msgs-fn"](_121_))
      else
        return nil
      end
    else
      return nil
    end
  end
  return try_ensure_conn(_120_)
end
M["select-test-runner"] = function()
  local test_runner_config_key = "conjure#client#clojure#nrepl#test#runner"
  local active_test_runner = core.get(vim.g, test_runner_config_key)
  local opts = {prompt = "Select a test-runner:"}
  local test_runner_names = core.keys(M["test-runners"])
  local choices
  local function _126_(tr)
    if (tr == active_test_runner) then
      return str.join({tr, " (*)"})
    else
      return tr
    end
  end
  choices = core.map(_126_, core.vals(test_runner_names))
  table.sort(choices)
  local function _128_(choice, _idx)
    if choice then
      vim.g[test_runner_config_key] = choice
      return nil
    else
      return nil
    end
  end
  return vim.ui.select(choices, opts, _128_)
end
local function refresh_impl(op)
  local function _130_(conn)
    local function _131_(msg)
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
    return server.send(core.merge({op = op, session = conn.session, after = cfg({"refresh", "after"}), before = cfg({"refresh", "before"}), dirs = cfg({"refresh", "dirs"})}), _131_)
  end
  return server["with-conn-and-ops-or-warn"]({op}, _130_)
end
local function use_clj_reload_backend_3f()
  return (cfg({"refresh", "backend"}) == "clj-reload")
end
M["refresh-changed"] = function()
  local use_clj_reload_3f = use_clj_reload_backend_3f()
  local function _133_()
    local _134_
    if use_clj_reload_3f then
      _134_ = "clj-reload"
    else
      _134_ = "tools.namespace"
    end
    log.append({str.join({"; Refreshing changed namespaces using '", _134_, "'"})}, {["break?"] = true})
    local function _136_()
      if use_clj_reload_3f then
        return "cider.clj-reload/reload"
      else
        return "refresh"
      end
    end
    return refresh_impl(_136_())
  end
  return try_ensure_conn(_133_)
end
M["refresh-all"] = function()
  local use_clj_reload_3f = use_clj_reload_backend_3f()
  local function _137_()
    local _138_
    if use_clj_reload_3f then
      _138_ = "clj-reload"
    else
      _138_ = "tools.namespace"
    end
    log.append({str.join({"; Refreshing all namespaces using '", _138_, "'"})}, {["break?"] = true})
    local function _140_()
      if use_clj_reload_3f then
        return "cider.clj-reload/reload-all"
      else
        return "refresh-all"
      end
    end
    return refresh_impl(_140_())
  end
  return try_ensure_conn(_137_)
end
M["refresh-clear"] = function()
  local use_clj_reload_3f = use_clj_reload_backend_3f()
  local function _141_()
    local _142_
    if use_clj_reload_3f then
      _142_ = "clj-reload"
    else
      _142_ = "tools.namespace"
    end
    log.append({str.join({"; Clearning reload cache using '", _142_, "'"})}, {["break?"] = true})
    local function _144_(conn)
      local _145_
      if use_clj_reload_3f then
        _145_ = "cider.clj-reload/reload-clear"
      else
        _145_ = "refresh-clear"
      end
      local function _147_(msgs)
        return log.append({"; Clearing complete"})
      end
      return server.send({op = _145_, session = conn.session}, nrepl["with-all-msgs-fn"](_147_))
    end
    return server["with-conn-and-ops-or-warn"]({"refresh-clear"}, _144_)
  end
  return try_ensure_conn(_141_)
end
M["shadow-select"] = function(build)
  local function _148_()
    local function _149_(conn)
      log.append({("; shadow-cljs (select): " .. build)}, {["break?"] = true})
      server.eval({code = ("#?(:clj (shadow.cljs.devtools.api/nrepl-select :" .. build .. ") :cljs :already-selected)")}, ui["display-result"])
      return M["passive-ns-require"]()
    end
    return server["with-conn-or-warn"](_149_)
  end
  return try_ensure_conn(_148_)
end
M.piggieback = function(code)
  local function _150_()
    local function _151_(conn)
      log.append({("; piggieback: " .. code)}, {["break?"] = true})
      require_ns("cider.piggieback")
      server.eval({code = ("(cider.piggieback/cljs-repl " .. code .. ")")}, ui["display-result"])
      return M["passive-ns-require"]()
    end
    return server["with-conn-or-warn"](_151_)
  end
  return try_ensure_conn(_150_)
end
local function clojure__3evim_completion(_152_)
  local word = _152_.candidate
  local kind = _152_.type
  local ns = _152_.ns
  local info = _152_.doc
  local arglists = _152_.arglists
  local function _153_()
    if arglists then
      return str.join(" ", arglists)
    else
      return nil
    end
  end
  local _154_
  if ("string" == type(info)) then
    _154_ = info
  else
    _154_ = nil
  end
  local _156_
  if not core["empty?"](kind) then
    _156_ = string.upper(string.sub(kind, 1, 1))
  else
    _156_ = nil
  end
  return {word = word, menu = str.join(" ", {ns, _153_()}), info = _154_, kind = _156_}
end
local function extract_completion_context(prefix)
  local root_form = extract.form({["root?"] = true})
  if root_form then
    local content = root_form.content
    local range = root_form.range
    local lines = text["split-lines"](content)
    local _let_158_ = vim.api.nvim_win_get_cursor(0)
    local row = _let_158_[1]
    local col = _let_158_[2]
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
  local function _161_(conn, ops)
    local _162_
    if ops.complete then
      local _163_
      if cfg({"completion", "with_context"}) then
        _163_ = extract_completion_context(opts.prefix)
      else
        _163_ = nil
      end
      local _165_
      if enhanced_cljs_completion_3f() then
        _165_ = "t"
      else
        _165_ = nil
      end
      _162_ = {op = "complete", session = conn.session, ns = opts.context, symbol = opts.prefix, context = _163_, ["extra-metadata"] = {"arglists", "doc"}, ["enhanced-cljs-completion?"] = _165_}
    elseif ops.completions then
      _162_ = {op = "completions", session = conn.session, ns = opts.context, prefix = opts.prefix}
    else
      _162_ = nil
    end
    local function _168_(msgs)
      return opts.cb(core.map(clojure__3evim_completion, core.get(core.last(msgs), "completions")))
    end
    return server.send(_162_, nrepl["with-all-msgs-fn"](_168_))
  end
  return server["with-conn-and-ops-or-warn"]({"complete", "completions"}, _161_, {["silent?"] = true, ["else"] = opts.cb})
end
M["out-subscribe"] = function()
  local function _169_()
    log.append({"; Subscribing to out"}, {["break?"] = true})
    local function _170_(conn)
      return server.send({op = "out-subscribe"})
    end
    return server["with-conn-and-ops-or-warn"]({"out-subscribe"}, _170_)
  end
  return try_ensure_conn(_169_)
end
M["out-unsubscribe"] = function()
  local function _171_()
    log.append({"; Unsubscribing from out"}, {["break?"] = true})
    local function _172_(conn)
      return server.send({op = "out-unsubscribe"})
    end
    return server["with-conn-and-ops-or-warn"]({"out-unsubscribe"}, _172_)
  end
  return try_ensure_conn(_171_)
end
return M
