(module conjure.client.clojure.nrepl.state
  {require {client conjure.client
            bencode-stream conjure.bencode-stream}})

(client.state
  [:clojure :nrepl]
  {:conn nil
   :bs (bencode-stream.new)
   :message-queue []
   :awaiting-process? false
   :join-next {:key nil}})

(defn get [...]
  (client.state [:clojure :nrepl ...]))
