(module conjure.remote.transport.swank
  {autoload {a conjure.aniseed.core
             log conjure.log}})

;;;; Slynk transport layer to deal with message encoding and decoding.
;;;; For reference, these functions should generally match what is expected
;;;; here: https://github.com/joaotavora/sly/blob/master/slynk/slynk-rpc.lisp#L150
;;;; (look for "write-message" and others in slynk rpc) 

(defn encode [msg]
  "Slynk RPC encoding"
  ;; TODO currently this is swank encoding, which might be similar
  ;; to what is expected by slynk, but will need to be verified.
  ;; we currently write out 6 hexidecimal digits to signify length before 
  ;; we send out our messge.
  (let [n (a.count msg)
        header (string.format "%06x" (+ 1 n))] ; Additional 1 for trailing newline
    (.. header msg "\n")))

(defn decode [msg]
  "Slynk RPC decoding"
  ;; read length for the first 6 digits, and then trim
  ;; the string for that length.
  ;; note that this matches the above.
  (let [len (tonumber (string.sub msg 1 7) 16)
        cmd (string.sub msg 7 len)]
    cmd))
