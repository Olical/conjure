(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local log (autoload :conjure.log))

(fn encode [msg]
  (let [n (a.count msg)
        header (string.format "%06x" (+ 1 n))] ; Additional 1 for trailing newline
    (.. header msg "\n")))

(fn decode [msg]
  (let [len (tonumber (string.sub msg 1 7) 16)
        cmd (string.sub msg 7 len)]
    cmd))

{: encode : decode}
