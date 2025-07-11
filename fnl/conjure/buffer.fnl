(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local text (autoload :conjure.text))

(local M (define :conjure.buffer))

(fn M.unlist [buf]
  "The buflisted attribute is reset when a new window is opened. Since the
  buffer upsert is decoupled from the window we have to run this whenever we
  split the buffer into some new window."
  (vim.api.nvim_buf_set_option buf :buflisted false))

(fn M.resolve [buf-name]
  (vim.api.nvim_buf_get_name (vim.fn.bufnr buf-name)))

(fn M.upsert-hidden [buf-name new-buf-fn]
  (let [(ok? buf) (pcall vim.fn.bufnr buf-name)
        loaded? (and ok? (vim.api.nvim_buf_is_loaded buf))]

    ;; This state happens when the user unloads the buffer somehow.
    ;; It still exists but is in a bad state, we delete and start over.
    (when (and (not= -1 buf) (not loaded?))
      (vim.api.nvim_buf_delete buf {}))

    (if (or (= -1 buf) (not loaded?))
      (let [buf (if loaded?
                  buf
                  (let [buf (vim.fn.bufadd buf-name)]
                    (vim.fn.bufload buf)
                    buf))]
        (vim.api.nvim_buf_set_option buf :buftype :nofile)
        (vim.api.nvim_buf_set_option buf :bufhidden :hide)
        (vim.api.nvim_buf_set_option buf :swapfile false)
        (M.unlist buf)
        (when new-buf-fn
          (new-buf-fn buf))
        buf)
      buf)))

(fn M.empty? [buf]
  (and (<= (vim.api.nvim_buf_line_count buf) 1)
       (= 0 (core.count (core.first (vim.api.nvim_buf_get_lines buf 0 -1 false))))))

(fn M.replace-range [buf range s]
  (let [start-line (core.dec (core.get-in range [:start 1]))
        end-line (core.get-in range [:end 1])
        start-char (core.get-in range [:start 2])
        end-char (core.get-in range [:end 2])

        new-lines (text.split-lines s)
        old-lines (vim.api.nvim_buf_get_lines buf start-line end-line false)

        head (string.sub (core.first old-lines) 1 start-char)
        tail (string.sub (core.last old-lines) (+ end-char 2))]

    (core.update
      new-lines 1
      (fn [l] (.. head l)))

    (core.update
      new-lines (core.count new-lines)
      (fn [l] (.. l tail)))

    (vim.api.nvim_buf_set_lines buf start-line end-line false new-lines)))

(fn M.append-prefixed-line [buf [tl tc] prefix body]
  "Appends a string to the end of the current line, or the one below this one
  if there's already the same suffix on the end. If there's already a matching
  suffix on the end of this line and the one below, it will insert another
  below that last one and so on."
  (let [tl (core.dec tl)
        [head-line & lines] (vim.api.nvim_buf_get_lines buf tl -1 false)
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
        (vim.api.nvim_buf_set_lines buf new-tl (core.inc new-tl) false lines))
      (vim.api.nvim_buf_set_lines
        buf tl
        (core.inc tl)
        false
        (if (= 1 (core.count to-append))
          [(.. head-line " " (core.first to-append))]
          (core.concat
            [head-line]
            to-append))))))

M
