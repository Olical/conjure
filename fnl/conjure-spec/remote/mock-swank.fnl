(local send-calls {})

(local clear-send-calls 
  (fn []
    (each [i _ (ipairs send-calls)]
      (tset send-calls i nil))))

(local send 
  (fn [_ msg cb] 
    (table.insert 
      send-calls 
      {:msg msg
       :cb cb})
    nil))

(local connect 
  (fn [opts] 
    {:destroy (fn [])
     :host (. opts :host)
     :port (. opts :port)}))

{: send
 : send-calls
 : clear-send-calls
 : connect}
