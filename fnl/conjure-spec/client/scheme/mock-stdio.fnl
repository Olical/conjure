(var mock-send (fn [_]))

(local set-mock-send (fn [send]
  (set mock-send send)))

(local start 
  (fn [] 
    {:send mock-send
     :destroy (fn [])}))

{ : start 
  : set-mock-send }

