local _2afile_2a = "fnl/conjure/remote/nrepl.fnl"
local _1_
do
  local name_4_auto = "conjure.remote.nrepl"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.remote.transport.bencode"), autoload("conjure.client"), autoload("conjure.extract"), autoload("conjure.log"), autoload("conjure.net"), autoload("conjure.timer"), autoload("conjure.uuid")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", bencode = "conjure.remote.transport.bencode", client = "conjure.client", extract = "conjure.extract", log = "conjure.log", net = "conjure.net", timer = "conjure.timer", uuid = "conjure.uuid"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local bencode = _local_4_[2]
local client = _local_4_[3]
local extract = _local_4_[4]
local log = _local_4_[5]
local net = _local_4_[6]
local timer = _local_4_[7]
local uuid = _local_4_[8]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.remote.nrepl"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local with_all_msgs_fn
do
  local v_23_auto
  do
    local v_25_auto
    local function with_all_msgs_fn0(cb)
      local acc = {}
      local function _8_(msg)
        table.insert(acc, msg)
        if msg.status.done then
          return cb(acc)
        end
      end
      return _8_
    end
    v_25_auto = with_all_msgs_fn0
    _1_["with-all-msgs-fn"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["with-all-msgs-fn"] = v_23_auto
  with_all_msgs_fn = v_23_auto
end
local connect
do
  local v_23_auto
  do
    local v_25_auto
    local function connect0(opts)
      local state = {["awaiting-process?"] = false, ["message-queue"] = {}, bc = bencode.new(), msgs = {}}
      local conn = {session = nil, state = state}
      local function enrich_status(msg)
        local ks = a.get(msg, "status")
        local status = {}
        local function _10_(k)
          return a.assoc(status, k, true)
        end
        a["run!"](_10_, ks)
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
        local function _12_()
        end
        a["assoc-in"](state, {"msgs", msg_id}, {["sent-at"] = os.time(), cb = (cb or _12_), msg = msg})
        do end (conn.sock):write(bencode.encode(msg))
        return nil
      end
      local function process_message(err, chunk)
        if err then
          return opts["on-error"](err)
        elseif not chunk then
          return opts["on-error"]()
        else
          local function _13_(msg)
            log.dbg("receive", msg)
            enrich_status(msg)
            if msg.status["need-input"] then
              local function _14_()
                return send({op = "stdin", session = msg.session, stdin = ((extract.prompt("Input required: ") or "") .. "\n")})
              end
              client.schedule(_14_)
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
          return a["run!"](_13_, bencode["decode-all"](state.bc, chunk))
        end
      end
      local function process_message_queue()
        state["awaiting-process?"] = false
        if not a["empty?"](state["message-queue"]) then
          local msgs = state["message-queue"]
          state["message-queue"] = {}
          local function _19_(args)
            return process_message(unpack(args))
          end
          return a["run!"](_19_, msgs)
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
        local function _22_(err)
          if err then
            return opts["on-failure"](err)
          else
            do end (conn.sock):read_start(client.wrap(enqueue_message))
            return opts["on-success"]()
          end
        end
        return client["schedule-wrap"](_22_)
      end
      conn = a["merge!"](conn, {send = send}, net.connect({cb = handle_connect_fn(), host = opts.host, port = opts.port}))
      return conn
    end
    v_25_auto = connect0
    _1_["connect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect"] = v_23_auto
  connect = v_23_auto
end
return nil