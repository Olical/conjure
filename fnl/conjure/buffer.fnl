(module conjure.buffer
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             str conjure.aniseed.string
             text conjure.text}})

(defn unlist [buf]
  "The buflisted attribute is reset when a new window is opened. Since the
  buffer upsert is decoupled from the window we have to run this whenever we
  split the buffer into some new window."
  (nvim.buf_set_option buf :buflisted false))

(defn resolve [buf-name]
  (nvim.buf_get_name (nvim.fn.bufnr buf-name)))

(defn upsert-hidden [buf-name new-buf-fn]
  (let [(ok? buf) (pcall nvim.fn.bufnr buf-name)
        loaded? (and ok? (nvim.buf_is_loaded buf))]
    (if (or (= -1 buf) (not loaded?))
      (let [buf (if loaded?
                  buf
                  (let [buf (nvim.fn.bufadd buf-name)]
                    (nvim.fn.bufload buf)
                    buf))]
        (nvim.buf_set_option buf :buftype :nofile)
        (nvim.buf_set_option buf :bufhidden :hide)
        (nvim.buf_set_option buf :swapfile false)
        (unlist buf)
        (when new-buf-fn
          (new-buf-fn buf))
        buf)
      buf)))

(defn empty? [buf]
  (and (<= (nvim.buf_line_count buf) 1)
       (= 0 (a.count (a.first (nvim.buf_get_lines buf 0 -1 false))))))

(defn replace-range [buf range s]
  (let [start-line (a.dec (a.get-in range [:start 1]))
        end-line (a.get-in range [:end 1])
        start-char (a.get-in range [:start 2])
        end-char (a.get-in range [:end 2])

        new-lines (text.split-lines s)
        old-lines (nvim.buf_get_lines buf start-line end-line false)

        head (string.sub (a.first old-lines) 1 start-char)
        tail (string.sub (a.last old-lines) (+ end-char 2))]

    (a.update
      new-lines 1
      (fn [l] (.. head l)))

    (a.update
      new-lines (a.count new-lines)
      (fn [l] (.. l tail)))

    (nvim.buf_set_lines buf start-line end-line false new-lines)))

(defn- take-while [f xs]
  (var acc [])
  (var done? false)
  (for [i 1 (a.count xs) 1]
    (let [v (. xs i)]
      (if (and (not done?) (f v))
        (table.insert acc v)
        (set done? true))))
  acc)

(defn append-prefixed-line [buf [tl tc] prefix body]
  "Appends a string to the end of the current line, or the one below this one
  if there's already the same suffix on the end. If there's already a matching
  suffix on the end of this line and the one below, it will insert another
  below that last one and so on."
  (let [tl (a.dec tl)
        [head-line & lines] (nvim.buf_get_lines buf tl -1 false)
        to-append (text.prefixed-lines body prefix {})]
    (if (head-line:find prefix tc)
      (let [[new-tl lines]
            (or
              (->> (a.kv-pairs lines)
                   (a.map
                     (fn [[n line]]
                       (if (text.starts-with line prefix)
                         [(+ tl n) (a.concat [line] to-append)]
                         false)))
                   (take-while a.identity)
                   (a.last))
              [tl (a.concat [head-line] to-append)])]
        (nvim.buf_set_lines buf new-tl (a.inc new-tl) false lines))
      (nvim.buf_set_lines
        buf tl
        (a.inc tl)
        false
        (if (= 1 (a.count to-append))
          [(.. head-line " " (a.first to-append))]
          (a.concat
            [head-line]
            to-append))))))
