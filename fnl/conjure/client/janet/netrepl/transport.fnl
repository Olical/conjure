(module conjure.client.janet.netrepl.transport
  {require {bit bit
            a conjure.aniseed.core
            str conjure.aniseed.string}})

(defn encode [msg]
  (let [n (a.count msg)]
    (..  (string.char
           (bit.band n 0xFF)
           (bit.band (bit.rshift n 8) 0xFF)
           (bit.band (bit.rshift n 16) 0xFF)
           (bit.band (bit.rshift n 24) 0xFF))
        msg)))

(defn- split [chunk]
  (let [(b0 b1 b2 b3) (string.byte chunk 1 4)]
    (values
      (bit.bor
        (bit.band b0 0xFF)
        (bit.lshift (bit.band b1 0xFF) 8)
        (bit.lshift (bit.band b2 0xFF) 16)
        (bit.lshift (bit.band b3 0xFF) 24))
      (string.sub chunk 5))))

(defn decoder []
  (var awaiting nil)
  (var buffer "")

  (fn reset []
    (set awaiting nil)
    (set buffer ""))

  (fn decode [chunk acc]
    (local acc (or acc []))

    (if awaiting
      (do
        (local before (a.count buffer))
        (local seen (a.count chunk))
        (set buffer (.. buffer chunk))

        (if
          ;; More than expected.
          ;; Consume part of the buffer reset state and recur.
          (> seen awaiting)
          (let [consumed (string.sub buffer 1 (+ before awaiting))
                next-chunk (string.sub chunk (a.inc awaiting))]
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

;; ------------------ 8< ------------------
; (defn- parse-result [msg]
;   (let [lines (-> msg
;                   (text.strip-ansi-codes)
;                   (text.trim-last-newline)
;                   (text.split-lines)
;                   (a.kv-pairs))
;         total (a.count lines)
;         head (a.second (a.first lines))]
;     (table.sort lines #(> (a.first $1) (a.first $2)))
;     (var text-lines [])
;     (var data-lines [])
;     (var data?
;       (not (or (text.starts-with head "error:")
;                (text.starts-with head "compile error:"))))

;     (a.run!
;       (fn [[n line]]
;         (if
;           (and data? (text.starts-with line "("))
;           (do
;             (table.insert
;               data-lines 1
;               (string.sub line 2
;                           (when (a.empty? data-lines)
;                             -2)))
;             (set data? false))

;           data?
;           (table.insert
;             data-lines 1
;             (string.sub line 3
;                         (when (= n total)
;                           -2)))

;           (table.insert
;             text-lines 1
;             (.. "# " line))))
;       lines)
;     {:text-lines text-lines
;      :data-lines data-lines
;      :data (str.join "\n" data-lines)}))



; (defn- decode-one [chunk]
;   (let [expecting (a.get-in state [:conn :expecting])]
;     (if expecting
;       (let [part (.. (a.get-in state [:conn :part]) chunk)
;             part-n (a.count part)]
;         (if (>= part-n expecting)
;           (do
;             (a.assoc-in state [:conn :expecting] nil)
;             (a.assoc-in state [:conn :part] nil)
;             [(string.sub part 1 expecting)
;              (when (> part-n expecting)
;                (string.sub part (a.inc expecting)))])
;           (do
;             (a.assoc-in state [:conn :part] part)
;             nil)))
;       (let [n (->> (a.map
;                      (fn [c]
;                        (string.byte (string.sub chunk c c)))
;                      [1 2 3 4])
;                    (a.reduce #(+ $1 $2) 0))
;             part (string.sub chunk 5)
;             part-n (a.count part)]
;         (if
;           (>= part-n n)
;           [(string.sub part 1 n)
;            (when (> part-n n)
;              (string.sub part (a.inc n)))]
;           (do
;             (a.assoc-in state [:conn :expecting] n)
;             (a.assoc-in state [:conn :part] part)
;             nil))))))

; (defn- decode-all [chunk acc]
;   (let [acc (or acc [])
;         res (decode-one chunk)]
;     (if res
;       (let [[msg rem] res]
;         (table.insert acc msg)
;         (if rem
;           (decode-all rem acc)
;           acc))
;       acc)))

