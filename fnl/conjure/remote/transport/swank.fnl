(module conjure.remote.transport.swank
  {autoload {a conjure.aniseed.core
             log conjure.log}})

(defn encode [msg]
  (let [n (a.count msg)
        header (string.format "%06x" (+ 1 n))] ; Additional 1 for trailing newline
    (.. header msg "\n")))

(defn decode [msg]
  (let [len (tonumber (string.sub msg 1 7) 16)
        cmd (string.sub msg 7 len)]
    cmd))
