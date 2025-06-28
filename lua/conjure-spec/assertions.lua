-- [nfnl] fnl/conjure-spec/assertions.fnl
local assert = require("luassert.assert")
local say = require("say")
local function assert_contains(_, args)
  if (string.match(args[2], args[1]) ~= nil) then
    return true
  else
    return false
  end
end
say:set("assertion.contains.positive", "Expected %s \nto be a substring of %s")
say:set("assertion.contains.negative", "Expected %s \nnot to be a substring of %s")
return assert:register("assertion", "contains", assert_contains, "assertion.contains.positive", "assertion.contains.negative")
