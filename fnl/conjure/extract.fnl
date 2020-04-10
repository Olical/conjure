(module conjure.extract
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            nu conjure.aniseed.nvim.util
            str conjure.aniseed.string
            config conjure.config
            lang conjure.lang}})

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
    (if (= :number
           (type
             (and (> stack-size 0)
                  (let [name (nvim.fn.synIDattr (. stack stack-size) :name)]
                    (or (name:find "Comment$")
                        (name:find "String$")
                        (name:find "Regexp$"))))))
      1
      0)))

(defn form [{: root?}]
  (let [;; 'W' don't Wrap around the end of the file
        ;; 'n' do Not move the cursor
        ;; 'z' start searching at the cursor column instead of Zero
        ;; 'b' search Backward instead of forward
        ;; 'c' accept a match at the Cursor position
        ;; 'r' repeat until no more matches found; will find the outer pair
        flags (.. "Wnz" (if root? "r" ""))
        cursor-char (current-char)

        skip-match?-viml "luaeval(\"require('conjure.extract')['skip-match?']()\")"

        start (nvim.fn.searchpairpos
                "(" "" ")"
                (.. flags "b" (if (= cursor-char "(") "c" ""))
                skip-match?-viml)
        end (nvim.fn.searchpairpos
              "(" "" ")"
              (.. flags (if (= cursor-char ")") "c" ""))
              skip-match?-viml)]

    (when (and (not (nil-pos? start))
               (not (nil-pos? end)))
      {:range {:start (a.update start 2 a.dec)
               :end (a.update end 2 a.dec)}
       :content (read-range start end)})))

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
  (let [header (->> (nvim.buf_get_lines
                      0 0 config.extract.context-header-lines false)
                    (str.join "\n"))]
    (string.match header (lang.get :context-pattern))))

(defn prompt [prefix]
  (nvim.fn.input (or prefix "")))

(defn prompt-char []
  (nvim.fn.nr2char (nvim.fn.getchar)))
