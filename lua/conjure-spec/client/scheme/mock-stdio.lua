-- [nfnl] fnl/conjure-spec/client/scheme/mock-stdio.fnl
local mock_send
local function _1_(_)
end
mock_send = _1_
local set_mock_send
local function _2_(send)
  mock_send = send
  return nil
end
set_mock_send = _2_
local start
local function _3_()
  local function _4_()
  end
  return {send = mock_send, destroy = _4_}
end
start = _3_
return {start = start, ["set-mock-send"] = set_mock_send}
