(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))

(local str (autoload :conjure.aniseed.string))
(local config (autoload :conjure.config))

;; All of the code related to the searchpair / searchpairpos based form
;; extraction. If you use Tree Sitter for all of the languages you work
;; with Conjure will avoid loading this module. It's only loaded for
;; files that can't support Tree Sitter for some reason.

(fn nil-pos? [pos]
  (or (not pos)
      (= 0 (unpack pos))))

(fn read-range [[srow scol] [erow ecol]]
  (let [lines (vim.api.nvim_buf_get_lines
                0 (- srow 1) erow false)]
    (-> lines
        (a.update
          (length lines)
          (fn [s]
            (string.sub s 0 ecol)))
        (a.update
          1
          (fn [s]
            (string.sub s scol)))
        (->> (str.join "\n")))))

(fn skip-match? []
  (let [[row col] (vim.api.nvim_win_get_cursor 0)
        stack (vim.fn.synstack row (a.inc col))
        stack-size (length stack)]
    (if (or
          ;; Are we in a comment, string or regular expression?
          (= :number
             (type
               (and (> stack-size 0)
                    (let [name (vim.fn.synIDattr (. stack stack-size) :name)]
                      (or (name:find "Comment$")
                          (name:find "String$")
                          (name:find "Regexp%?$"))))))

          ;; Is the character escaped?
          ;; https://github.com/Olical/conjure/issues/209
          (= "\\" (-> (vim.api.nvim_buf_get_lines
                        (vim.api.nvim_win_get_buf 0) (- row 1) row false)
                      (a.first)
                      (string.sub col col))))
      1
      0)))

(fn current-char []
  (let [[row col] (vim.api.nvim_win_get_cursor 0)
        [line] (vim.api.nvim_buf_get_lines 0 (- row 1) row false)
        char (+ col 1)]
    (string.sub line char char)))

(fn form* [[start-char end-char escape?] {: root?}]
  (let [;; 'W' don't Wrap around the end of the file
        ;; 'n' do Not move the cursor
        ;; 'z' start searching at the cursor column instead of Zero
        ;; 'b' search Backward instead of forward
        ;; 'c' accept a match at the Cursor position
        ;; 'r' repeat until no more matches found; will find the outer pair
        flags (.. "Wnz" (if root? "r" ""))
        cursor-char (current-char)

        safe-start-char
        (if escape?
          (.. "\\" start-char)
          start-char)

        safe-end-char
        (if escape?
          (.. "\\" end-char)
          end-char)

        start (vim.fn.searchpairpos
                safe-start-char "" safe-end-char
                (.. flags "b" (if (= cursor-char start-char) "c" ""))
                skip-match?)
        end (vim.fn.searchpairpos
              safe-start-char "" safe-end-char
              (.. flags (if (= cursor-char end-char) "c" ""))
              skip-match?)]

    (when (and (not (nil-pos? start))
               (not (nil-pos? end)))
      {:range {:start [(a.first start) (a.dec (a.second start))]
               :end [(a.first end) (a.dec (a.second end))]}
       :content (read-range start end)})))

(fn distance-gt [[al ac] [bl bc]]
  (or (> al bl)
      (and (= al bl) (> ac bc))))

(fn range-distance [range]
  (let [[sl sc] range.start
        [el ec] range.end]
    [(- sl el) (- sc ec)]))

(fn form [opts]
  (local forms
    (->> (config.get-in [:extract :form_pairs])
         (a.map #(form* $1 opts))
         (a.filter a.table?)))

  (table.sort
    forms
    #(distance-gt
       (range-distance $1.range)
       (range-distance $2.range)))

  (if opts.root?
    (a.last forms)
    (a.first forms)))

{: skip-match?
 : form}
