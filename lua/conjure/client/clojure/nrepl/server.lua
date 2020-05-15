local _0_0 = nil
do
  local name_23_0_ = "conjure.client.clojure.nrepl.server"
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
  _0_0["aniseed/local-fns"] = {require = {["bencode-stream"] = "conjure.bencode-stream", a = "conjure.aniseed.core", bencode = "conjure.bencode", config = "conjure.client.clojure.nrepl.config", extract = "conjure.extract", net = "conjure.net", state = "conjure.client.clojure.nrepl.state", text = "conjure.text", ui = "conjure.client.clojure.nrepl.ui", uuid = "conjure.uuid", view = "conjure.aniseed.view"}}
  return {require("conjure.aniseed.core"), require("conjure.bencode"), require("conjure.bencode-stream"), require("conjure.client.clojure.nrepl.config"), require("conjure.extract"), require("conjure.net"), require("conjure.client.clojure.nrepl.state"), require("conjure.text"), require("conjure.client.clojure.nrepl.ui"), require("conjure.uuid"), require("conjure.aniseed.view")}
end
local _2_ = _1_(...)
local a = _2_[1]
local uuid = _2_[10]
local view = _2_[11]
local bencode = _2_[2]
local bencode_stream = _2_[3]
local config = _2_[4]
local extract = _2_[5]
local net = _2_[6]
local state = _2_[7]
local text = _2_[8]
local ui = _2_[9]
do local _ = ({nil, _0_0, nil})[2] end
local with_conn_or_warn = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function with_conn_or_warn0(f, opts)
      local conn = a.get(state, "conn")
      if conn then
        return f(conn)
      else
        if not a.get(opts, "silent?") then
          ui.display({"; No connection"})
        end
        if a.get(opts, "else") then
          return opts["else"]()
        end
      end
    end
    v_23_0_0 = with_conn_or_warn0
    _0_0["with-conn-or-warn"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["with-conn-or-warn"] = v_23_0_
  with_conn_or_warn = v_23_0_
end
local dbg = nil
do
  local v_23_0_ = nil
  local function dbg0(desc, data)
    if config["debug?"] then
      ui.display(a.concat({("; debug: " .. desc)}, text["split-lines"](view.serialise(data))))
    end
    return data
  end
  v_23_0_ = dbg0
  _0_0["aniseed/locals"]["dbg"] = v_23_0_
  dbg = v_23_0_
end
local send = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function send0(msg, cb)
      local conn = a.get(state, "conn")
      if conn then
        local msg_id = uuid.v4()
        a.assoc(msg, "id", msg_id)
        dbg("send", msg)
        local function _3_()
        end
        a["assoc-in"](conn, {"msgs", msg_id}, {["sent-at"] = os.time(), cb = (cb or _3_), msg = msg})
        do end (conn.sock):write(bencode.encode(msg))
        return nil
      end
    end
    v_23_0_0 = send0
    _0_0["send"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["send"] = v_23_0_
  send = v_23_0_
end
local display_conn_status = nil
do
  local v_23_0_ = nil
  local function display_conn_status0(status)
    local function _3_(conn)
      return ui.display({("; " .. conn["raw-host"] .. ":" .. conn.port .. " (" .. status .. ")")}, {["break?"] = true})
    end
    return with_conn_or_warn(_3_)
  end
  v_23_0_ = display_conn_status0
  _0_0["aniseed/locals"]["display-conn-status"] = v_23_0_
  display_conn_status = v_23_0_
end
local disconnect = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function disconnect0()
      local function _3_(conn)
        if not (conn.sock):is_closing() then
          do end (conn.sock):read_stop()
          do end (conn.sock):shutdown()
          do end (conn.sock):close()
        end
        display_conn_status("disconnected")
        return a.assoc(state, "conn", nil)
      end
      return with_conn_or_warn(_3_)
    end
    v_23_0_0 = disconnect0
    _0_0["disconnect"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["disconnect"] = v_23_0_
  disconnect = v_23_0_
end
local with_all_msgs_fn = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function with_all_msgs_fn0(cb)
      local acc = {}
      local function _3_(msg)
        table.insert(acc, msg)
        if msg.status.done then
          return cb(acc)
        end
      end
      return _3_
    end
    v_23_0_0 = with_all_msgs_fn0
    _0_0["with-all-msgs-fn"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["with-all-msgs-fn"] = v_23_0_
  with_all_msgs_fn = v_23_0_
end
local close_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function close_session0(session, cb)
      return send({op = "close", session = session}, cb)
    end
    v_23_0_0 = close_session0
    _0_0["close-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["close-session"] = v_23_0_
  close_session = v_23_0_
end
local assume_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function assume_session0(session)
      a["assoc-in"](state, {"conn", "session"}, session)
      return ui.display({("; Assumed session: " .. session)}, {["break?"] = true})
    end
    v_23_0_0 = assume_session0
    _0_0["assume-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["assume-session"] = v_23_0_
  assume_session = v_23_0_
end
local clone_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function clone_session0(session)
      local function _3_(msgs)
        return assume_session(a.get(a.last(msgs), "new-session"))
      end
      return send({op = "clone", session = session}, with_all_msgs_fn(_3_))
    end
    v_23_0_0 = clone_session0
    _0_0["clone-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["clone-session"] = v_23_0_
  clone_session = v_23_0_
end
local with_sessions = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function with_sessions0(cb)
      local function _3_(_)
        local function _4_(msg)
          local sessions = nil
          local function _5_(session)
            return (msg.session ~= session)
          end
          sessions = a.filter(_5_, a.get(msg, "sessions"))
          table.sort(sessions)
          return cb(sessions)
        end
        return send({op = "ls-sessions"}, _4_)
      end
      return with_conn_or_warn(_3_)
    end
    v_23_0_0 = with_sessions0
    _0_0["with-sessions"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["with-sessions"] = v_23_0_
  with_sessions = v_23_0_
end
local assume_or_create_session = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function assume_or_create_session0()
      local function _3_(sessions)
        if a["empty?"](sessions) then
          return clone_session()
        else
          return assume_session(a.first(sessions))
        end
      end
      return with_sessions(_3_)
    end
    v_23_0_0 = assume_or_create_session0
    _0_0["assume-or-create-session"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["assume-or-create-session"] = v_23_0_
  assume_or_create_session = v_23_0_
end
local enrich_status = nil
do
  local v_23_0_ = nil
  local function enrich_status0(msg)
    local ks = a.get(msg, "status")
    local status = {}
    local function _3_(k)
      return a.assoc(status, k, true)
    end
    a["run!"](_3_, ks)
    a.assoc(msg, "status", status)
    return msg
  end
  v_23_0_ = enrich_status0
  _0_0["aniseed/locals"]["enrich-status"] = v_23_0_
  enrich_status = v_23_0_
end
local process_message = nil
do
  local v_23_0_ = nil
  local function process_message0(err, chunk)
    local conn = a.get(state, "conn")
    if err then
      return display_conn_status(err)
    elseif not chunk then
      return disconnect()
    else
      local function _3_(msg)
        dbg("receive", msg)
        enrich_status(msg)
        if msg.status["need-input"] then
          local function _4_()
            return send({op = "stdin", session = conn.session, stdin = ((extract.prompt("Input required: ") or "") .. "\n")})
          end
          vim.schedule(_4_)
        end
        local cb = nil
        local function _5_(_241)
          return ui["display-result"](_241)
        end
        cb = a["get-in"](conn, {"msgs", msg.id, "cb"}, _5_)
        local ok_3f, err0 = pcall(cb, msg)
        if not ok_3f then
          ui.display({("; conjure.client.clojure.nrepl error: " .. err0)})
        end
        if msg.status["unknown-session"] then
          ui.display({"; Unknown session, correcting"})
          assume_or_create_session()
        end
        if msg.status.done then
          return a["assoc-in"](conn, {"msgs", msg.id}, nil)
        end
      end
      return a["run!"](_3_, bencode_stream["decode-all"](state.bs, chunk))
    end
  end
  v_23_0_ = process_message0
  _0_0["aniseed/locals"]["process-message"] = v_23_0_
  process_message = v_23_0_
end
local awaiting_process_3f = nil
do
  local v_23_0_ = (_0_0["aniseed/locals"]["awaiting-process?"] or false)
  _0_0["aniseed/locals"]["awaiting-process?"] = v_23_0_
  awaiting_process_3f = v_23_0_
end
local process_message_queue = nil
do
  local v_23_0_ = nil
  local function process_message_queue0()
    awaiting_process_3f = false
    if not a["empty?"](state["message-queue"]) then
      local msgs = state["message-queue"]
      state["message-queue"] = {}
      local function _3_(args)
        return process_message(unpack(args))
      end
      return a["run!"](_3_, msgs)
    end
  end
  v_23_0_ = process_message_queue0
  _0_0["aniseed/locals"]["process-message-queue"] = v_23_0_
  process_message_queue = v_23_0_
end
local enqueue_message = nil
do
  local v_23_0_ = nil
  local function enqueue_message0(...)
    table.insert(state["message-queue"], {...})
    if not awaiting_process_3f then
      vim.schedule(process_message_queue)
      awaiting_process_3f = true
      return nil
    end
  end
  v_23_0_ = enqueue_message0
  _0_0["aniseed/locals"]["enqueue-message"] = v_23_0_
  enqueue_message = v_23_0_
end
local eval = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function eval0(opts, cb)
      local function _3_(_)
        local _4_
        if config.eval["pretty-print?"] then
          _4_ = "conjure.nrepl.pprint/pprint"
        else
        _4_ = nil
        end
        local _7_
        do
          local _6_0 = a["get-in"](opts, {"range", "start", 2})
          if _6_0 then
            _7_ = a.inc(_6_0)
          else
            _7_ = _6_0
          end
        end
        return send({["nrepl.middleware.print/print"] = _4_, code = opts.code, column = _7_, file = opts["file-path"], line = a["get-in"](opts, {"range", "start", 1}), op = "eval", session = a["get-in"](state, {"conn", "session"})}, cb)
      end
      return with_conn_or_warn(_3_)
    end
    v_23_0_0 = eval0
    _0_0["eval"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["eval"] = v_23_0_
  eval = v_23_0_
end
local inject_pprint_wrapper = nil
do
  local v_23_0_ = nil
  local function inject_pprint_wrapper0()
    return send({code = ("(ns conjure.nrepl.pprint" .. "  (:require [clojure.pprint :as pp]))" .. "(defn pprint [val w opts]" .. "  (apply pp/write val" .. "    (mapcat identity (assoc opts :stream w))))"), op = "eval"})
  end
  v_23_0_ = inject_pprint_wrapper0
  _0_0["aniseed/locals"]["inject-pprint-wrapper"] = v_23_0_
  inject_pprint_wrapper = v_23_0_
end
local capture_describe = nil
do
  local v_23_0_ = nil
  local function capture_describe0()
    local function _3_(msg)
      return a["assoc-in"](state, {"conn", "describe"}, msg)
    end
    return send({op = "describe"}, _3_)
  end
  v_23_0_ = capture_describe0
  _0_0["aniseed/locals"]["capture-describe"] = v_23_0_
  capture_describe = v_23_0_
end
local with_conn_and_op_or_warn = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function with_conn_and_op_or_warn0(op, f, opts)
      local function _3_(conn)
        if a["get-in"](conn, {"describe", "ops", op}) then
          return f(conn)
        else
          if not a.get(opts, "silent?") then
            ui.display({("; Unsupported operation: " .. op), "; Ensure the CIDER middleware is installed and up to date", "; https://docs.cider.mx/cider-nrepl/usage.html"})
          end
          if a.get(opts, "else") then
            return opts["else"]()
          end
        end
      end
      return with_conn_or_warn(_3_, opts)
    end
    v_23_0_0 = with_conn_and_op_or_warn0
    _0_0["with-conn-and-op-or-warn"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["with-conn-and-op-or-warn"] = v_23_0_
  with_conn_and_op_or_warn = v_23_0_
end
local handle_connect_fn = nil
do
  local v_23_0_ = nil
  local function handle_connect_fn0()
    local function _3_(err)
      local conn = a.get(state, "conn")
      if err then
        display_conn_status(err)
        return disconnect()
      else
        do end (conn.sock):read_start(enqueue_message)
        display_conn_status("connected")
        capture_describe()
        inject_pprint_wrapper()
        return assume_or_create_session()
      end
    end
    return vim.schedule_wrap(_3_)
  end
  v_23_0_ = handle_connect_fn0
  _0_0["aniseed/locals"]["handle-connect-fn"] = v_23_0_
  handle_connect_fn = v_23_0_
end
local connect = nil
do
  local v_23_0_ = nil
  do
    local v_23_0_0 = nil
    local function connect0(_3_0)
      local _4_ = _3_0
      local host = _4_["host"]
      local port = _4_["port"]
      local resolved_host = net.resolve(host)
      local conn = {["raw-host"] = host, host = resolved_host, msgs = {}, port = port, session = nil, sock = vim.loop.new_tcp()}
      if a.get(state, "conn") then
        disconnect()
      end
      a.assoc(state, "conn", conn)
      return (conn.sock):connect(resolved_host, port, handle_connect_fn())
    end
    v_23_0_0 = connect0
    _0_0["connect"] = v_23_0_0
    v_23_0_ = v_23_0_0
  end
  _0_0["aniseed/locals"]["connect"] = v_23_0_
  connect = v_23_0_
end
return nil