(module conjure.remote.transport.swank
  {autoload {a conjure.aniseed.core
             log conjure.log}})

(defn encode [msg]
  (let [n (a.count msg)
        header (string.format "%06x" (+ 1 n))] ; Additional 1 for trailing newline
    (.. header msg "\n")))

(defn decoder [msg pos]
  (log.append [msg]))
