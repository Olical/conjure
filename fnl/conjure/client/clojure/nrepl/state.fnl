(module conjure.client.clojure.nrepl.state
  {require {client conjure.client
            bencode-stream conjure.bencode-stream}})

(defonce get
  (client.new-state
    (fn []
      {:conn nil
       :bs (bencode-stream.new)
       :message-queue []
       :awaiting-process? false
       :join-next {:key nil}})))
