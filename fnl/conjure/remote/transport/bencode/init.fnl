(local buffer (require :string.buffer))
(local ffi (require :ffi))

(fn new [] {:buf (buffer.new) :stack []})

(fn decode-all [state chunk]
  (when (and chunk (> (length chunk) 0)) (state.buf:put chunk))

  (var i 0)
  (let [acc [] (ptr blen) (state.buf:ref)]
    (fn need [n] (<= (+ i n) blen))

    (fn push [v]
      (let [depth (length state.stack)]
        (if (= depth 0)
            (table.insert acc v)
            (let [frame (. state.stack depth)]
              (if (= frame.t "list")
                  (table.insert frame.v v)
                  (if (= frame.k nil)
                      (do
                        (when (not (= (type v) "string"))
                          (error "dict key must be string"))
                        (set frame.k v))
                      (do
                        (tset frame.v frame.k v)
                        (set frame.k nil))))))))

    (fn parse []
      (if (not (need 1)) (values nil true)
          (let [c (. ptr i)]
            (if
              ;; integer
              (= c (string.byte "i"))
              (do
                (set i (+ i 1))
                (let [start i]
                  (while true
                    (when (not (need 1))
                      (lua "return nil, true"))
                    (if (= (. ptr i) (string.byte "e"))
                        (do
                          (let [num (tonumber (ffi.string (+ ptr start) (- i start)))]
                            (set i (+ i 1))
                            (lua "return num")))
                        (set i (+ i 1))))))

              ;; string
              (and (>= c (string.byte "0")) (<= c (string.byte "9")))
              (do
                (let [start i]
                  (while true
                    (set i (+ i 1))
                    (when (not (need 1))
                      (lua "return nil, true"))
                    (when (= (. ptr i) (string.byte ":"))
                      (lua "break")))
                  (let [len (tonumber (ffi.string (+ ptr start) (- i start)))]
                    (set i (+ i 1))
                    (when (not (need len))
                      (lua "return nil, true"))
                    (let [s (ffi.string (+ ptr i) len)]
                      (set i (+ i len))
                      s))))

              ;; list or dict opener
              (or (= c (string.byte "l")) (= c (string.byte "d")))
              (do (set i (+ i 1))
                (table.insert state.stack {:t (if (= c (string.byte "l")) "list" "dict") :v {} :k nil}))

              ;; terminator
              (= c (string.byte "e"))
              (do
                (when (= (length state.stack) 0) (error "unexpected 'e'"))
                (set i (+ i 1))
                (let [frame (table.remove state.stack)]
                  (when (and (= frame.t "dict") (not (= frame.k nil)))
                    (error "dictionary ended while waiting for value"))
                  frame.v))

              (error (string.format "bad bencode byte 0x%02x" c))))))

    (while true
      (let [start i (val incomplete) (parse)]
        (when incomplete
          (set i start)
          (lua "break"))
        (when val
          (push val))))

    (when (> i 0) (state.buf:skip i))

    acc))

(fn is-list? [x]
  (let [n (length x)]
    (each [k _ (pairs x)]
      (when (not (and (= (type k) "number") (= (% k 1) 0) (<= 1 k n)))
        (lua "return false")))
    (for [i 1 n] (when (= (. x i) nil) (lua "return false")))
    true))

(fn encode [x]
  (case (type x)
    "string" (.. (length x) ":" x)
    "number" (if (= (% x 1) 0) (.. "i" x "e") (error (.. "bencode: non‑integer number " x)))
    "table"  (if (is-list? x)
                 (.. "l" (table.concat (icollect [_ v (ipairs x)] (encode v))) "e")
                 (let [keys []]
                   (each [k _ (pairs x)]
                     (assert (= (type k) "string") "bencode: dict key not string")
                     (table.insert keys k))
                   (table.sort keys)
                   (.. "d" (table.concat (icollect [_ k (ipairs keys)] (.. (encode k) (encode (. x k))))) "e")))

    _ (error (.. "bencode: unsupported type " (type x)))))

{: new : decode-all : encode}
