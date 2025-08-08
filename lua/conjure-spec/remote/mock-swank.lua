-- [nfnl] fnl/conjure-spec/remote/mock-swank.fnl
local send_calls = {}
local clear_send_calls
local function _1_()
  for i, _ in ipairs(send_calls) do
    send_calls[i] = nil
  end
  return nil
end
clear_send_calls = _1_
local send
local function _2_(_, msg, cb)
  table.insert(send_calls, {msg = msg, cb = cb})
  return nil
end
send = _2_
local connect
local function _3_(opts)
  local function _4_()
  end
  return {destroy = _4_, host = opts.host, port = opts.port}
end
connect = _3_
return {send = send, ["send-calls"] = send_calls, ["clear-send-calls"] = clear_send_calls, connect = connect}
