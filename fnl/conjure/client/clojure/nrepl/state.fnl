(module conjure.client.clojure.nrepl.state
  {require {client conjure.client}})

(defonce get
  (client.new-state
    (fn []
      {:conn nil
       :join-next {:key nil}})))
