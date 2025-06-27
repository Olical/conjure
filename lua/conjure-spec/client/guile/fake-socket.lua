-- [nfnl] fnl/conjure-spec/client/guile/fake-socket.fnl
local fake_repl = {}
local function set_fake_repl(repl)
  fake_repl = repl
  return nil
end
local function start()
  return fake_repl
end
return {start = start, ["set-fake-repl"] = set_fake_repl}
