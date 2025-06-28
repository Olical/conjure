-- [nfnl] fnl/conjure-spec/client/guile/fake-socket.fnl
local fake_repl = {}
local function start()
  return fake_repl
end
local function set_fake_repl(repl)
  fake_repl = repl
  return nil
end
local function build_fake_repl(send)
  local function _1_()
  end
  return {send = send, status = nil, destroy = _1_}
end
return {start = start, ["set-fake-repl"] = set_fake_repl, ["build-fake-repl"] = build_fake_repl}
