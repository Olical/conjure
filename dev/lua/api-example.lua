local eval = require("conjure.eval")
local client = require("conjure.client")
local text = require("conjure.text")

client["with-filetype"]("janet", eval["eval-str"], {
  origin = "my-awesome-plugin",
  code = "(+ 10 20)", 
  ["passive?"] = true,
  ["on-result"] = function (r)
    local clean = text["strip-ansi-escape-sequences"](r)
    print("RESULT:", r)
    print("CLEANED:", clean)
  end
})
