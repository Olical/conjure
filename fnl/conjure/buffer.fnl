(local {: autoload} (require :nfnl.module))
(local nvim (autoload :conjure.aniseed.nvim))
(local core (autoload :nfnl.core))
(local text (autoload :conjure.text))

(fn unlist [buf]
  "The buflisted attribute is reset when a new window is opened. Since the
  buffer upsert is decoupled from the window we have to run this whenever we
  split the buffer into some new window."
  (nvim.buf_set_option buf :buflisted false))

(fn resolve [buf-name]
  (nvim.buf_get_name (nvim.fn.bufnr buf-name)))

(fn upsert-hidden [buf-name new-buf-fn]
  (let [(ok? buf) (pcall nvim.fn.bufnr buf-name)
        loaded? (and ok? (nvim.buf_is_loaded buf))]

    ;; This state happens when the user unloads the buffer somehow.
    ;; It still exists but is in a bad state, we delete and start over.
    (when (and (not= -1 buf) (not loaded?))
      (nvim.buf_delete buf {}))

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

(fn empty? [buf]
  (and (<= (nvim.buf_line_count buf) 1)
       (= 0 (core.count (core.first (nvim.buf_get_lines buf 0 -1 false))))))

(fn replace-range [buf range s]
  (let [start-line (core.dec (core.get-in range [:start 1]))
        end-line (core.get-in range [:end 1])
        start-char (core.get-in range [:start 2])
        end-char (core.get-in range [:end 2])

        new-lines (text.split-lines s)
        old-lines (nvim.buf_get_lines buf start-line end-line false)

        head (string.sub (core.first old-lines) 1 start-char)
        tail (string.sub (core.last old-lines) (+ end-char 2))]

    (core.update
      new-lines 1
      (fn [l] (.. head l)))

    (core.update
      new-lines (core.count new-lines)
      (fn [l] (.. l tail)))

    (nvim.buf_set_lines buf start-line end-line false new-lines)))

(fn append-prefixed-line [buf [tl tc] prefix body]
  "Appends a string to the end of the current line, or the one below this one
  if there's already the same suffix on the end. If there's already a matching
  suffix on the end of this line and the one below, it will insert another
  below that last one and so on."
  (let [tl (core.dec tl)
        [head-line & lines] (nvim.buf_get_lines buf tl -1 false)
        to-append (text.prefixed-lines body prefix {})]
    (if (head-line:find prefix tc)
      (let [[new-tl lines]
            (or
              (->> (core.kv-pairs lines)
                   (core.map
                     (fn [[n line]]
                       (if (text.starts-with line prefix)
                         [(+ tl n) (core.concat [line] to-append)]
                         false)))
                   (core.take-while core.identity)
                   (core.last))
              [tl (core.concat [head-line] to-append)])]
        (nvim.buf_set_lines buf new-tl (core.inc new-tl) false lines))
      (nvim.buf_set_lines
        buf tl
        (core.inc tl)
        false
        (if (= 1 (core.count to-append))
          [(.. head-line " " (core.first to-append))]
          (core.concat
            [head-line]
            to-append))))))

{: unlist
 : resolve
 : upsert-hidden
 : empty?
 : replace-range
 : append-prefixed-line}
