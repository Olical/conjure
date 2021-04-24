(module conjure.client.clojure.nrepl.state
  {autoload {client conjure.client}})

(defonce get
  (client.new-state
    (fn []
      {:conn nil
       :join-next {:key nil}})))
