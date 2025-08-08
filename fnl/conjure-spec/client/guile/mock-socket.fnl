(var mock-repl {})

(fn start []
  mock-repl)

(fn set-mock-repl [repl]
  (set mock-repl repl))

(fn build-mock-repl 
  [send] 
  {:send send 
   :status nil 
   :destroy (fn [])})

{: start
 : set-mock-repl
 : build-mock-repl}
