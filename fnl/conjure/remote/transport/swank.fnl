(local {: autoload} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))

(fn encode [msg]
  (let [n (core.count msg)
        header (string.format "%06x" (+ 1 n))] ; Additional 1 for trailing newline
    (.. header msg "\n")))

(fn decode [msg]
  (let [len (tonumber (string.sub msg 1 7) 16)
        cmd (string.sub msg 7 len)]
    cmd))

{: encode : decode}
