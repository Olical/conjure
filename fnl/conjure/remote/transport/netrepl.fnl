(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local bit (autoload :bit))

(local M (define :conjure.remote.transport.netrepl))

(fn M.encode [msg]
  (let [n (core.count msg)]
    (..  (string.char
           (bit.band n 0xFF)
           (bit.band (bit.rshift n 8) 0xFF)
           (bit.band (bit.rshift n 16) 0xFF)
           (bit.band (bit.rshift n 24) 0xFF))
        msg)))

(fn split [chunk]
  (let [(b0 b1 b2 b3) (string.byte chunk 1 4)]
    (values
      (bit.bor
        (bit.band b0 0xFF)
        (bit.lshift (bit.band b1 0xFF) 8)
        (bit.lshift (bit.band b2 0xFF) 16)
        (bit.lshift (bit.band b3 0xFF) 24))
      (string.sub chunk 5))))

(fn M.decoder []
  (var awaiting nil)
  (var buffer "")

  (fn reset []
    (set awaiting nil)
    (set buffer ""))

  (fn decode [chunk acc]
    (local acc (or acc []))

    (if awaiting
      (do
        (local before (core.count buffer))
        (local seen (core.count chunk))
        (set buffer (.. buffer chunk))

        (if
          ;; More than expected.
          ;; Consume part of the buffer reset state and recur.
          (> seen awaiting)
          (let [consumed (string.sub buffer 1 (+ before awaiting))
                next-chunk (string.sub chunk (core.inc awaiting))]
            (table.insert acc consumed)
            (reset)
            (decode next-chunk acc))

          ;; Exact amount required.
          ;; Consume whole buffer, reset state and return.
          (= seen awaiting)
          (do
            (table.insert acc buffer)
            (reset)
            acc)

          ;; Else, less than expected.
          ;; Mark off what we have so far, return.
          (do
            (set awaiting (- awaiting seen))
            acc)))

      (let [(n rem) (split chunk)]
        (set awaiting n)
        (decode rem acc)))))

M
