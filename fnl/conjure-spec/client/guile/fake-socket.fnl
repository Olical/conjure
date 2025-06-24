(var fake-repl {})

(fn set-fake-repl [repl]
  (set fake-repl repl))

(fn start []
  fake-repl)

{: start
 : set-fake-repl}
