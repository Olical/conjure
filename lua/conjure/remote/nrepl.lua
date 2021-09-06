local _2afile_2a = "fnl/conjure/remote/nrepl.fnl"
local _2amodule_name_2a = "conjure.remote.nrepl"
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
local a, bencode, client, extract, log, net, timer, uuid = autoload("conjure.aniseed.core"), autoload("conjure.remote.transport.bencode"), autoload("conjure.client"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.net"), autoload("conjure.timer"), autoload("conjure.uuid")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["bencode"] = bencode
_2amodule_locals_2a["client"] = client
_2amodule_locals_2a["extract"] = extract
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["net"] = net
_2amodule_locals_2a["timer"] = timer
_2amodule_locals_2a["uuid"] = uuid
local function with_all_msgs_fn(cb)
  local acc = {}
  local function _1_(msg)
    table.insert(acc, msg)
    if msg.status.done then
      return cb(acc)
    end
  end
  return _1_
end
_2amodule_2a["with-all-msgs-fn"] = with_all_msgs_fn
local function connect(opts)
  local state = {["message-queue"] = {}, ["awaiting-process?"] = false, bc = bencode.new(), msgs = {}}
  local conn = {session = nil, state = state}
  local function enrich_status(msg)
    local ks = a.get(msg, "status")
    local status = {}
    local function _3_(k)
      return a.assoc(status, k, true)
    end
    a["run!"](_3_, ks)
    a.assoc(msg, "status", status)
    return msg
  end
  local function send(msg, cb)
    local msg_id = uuid.v4()
    a.assoc(msg, "id", msg_id)
    if (not msg.session and conn.session) then
      a.assoc(msg, "session", conn.session)
    end
    log.dbg("send", msg)
    local function _5_()
    end
    a["assoc-in"](state, {"msgs", msg_id}, {msg = msg, cb = (cb or _5_), ["sent-at"] = os.time()})
    do end (conn.sock):write(bencode.encode(msg))
    return nil
  end
  local function process_message(err, chunk)
    if err then
      return opts["on-error"](err)
    elseif not chunk then
      return opts["on-error"]()
    else
      local function _6_(msg)
        log.dbg("receive", msg)
        enrich_status(msg)
        if msg.status["need-input"] then
          local function _7_()
            return send({op = "stdin", stdin = ((extract.prompt("Input required: ") or "") .. "\n"), session = msg.session})
          end
          client.schedule(_7_)
        end
        do
          local cb = a["get-in"](state, {"msgs", msg.id, "cb"}, opts["default-callback"])
          local ok_3f, err0 = pcall(cb, msg)
          if not ok_3f then
            opts["on-error"](err0)
          end
        end
        if msg.status.done then
          a["assoc-in"](state, {"msgs", msg.id}, nil)
        end
        return opts["on-message"](msg)
      end
      return a["run!"](_6_, bencode["decode-all"](state.bc, chunk))
    end
  end
  local function process_message_queue()
    state["awaiting-process?"] = false
    if not a["empty?"](state["message-queue"]) then
      local msgs = state["message-queue"]
      state["message-queue"] = {}
      local function _12_(args)
        return process_message(unpack(args))
      end
      return a["run!"](_12_, msgs)
    end
  end
  local function enqueue_message(...)
    table.insert(state["message-queue"], {...})
    if not state["awaiting-process?"] then
      state["awaiting-process?"] = true
      return client.schedule(process_message_queue)
    end
  end
  local function handle_connect_fn()
    local function _15_(err)
      if err then
        return opts["on-failure"](err)
      else
        do end (conn.sock):read_start(client.wrap(enqueue_message))
        return opts["on-success"]()
      end
    end
    return client["schedule-wrap"](_15_)
  end
  conn = a["merge!"](conn, {send = send}, net.connect({host = opts.host, port = opts.port, cb = handle_connect_fn()}))
  return conn
end
_2amodule_2a["connect"] = connect