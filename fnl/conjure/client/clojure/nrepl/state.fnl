(module conjure.client.clojure.nrepl.state
  {require {client conjure.client
            bencode-stream conjure.bencode-stream}})

(client.init-state
  [:clojure :nrepl]
  {:conn nil
   :bs (bencode-stream.new)
   :message-queue []
   :awaiting-process? false
   :join-next {:key nil}})

(def get (client.state-fn :clojure :nrepl))
