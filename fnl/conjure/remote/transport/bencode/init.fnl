(import-macros {: if-let : when-let} :conjure.nfnl.macros)
(local buffer (require :string.buffer))
(local ffi (require :ffi))
(local core (require :conjure.nfnl.core))

(fn new [] {:buf (buffer.new) :stack []})

(local \i (string.byte :i))
(local \e (string.byte :e))
(local \l (string.byte :l))
(local \d (string.byte :d))
(local \0 (string.byte :0))
(local \9 (string.byte :9))
(local \_ (string.byte ":"))

(fn decode-all [state chunk]
  (when (and chunk (> (length chunk) 0))
    (state.buf:put chunk))
  (var offset 0)
  (let [vals []
        (ptr blen) (state.buf:ref)]
    (fn check [n]
      "Checks if the buffer has at least N bytes available."
      (when (<= n blen) n))

    (fn push [val]
      "Pushes a value onto the accumulator or the stack."
      (if-let [frame (core.last state.stack)]
              (case frame
                {:t :list}
                (table.insert frame.v val) ; Push value to stack frame list
                {:t :dict :k nil}
                (do
                  (assert (= (type val) :string) "bencode: dict key not string")
                  (set frame.k val)) ; Set pending :k to (string) v
                {:t :dict : k}
                (doto frame
                  (tset :k nil) ; Reset pending :k for next pair
                  (tset :v k val))) ; Set kv pair on dict
              (table.insert vals val))) ; Empty stack, push directly to vals

    (fn parse-number [?term ?inclusive]
      "Returns number if complete, otherwise nil
       Takes term char and whether to include first char for parsing number/string length"
      (let [start (+ offset (if ?inclusive 0 1))]
        (var pos start)
        (while (and (check pos) (not= (. ptr pos) (or ?term \e)))
          (set pos (+ pos 1))) ; Search for terminator one byte at a time
        (when (= (. ptr pos) (or ?term \e)) ; Found terminator, otherwise end of buffer
          (let [num (tonumber (ffi.string (+ ptr start) (- pos start)))]
            (set offset (+ pos 1)) ; Move past terminator
            num))))

    (fn parse-string []
      "Returns string if complete, otherwise nil"
      (let [original-offset offset]
        (when-let [len (parse-number \_ true)]
                  ; Parse string length with colon terminator
                  ; Include number char indicating string (unlike \i which is skipped)
                  (if-let [str-end (check (+ offset len))]
                          (let [str (ffi.string (+ ptr offset) len)]
                            (set offset str-end) ; Move past string
                            str)
                          ; String content incomplete, restore offset
                          (set offset original-offset)))))

    (local BEGIN {})

    (fn parse-collection [t]
      "Pushes a new list/dict frame onto the stack."
      (set offset (+ offset 1)) ; Move past collection indicator
      [BEGIN t])

    (fn parse-terminator []
      "Pops the last frame from the stack and returns its value."
      (assert (> (length state.stack) 0) "bencode: unexpected terminator")
      (set offset (+ offset 1)) ; Move past terminator
      (let [frame (table.remove state.stack)] ; Pop last frame and return its value
        (assert (or (not= frame.t :dict) (= frame.k nil))
                "bencode: dict ended with pending key")
        frame.v))

    (fn parse []
      "Parses the next value from the buffer.
       Returns parsed value if complete, otherwise nil"
      (if-let [c (and (check (+ offset 1)) (. ptr offset))]
              (match c
                \i ; i42e -> 42
                (parse-number)
                (where c (and (>= c \0) (<= c \9))) ; 3:foo -> "foo"
                (parse-string)
                \l ; l3:fooi42e -> { "foo", 42 }
                (parse-collection :list)
                \d ; d3:fooi42e -> { foo = 42 }
                (parse-collection :dict)
                \e ; e -> end of list/dict
                (parse-terminator)
                _
                (error (string.format "bencode: bad byte 0x%02x" c)))))

    (each [val parse &until (= val nil)]
      (match val
        [BEGIN t] (table.insert state.stack {: t :k nil :v {}})
        _ (push val))) ; Push value to stack or vals
    (when (> offset 0) (state.buf:skip offset)) ; Skip parsed bytes
    vals))

(fn is-list? [x]
  "Checks if all keys in a table are sequential."
  (let [keys (core.keys x)]
    (faccumulate [valid? true i 1 (length keys) &until (not valid?)]
      (and valid? (= (. keys i) i)))))

(fn wrap [prefix suffix x]
  (.. prefix x suffix))

(fn encode [x]
  (case (type x)
    :string (.. (length x) ":" x)
    :number (do
              (assert (= (% x 1) 0) (.. "bencode: non‑integer number " x))
              (->> x (wrap :i :e)))
    :table (if (is-list? x)
               (->> (core.vals x) (core.map encode) (table.concat) (wrap :l :e))
               (do
                 (table.sort x)
                 (->> x
                      (core.map-indexed (fn [[k v]]
                                          (assert (= (type k) :string)
                                                  "bencode: dict key not string")
                                          (.. (encode k) (encode v))))
                      (table.concat)
                      (wrap :d :e))))
    _ (error (.. "bencode: unsupported type " (type x)))))

{: new : decode-all : encode}
