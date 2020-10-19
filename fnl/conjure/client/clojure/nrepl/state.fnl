(module conjure.client.clojure.nrepl.state
  {require {client conjure.client
            bencode conjure.remote.transport.bencode}})

(defonce get
  (client.new-state
    (fn []
      {:conn nil
       :bs (bencode.new)
       :message-queue []
       :awaiting-process? false
       :join-next {:key nil}})))
