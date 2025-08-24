-- [nfnl] fnl/conjure-spec/client/guile/mock-socket.fnl
local mock_repl = {}
local function start()
  return mock_repl
end
local function set_mock_repl(repl)
  mock_repl = repl
  return nil
end
local function build_mock_repl(send)
  local function _1_()
  end
  return {send = send, status = nil, destroy = _1_}
end
return {start = start, ["set-mock-repl"] = set_mock_repl, ["build-mock-repl"] = build_mock_repl}
