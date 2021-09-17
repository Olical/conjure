(module conjure.remote.transport.swank
  {autoload {a conjure.aniseed.core
             log conjure.log}})

(defn encode [msg]
  (let [n (a.count msg)
        header (string.format "%06x" (+ 1 n))] ; Additional 1 for trailing newline
    (.. header msg "\n")))

(defn decoder []
  (var awaiting nil)
  (var buffer "")

  (fn reset []
    (set awaiting nil)
    (set buffer "")

    (fn decode [chunk acc]
      (log.dbg "decoder" chunk))))
