(module conjure.client.janet.netrepl.config)

(def debug? false)

(def connection
  {:default-host "127.0.0.1"
   :default-port "9365"})

(def mappings
  {:connect "cc"
   :disconnect "cd"})
