-- [nfnl] Compiled from fnl/conjure/remote/nrepl.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("nfnl.module")
local autoload = _local_1_["autoload"]
local a = autoload("conjure.aniseed.core")
local bencode = autoload("conjure.remote.transport.bencode")
local client = autoload("conjure.client")
local log = autoload("conjure.log")
local net = autoload("conjure.net")
local uuid = autoload("conjure.uuid")
local function with_all_msgs_fn(cb)
  local acc = {}
  local function _2_(msg)
    table.insert(acc, msg)
    if msg.status.done then
      return cb(acc)
    else
      return nil
    end
  end
  return _2_
end
local function enrich_status(msg)
  local ks = a.get(msg, "status")
  local status = {}
  local function _4_(k)
    return a.assoc(status, k, true)
  end
  a["run!"](_4_, ks)
  a.assoc(msg, "status", status)
  return msg
end
local function connect(opts)
  local state = {["message-queue"] = {}, bc = bencode.new(), msgs = {}, ["awaiting-process?"] = false}
  local conn = {session = nil, state = state}
  local function send(msg, cb)
    local msg_id = uuid.v4()
    a.assoc(msg, "id", msg_id)
    if ("no-session" == msg.session) then
      a.assoc(msg, "session", nil)
    elseif (not msg.session and conn.session) then
      a.assoc(msg, "session", conn.session)
    else
    end
    log.dbg("send", msg)
    local or_6_ = cb
    if not or_6_ then
      local function _7_()
      end
      or_6_ = _7_
    end
    a["assoc-in"](state, {"msgs", msg_id}, {msg = msg, cb = or_6_, ["sent-at"] = os.time()})
    conn.sock:write(bencode.encode(msg))
    return nil
  end
  local function process_message(err, chunk)
    if err then
      return opts["on-error"](err)
    elseif not chunk then
      return opts["on-error"]()
    else
      local function _8_(msg)
        log.dbg("receive", msg)
        enrich_status(msg)
        do
          local ok_3f, err0 = pcall(opts["side-effect-callback"], msg)
          if not ok_3f then
            opts["on-error"](err0)
          else
          end
        end
        do
          local cb = a["get-in"](state, {"msgs", msg.id, "cb"}, opts["default-callback"])
          local ok_3f, err0 = pcall(cb, msg)
          if not ok_3f then
            opts["on-error"](err0)
          else
          end
        end
        if msg.status.done then
          a["assoc-in"](state, {"msgs", msg.id}, nil)
        else
        end
        return opts["on-message"](msg)
      end
      return a["run!"](_8_, bencode["decode-all"](state.bc, chunk))
    end
  end
  local function process_message_queue()
    state["awaiting-process?"] = false
    if not a["empty?"](state["message-queue"]) then
      local msgs = state["message-queue"]
      state["message-queue"] = {}
      local function _13_(args)
        return process_message(unpack(args))
      end
      return a["run!"](_13_, msgs)
    else
      return nil
    end
  end
  local function enqueue_message(...)
    table.insert(state["message-queue"], {...})
    if not state["awaiting-process?"] then
      state["awaiting-process?"] = true
      return client.schedule(process_message_queue)
    else
      return nil
    end
  end
  local function handle_connect_fn()
    local function _16_(err)
      if err then
        return opts["on-failure"](err)
      else
        conn.sock:read_start(client.wrap(enqueue_message))
        return opts["on-success"]()
      end
    end
    return client["schedule-wrap"](_16_)
  end
  conn = a["merge!"](conn, {send = send}, net.connect({host = opts.host, port = opts.port, cb = handle_connect_fn()}))
  return conn
end
return {connect = connect, ["enrich-status"] = enrich_status, ["with-all-msgs-fn"] = with_all_msgs_fn}
