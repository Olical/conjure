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
  _0_0["aniseed/local-fns"] = {require = {a = "conjure.aniseed.core", client = "conjure.client", config = "conjure.client.clojure.nrepl.config", editor = "conjure.editor", eval = "conjure.aniseed.eval", extract = "conjure.extract", ll = "conjure.linked-list", nvim = "conjure.aniseed.nvim", server = "conjure.client.clojure.nrepl.server", state = "conjure.client.clojure.nrepl.state", str = "conjure.aniseed.string", text = "conjure.text", ui = "conjure.client.clojure.nrepl.ui"}}
  return {require("conjure.aniseed.core"), require("conjure.client"), require("conjure.client.clojure.nrepl.config"), require("conjure.editor"), require("conjure.aniseed.eval"), require("conjure.extract"), require("conjure.linked-list"), require("conjure.aniseed.nvim"), require("conjure.client.clojure.nrepl.server"), require("conjure.client.clojure.nrepl.state"), require("conjure.aniseed.string"), require("conjure.text"), require("conjure.client.clojure.nrepl.ui")}
end
local _2_ = _1_(...)
local a = _2_[1]
local client = _2_[2]
local config = _2_[3]
local editor = _2_[4]
local eval = _2_[5]
local extract = _2_[6]
local ll = _2_[7]
local nvim = _2_[8]
local server = _2_[9]
local state = _2_[10]
local str = _2_[11]
local text = _2_[12]
local ui = _2_[13]
do local _ = ({nil, _0_0, nil})[2] end
local display_session_type = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function display_session_type0()
      local function _3_(msgs)
        return ui.display({("; Session type: " .. a.get(a.first(msgs), "value"))}, {["break?"] = true})
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
local connect_port_file = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function connect_port_file0()
      local port = nil
      do
        local _3_0 = a.slurp(".nrepl-port")
        if _3_0 then
          port = tonumber(_3_0)
        else
          port = _3_0
        end
      end
      if port then
        return server.connect({host = config.connection.localhost, port = port})
      else
        return ui.display({"; No .nrepl-port file found"})
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
        _3_ = config.connection.localhost
      else
        _3_ = a.first(args)
      end
      return server.connect({host = _3_, port = tonumber(a.last(args))})
    end
    v_23_0_0 = connect_host_port0
    _0_0["connect-host-port"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connect-host-port"] = v_23_0_
  connect_host_port = v_23_0_
end
local eval_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval_str0(opts)
      local function _3_(_)
        do
          local context = a.get(opts, "context")
          local function _4_()
            if context then
              return ("(in-ns '" .. context .. ")")
            else
              return "(in-ns #?(:clj 'user, :cljs 'cljs.user))"
            end
          end
          local function _5_()
          end
          server.eval({code = ("(do " .. _4_() .. " *1)")}, _5_)
        end
        local function _4_(_241)
          return ui["display-result"](opts, _241)
        end
        return server.eval(opts, (opts.cb or _4_))
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
local doc_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function doc_str0(opts)
      local function _3_(msgs)
        local function _4_(_241)
          return a.get(_241, "out")
        end
        return ui.display(text["prefixed-lines"](str.join("\n", a.rest(a.filter(a["string?"], a.map(_4_, msgs)))), "; "))
      end
      return eval_str(a.merge(opts, {cb = server["with-all-msgs-fn"](_3_), code = ("(do (require 'clojure.repl)" .. "    (clojure.repl/doc " .. opts.code .. "))")}))
    end
    v_23_0_0 = doc_str0
    _0_0["doc-str"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["doc-str"] = v_23_0_
  doc_str = v_23_0_
end
local jar__3ezip = nil
do
  local v_23_0_ = nil
  local function jar__3ezip0(path)
    if text["starts-with"](path, "jar:file:") then
      local function _3_(zip, file)
        return ("zipfile:" .. zip .. "::" .. file)
      end
      return string.gsub(path, "^jar:file:(.+)!/?(.+)$", _3_)
    else
      return path
    end
  end
  v_23_0_ = jar__3ezip0
  _0_0["aniseed/locals"]["jar->zip"] = v_23_0_
  jar__3ezip = v_23_0_
end
local def_str = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function def_str0(opts)
      local function _3_(msgs)
        local val = a.get(a.first(msgs), "value")
        local ok_3f, res = nil, nil
        if val then
          ok_3f, res = eval.str(val)
        else
        ok_3f, res = nil
        end
        if ok_3f then
          local _5_ = res
          local path = _5_[1]
          local line = _5_[2]
          local column = _5_[3]
          return editor["go-to"](jar__3ezip(path), line, column)
        else
          return ui.display({"; Couldn't find definition."})
        end
      end
      return eval_str(a.merge(opts, {cb = server["with-all-msgs-fn"](_3_), code = ("(mapv #(% (meta #'" .. opts.code .. "))\n      [(comp #(.toString %)\n      (some-fn (comp #?(:clj clojure.java.io/resource :cljs identity)\n      :file) :file))\n      :line :column])")}))
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
      local function _3_(_241)
        return ui["display-result"](opts, _241)
      end
      return server.eval(a.assoc(opts, "code", ("(load-file \"" .. opts["file-path"] .. "\")")), _3_)
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
        if a["empty?"](msgs) then
          return ui.display({"; Nothing to interrupt"}, {["break?"] = true})
        else
          local function _5_(a0, b)
            return (a0["sent-at"] < b["sent-at"])
          end
          table.sort(msgs, _5_)
          do
            local oldest = a.first(msgs)
            server.send({id = oldest.msg.id, op = "interrupt", session = oldest.msg.session})
            return ui.display({("; Interrupted: " .. text["left-sample"](oldest.msg.code, editor["percent-width"](config.interrupt["sample-limit"])))}, {["break?"] = true})
          end
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
        local function _3_(msgs)
          local source = nil
          local function _4_(_241)
            return a.get(_241, "out")
          end
          source = str.join("\n", a.filter(a["string?"], a.map(_4_, msgs)))
          local function _5_()
            if ("Source not found\n" == source) then
              return ("; " .. source)
            else
              return source
            end
          end
          return ui.display(text["split-lines"](_5_()))
        end
        return eval_str({cb = server["with-all-msgs-fn"](_3_), code = ("(do (require 'clojure.repl)" .. "(clojure.repl/source " .. word .. "))"), context = extract.context()})
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
return nil