(module conjure.buffer
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            text conjure.text}})

(defn unlist [buf]
  "The buflisted attribute is reset when a new window is opened. Since the
  buffer upsert is decoupled from the window we have to run this whenever we
  split the buffer into some new window."
  (nvim.buf_set_option buf :buflisted false))

(defn resolve [buf-name]
  (nvim.buf_get_name (nvim.fn.bufnr buf-name)))

(defn upsert-hidden [buf-name]
  (let [buf (nvim.fn.bufnr buf-name)]
    (if (= -1 buf)
      (let [buf (nvim.fn.bufadd buf-name)]
        (nvim.buf_set_option buf :buftype :nofile)
        (nvim.buf_set_option buf :bufhidden :hide)
        (nvim.buf_set_option buf :swapfile false)
        (unlist buf)
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
