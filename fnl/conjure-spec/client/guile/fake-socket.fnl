(var fake-repl {})

(fn start []
  fake-repl)

(fn set-fake-repl [repl]
  (set fake-repl repl))

(fn build-fake-repl 
  [send] 
  {:send send 
   :status nil 
   :destroy (fn [])})

{: start
 : set-fake-repl
 : build-fake-repl}
