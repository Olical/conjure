(module conjure.extract
  {autoload {a conjure.aniseed.core
             nvim conjure.aniseed.nvim
             nu conjure.aniseed.nvim.util
             str conjure.aniseed.string
             config conjure.config
             client conjure.client
             ts conjure.tree-sitter}})

(defn- read-range [[srow scol] [erow ecol]]
  (let [lines (nvim.buf_get_lines
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

(defn- current-char []
  (let [[row col] (nvim.win_get_cursor 0)
        [line] (nvim.buf_get_lines 0 (- row 1) row false)
        char (+ col 1)]
    (string.sub line char char)))

(defn- nil-pos? [pos]
  (or (not pos)
      (= 0 (unpack pos))))

(defn skip-match? []
  (let [[row col] (nvim.win_get_cursor 0)
        stack (nvim.fn.synstack row (a.inc col))
        stack-size (length stack)]
    (if (or
          ;; Are we in a comment, string or regular expression?
          (= :number
             (type
               (and (> stack-size 0)
                    (let [name (nvim.fn.synIDattr (. stack stack-size) :name)]
                      (or (name:find "Comment$")
                          (name:find "String$")
                          (name:find "Regexp%?$"))))))

          ;; Is the character escaped?
          ;; https://github.com/Olical/conjure/issues/209
          (= "\\" (-> (nvim.buf_get_lines
                        (nvim.win_get_buf 0) (- row 1) row false)
                      (a.first)
                      (string.sub col col))))
      1
      0)))

(defn- form* [[start-char end-char escape?] {: root?}]
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

        start (nvim.fn.searchpairpos
                safe-start-char "" safe-end-char
                (.. flags "b" (if (= cursor-char start-char) "c" ""))
                skip-match?)
        end (nvim.fn.searchpairpos
              safe-start-char "" safe-end-char
              (.. flags (if (= cursor-char end-char) "c" ""))
              skip-match?)]

    (when (and (not (nil-pos? start))
               (not (nil-pos? end)))
      {:range {:start [(a.first start) (a.dec (a.second start))]
               :end [(a.first end) (a.dec (a.second end))]}
       :content (read-range start end)})))

(defn- range-distance [range]
  (let [[sl sc] range.start
        [el ec] range.end]
    [(- sl el) (- sc ec)]))

(defn- distance-gt [[al ac] [bl bc]]
  (or (> al bl)
      (and (= al bl) (> ac bc))))

(defn form [opts]
  (if (ts.enabled?)
    (let [node (if opts.root?
                 (ts.get-root)
                 (ts.get-form))]
      (when node
        {:range (ts.range node)
         :content (ts.node->str node)
         :node-type (tostring node)}))
    (do
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
        (a.first forms)))))

(defn word []
  {:content (nvim.fn.expand "<cword>")

   ;; This is wrong but that's okay. I hope.
   :range {:start (nvim.win_get_cursor 0)
           :end (nvim.win_get_cursor 0)}})

(defn file-path []
  (nvim.fn.expand "%:p"))

(defn- buf-last-line-length [buf]
  (a.count (a.first (nvim.buf_get_lines buf (a.dec (nvim.buf_line_count buf)) -1 false))))

(defn range [start end]
  {:content (str.join "\n" (nvim.buf_get_lines 0 start end false))
   :range {:start [(a.inc start) 0]
           :end [end (buf-last-line-length 0)]}})

(defn buf []
  (range 0 -1))

(defn- getpos [expr]
  (let [[_ start end _] (nvim.fn.getpos expr)]
    [start (a.dec end)]))

(defn selection [{:kind kind :visual? visual?}]
  (let [sel-backup nvim.o.selection]
    (nvim.ex.let "g:conjure_selection_reg_backup = @@")
    (set nvim.o.selection :inclusive)

    (if
      visual? (nu.normal (.. "`<" kind "`>y"))
      (= kind :line) (nu.normal "'[V']y")
      (= kind :block) (nu.normal "`[`]y")
      (nu.normal "`[v`]y"))

    (let [content (nvim.eval "@@")]
      (set nvim.o.selection sel-backup)
      (nvim.ex.let "@@ = g:conjure_selection_reg_backup")
      {:content content
       :range {:start (getpos "'<")
               :end (getpos "'>")}})))

(defn context []
  (let [pat (client.get :context-pattern)
        f (if pat
            #(string.match $1 pat)
            (client.get :context))]
    (when f
      (->> (nvim.buf_get_lines
             0 0 (config.get-in [:extract :context_header_lines]) false)
           (str.join "\n")
           (f)))))

(defn prompt [prefix]
  (let [(ok? val) (pcall #(nvim.fn.input (or prefix "")))]
    (when ok?
      val)))

(defn prompt-char []
  (nvim.fn.nr2char (nvim.fn.getchar)))
