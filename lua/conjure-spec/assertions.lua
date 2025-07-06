-- [nfnl] fnl/conjure-spec/assertions.fnl
local assert = require("luassert.assert")
local say = require("say")
local function assert_has_substring(_, args)
  if (string.match(args[2], args[1]) ~= nil) then
    return true
  else
    return false
  end
end
say:set("assertion.has-substring.positive", "Expected %s \nto be a substring of %s")
say:set("assertion.has-substring.negative", "Expected %s \nnot to be a substring of %s")
return assert:register("assertion", "has-substring", assert_has_substring, "assertion.has-substring.positive", "assertion.has-substring.negative")
