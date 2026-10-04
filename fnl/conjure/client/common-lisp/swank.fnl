(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local extract (autoload :conjure.extract))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local remote (autoload :conjure.remote.swank))
(local str (autoload :conjure.nfnl.string))
(local text (autoload :conjure.text))
(local ts (autoload :conjure.tree-sitter))
(local cmpl (autoload :conjure.client.common-lisp.completions))
(local util (autoload :conjure.util))

(local M (define :conjure.client.common-lisp.swank))

(set M.buf-suffix ".lisp")
(set M.comment-prefix "; ")
(set M.form-node? ts.node-surrounded-by-form-pair-chars?)

(fn iterate-backwards [f lines]
  (for [i (length lines) 1 (- 1)] (local line (. lines i))
    (let [res (f line)]
      (when res
        (lua "return res"))))
  nil)

(fn M.context [_code]
  (let [[line _col] (vim.api.nvim_win_get_cursor 0)
        lines (vim.api.nvim_buf_get_lines 0 0 line false)]
    (iterate-backwards
      (fn [line]
        (or (string.match line "%(%s*defpackage%s+(.-)[%s){]")
            (string.match line "%(%s*in%-package%s+(.-)[%s){]")))
      lines)))

;; ------------ common lisp client
;; Can parse simple forms
;; and return the result.
;; will also display the stdout
;; in the log, when present.

(config.merge
  {:client
   {:common_lisp
    {:swank
     {:connection {:default_host "127.0.0.1"
                   :default_port "4005"}
      :enable_completions true}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
   {:client
    {:common_lisp
     {:swank
      {:mapping {:connect "cc"
                 :disconnect "cd"
                 :invoke_restart "dr"
                 :sticker_toggle "ss"
                 :sticker_list "sl"
                 :sticker_clear "sc"
                 :hyperspec "hs"
                 :macroexpand_1 "m1"
                 :macroexpand_all "ma"
                 :trace "tt"
                 :untrace_all "ta"}}}}}))

(local state (client.new-state
                  #(do
                     {:conn nil
                      :eval-id 0})))

(fn completions-enabled? []
  (config.get-in [:client :common_lisp :swank :enable_completions]))

(fn with-conn-or-warn [f opts]
  (let [conn (state :conn)]
    (if conn
      (f conn)
      (log.append "; No connection"))))

(fn connected? []
  (if (state :conn)
    true
    false))

(fn display-conn-status [status]
  (with-conn-or-warn
    (fn [conn]
      (log.append
        [(.. "; " conn.host ":" conn.port " (" status ")")]
        {:break? true}))))

(fn M.disconnect []
  (with-conn-or-warn
    (fn [conn]
      (conn.destroy)
      (display-conn-status :disconnected)
      (core.assoc (state) :conn nil))))

(fn escape-string [in]
  "puts leading slashes infront of \\ and \"
  so that swank can correctly interpret the results."
  (fn replace [in pat rep]
    (let [(s c) (string.gsub in pat rep)] s))
  (-> in
      (replace "\\" "\\\\")
      (replace "\"" "\\\"")))

(fn send-rex [form context thread cb]
  "Send an :emacs-rex request for form. The trailing eval-id marries the
  :return that swank sends back to cb, asynchronously."
  (with-conn-or-warn
    (fn [conn]
      (let [eval-id (core.get (core.update (state) :eval-id core.inc) :eval-id)]
        (remote.send
          conn
          (str.join
            ["(:emacs-rex " form " \"" (or context "*package*") "\" " thread " " eval-id ")"])
          cb)))))

(fn send [msg context cb]
  (log.dbg (.. "swank.send called with msg: " (core.pr-str msg) ", context: " (core.pr-str context)))
  (send-rex
    (.. "(swank:eval-and-grab-output \"" (escape-string msg) "\")")
    context "t" cb))

(fn M.connect [opts]
  (log.dbg (.. "connect called with: " (core.pr-str opts)))
  (let [opts (or opts {})
        host (or opts.host (config.get-in [:client :common_lisp :swank :connection :default_host]))
        port (or opts.port (config.get-in [:client :common_lisp :swank :connection :default_port]))]

    (when (state :conn)
      (M.disconnect))

    (core.assoc
      (state) :conn
      (remote.connect
        {:host host
         :port port

         :on-failure
         (fn [err]
           (display-conn-status err)
           (M.disconnect))

         :on-success
         (fn []
           (display-conn-status :connected))

         :on-error
         (fn [err]
           (if err
             (display-conn-status err)
             (M.disconnect)))

         :on-event #(M.handle-event $1)}))

    (send ":ok" (fn [_]))))

(fn try-ensure-conn []
  (when (not (connected?))
    (M.connect {:silent? true})))

(fn string-stream [str]
  "Convert a string into a byte-value iterator"
  (var index 1)
  (fn []
    (let [r (str:byte index)]
      (set index (+ index 1))
      r)))

(fn display-stdout [msg]
  (when (and (not= nil msg) (not= "" msg))
    (log.append (text.prefixed-lines msg M.comment-prefix))))


(fn inner-results [received]
  "A string of '(:return (:ok (blah)) 1)' should just give us the blah"
  ;; this is super hacky, but it seems to work, so we're going with it
  ;; until something better comes along.
  (local search-string "(:return (:ok (")
  (local tail-size 5) ;; TODO: once we fix up the increments, this will change
  (let [(idx len) (string.find received search-string 1 true)]
    (string.sub received
                (+ idx len)
                (- (string.len received) tail-size))))

(fn parse-separated-list [string-to-parse]
  "Take a string of quoted components and return an array of those values,
  ie: (I'm using single instead of double quotes in the example for ease)

  'this is' not the 'the\' output'
  => ['this is' 'the\' output'] (length of 2)

  We must be able to correctly deal with escaped values.
  This is the form that SWANK gives us, along the lines of:
      (:return (:ok ('stdout-things' 'results-of-eval')) 1)
  "
  ;; (parse-separated-list " \"hello\" to the \"\\\"world\\\"\" ")
  ;; expected value [ "hello" "\"world\""]

  (var opened-quote nil)
  (var escaped false)
  (var stack [])
  (var vals [])

  (local slash-byte (string.byte "\\"))
  (local quote-byte (string.byte "\""))

  (fn maybe-insert [b]
    "insert the value, and reset the escape flag"
    (when opened-quote
      (table.insert stack b)
      (set escaped false)))

  (fn maybe-close [b]
    "When we reach a quote, we could be starting/stopping
    a value, or we could have escaped this byte, etc"
    (if opened-quote
      (do
        (when (not escaped)
          ; move the entire stack into vals and clear
          (set opened-quote false)
          (table.insert
            vals
            (str.join (core.map string.char stack)))
          (set stack []))
        (when escaped
          ;; if we've escaped this quote, put it in.
          (maybe-insert b)))
      (do
        (when escaped
          (log.dbg "Received an escaped quote outside of expected values"))
        (set opened-quote true))))

  (fn slash-escape [b]
    "process a \\ value, which could be escaped or escaping something else"
    (if escaped
      (maybe-insert b)
      (set escaped true)))

  (fn dispatch [b]
    "process each byte that comes in"
    (match b
      slash-byte (slash-escape b)
      quote-byte (maybe-close b)
      _ (maybe-insert b)))

  (each [b (string-stream string-to-parse)]
    (dispatch b))
  ;;finally return vals
  vals)

(fn M.parse-result [received]
  "Given the form (:return (:ok (\"\" \"(1 2 \\\"3\\\" 4)\")) 1) we want)])
  to extract both
  - the stdout, which is the first delimited quoted component
  - the result, which is the second delimited quoted component

  If there has been an error, it will not look like a result, so more parsing
  will be needed"
  (fn result? [response]
    (text.starts-with response "(:return (:ok ("))

  ;; TODO - parse debug messages properly and show them in a nice way
  ;; I'm not sure what the proper conjure way is here.
  (when (not (result? received))
    ;;super hack; taking out the first quoted component and hoping it is
    ;; a nice message.
    (let [(msg) (pick-values 1 (parse-separated-list received))]
      (display-stdout (. msg 1))))

  (when (result? received)
    (unpack (parse-separated-list (inner-results received)))))

;; ------------ stickers
;; A sticker marks a form with an extmark. When an evaluation contains the
;; form, the form is wrapped so that every pass pushes its values onto the
;; plist of a keyword in the Lisp image. The latest values show as virtual
;; text and <localleader>sl lists every pass.

(local sticker-ns (vim.api.nvim_create_namespace "conjure-common-lisp-stickers"))

(fn sticker-key [id]
  (.. ":conjure-sticker-" (vim.fn.getpid) "-" id))

(fn stickers [buf]
  "[{:id :row :col :end-row :end-col}] for every sticker in buf."
  (core.map
    (fn [[id row col details]]
      {:id id :row row :col col :end-row details.end_row :end-col details.end_col})
    (vim.api.nvim_buf_get_extmarks buf sticker-ns 0 -1 {:details true})))

(fn set-sticker [buf s label]
  (vim.api.nvim_buf_set_extmark
    buf sticker-ns s.row s.col
    {:id s.id
     :end_row s.end-row
     :end_col s.end-col
     :hl_group :Underlined
     :virt_text [[label :Comment]]
     :virt_text_pos :eol}))

(fn M.instrument-stickers [buf code range]
  "Wrap each sticker inside the evaluated range so it records its values.
  code must be the buffer text that starts at range.start."
  (let [lines (vim.api.nvim_buf_get_lines buf 0 -1 false)
        offset (fn [row col]
                 (var o col)
                 (for [r 1 row]
                   (set o (+ o (length (. lines r)) 1)))
                 o)
        base (offset (- (core.get-in range [:start 1]) 1) (core.get-in range [:start 2]))
        found (core.filter
                (fn [s]
                  (and (>= s.start 0)
                       (<= s.end (length code))
                       (= (string.sub code (+ s.start 1) s.end)
                          (table.concat
                            (vim.api.nvim_buf_get_text buf s.row s.col s.end-row s.end-col {})
                            "\n"))))
                (core.map
                  (fn [s]
                    (core.assoc s
                                :start (- (offset s.row s.col) base)
                                :end (- (offset s.end-row s.end-col) base)))
                  (stickers buf)))]
    ;; Splice from the last start backwards. Wrapping a nested sticker grows
    ;; every sticker that encloses it.
    (table.sort found #(> $1.start $2.start))
    (var out code)
    (each [i s (ipairs found)]
      (let [label (+ 7000000 s.id)
            pre (.. "(let ((#" label "=#:v (multiple-value-list ")
            post (.. "))) (push #" label "# (get " (sticker-key s.id) " :values)) (values-list #" label "#))")]
        (set out (.. (string.sub out 1 s.start) pre
                      (string.sub out (+ s.start 1) s.end) post
                      (string.sub out (+ s.end 1))))
        (for [j (+ i 1) (length found)]
          (let [outer (. found j)]
            (when (>= outer.end s.end)
              (set outer.end (+ outer.end (length pre) (length post))))))))
    out))

(fn sticker-values-code [buf all?]
  "Lisp code that returns a list of \"id count values\" strings, one per
  sticker: the latest pass, or every pass when all? is true."
  (.. "(list "
      (table.concat
        (core.map
          (fn [s]
            (.. "(let ((v (reverse (get " (sticker-key s.id) " :values))))"
                " (format nil \"~D ~D ~A\" " s.id " (length v)"
                (if all?
                  " (format nil \"~{~{~S~^ ~}~^ | ~}\" v)"
                  " (format nil \"~{~S~^ ~}\" (car (last v)))")
                "))"))
          (stickers buf))
        " ")
      ")"))

(fn each-sticker-result [result f]
  (each [_ entry (ipairs (parse-separated-list result))]
    (let [(id n vals) (string.match entry "^(%d+) (%d+) ?(.*)$")]
      (when id
        (f (tonumber id) (tonumber n) vals)))))

(fn M.refresh-stickers [buf]
  "Show the latest recorded values of each sticker as virtual text."
  (when (not (core.empty? (stickers buf)))
    (M.eval-str
      {:origin :custom
       :passive? true
       :code (sticker-values-code buf false)
       :on-result
       (fn [result]
         (let [by-id (core.reduce (fn [acc s] (core.assoc acc s.id s)) {} (stickers buf))]
           (each-sticker-result
             result
             (fn [id n vals]
               (let [s (. by-id id)]
                 (when s
                   (set-sticker buf s (if (= 0 n)
                                        "=> (no value yet)"
                                        (.. "=> " vals " (" n "x)")))))))))})))

(fn M.toggle-sticker []
  "Place a sticker on the form under the cursor, or remove the one there."
  (let [form (extract.form {})
        buf (vim.api.nvim_get_current_buf)]
    (when form
      (let [row (- (core.get-in form [:range :start 1]) 1)
            col (core.get-in form [:range :start 2])
            here (core.filter #(and (= row $1.row) (= col $1.col)) (stickers buf))]
        (if (core.empty? here)
          (let [lines (text.split-lines form.content)
                end-row (+ row (length lines) -1)
                end-col (+ (if (= 1 (length lines)) col 0) (length (core.last lines)))]
            (vim.api.nvim_buf_set_extmark
              buf sticker-ns row col
              {:end_row end-row
               :end_col end-col
               :hl_group :Underlined
               :virt_text [["=> (no value yet)" :Comment]]
               :virt_text_pos :eol}))
          (vim.api.nvim_buf_del_extmark buf sticker-ns (. here 1 :id)))))))

(fn M.clear-stickers []
  (vim.api.nvim_buf_clear_namespace 0 sticker-ns 0 -1))

(fn M.list-stickers []
  "Log every recorded pass of each sticker in the current buffer."
  (let [buf (vim.api.nvim_get_current_buf)
        by-id (core.reduce (fn [acc s] (core.assoc acc s.id s)) {} (stickers buf))]
    (if (core.empty? by-id)
      (log.append ["; No stickers in this buffer"])
      (M.eval-str
        {:origin :custom
         :passive? true
         :code (sticker-values-code buf true)
         :on-result
         (fn [result]
           (let [lines ["; Stickers"]]
             (each-sticker-result
               result
               (fn [id n vals]
                 (let [s (. by-id id)]
                   (when s
                     (table.insert
                       lines
                       (.. "; line " (+ s.row 1) " "
                           (table.concat (vim.api.nvim_buf_get_text buf s.row s.col s.end-row s.end-col {}) " ")))
                     (table.insert lines (.. ";   " n " pass(es): " vals))))))
             (log.append lines {:break? true})))}))))

(fn M.eval-str [opts]
  (log.dbg (.. "eval-str() called with: " (core.pr-str opts)))
  (try-ensure-conn)

  (when (not (core.empty? opts.code))
    (local buf (vim.api.nvim_get_current_buf))
    (local code (if opts.range
                  (M.instrument-stickers buf opts.code opts.range)
                  opts.code))
    (send
      ;; Swank binds *trace-output* to a stream Conjure never reads, so route
      ;; TRACE output into the captured stdout of this evaluation.
      (.. "(let ((*trace-output* *standard-output*)) "
          (if (= :buf opts.origin)
            (.. "(list " code ")")
            code)
          ")")
      (when (not (core.empty? opts.context))
        opts.context)
      (fn [msg] ;; handle results from Swank server
        (let [(stdout result) (M.parse-result msg)]
          (display-stdout stdout)
          (when (not= nil result)
            (when opts.on-result
              (opts.on-result result))

            (when (not opts.passive?) ;; log results when not true
              (log.append (text.split-lines result))
              (M.refresh-stickers buf))))))))

(fn M.doc-str [opts]
  (try-ensure-conn)
  (M.eval-str (core.update opts :code #(.. "(describe '" $1 ")"))))

(fn split-list [s]
  "Top-level elements of the Lisp list printed in s, as strings.
  (split-list \"(:a (b \\\"c d\\\") 1)\") => [\":a\" \"(b \\\"c d\\\")\" \"1\"]"
  (let [items []
        cur []]
    (var depth 0)
    (var in-str? false)
    (var esc? false)
    (fn flush []
      (when (> (length cur) 0)
        (table.insert items (table.concat cur))
        (for [i (length cur) 1 -1] (tset cur i nil))))
    (for [i 1 (length s)]
      (let [c (string.sub s i i)]
        (if
          in-str? (do
                    (table.insert cur c)
                    (if esc? (set esc? false)
                        (= c "\\") (set esc? true)
                        (= c "\"") (set in-str? false)))
          (and (= depth 0) (= c "(")) (set depth 1)
          (and (= depth 1) (= c ")")) (do (flush) (set depth 0))
          (and (= depth 1) (or (= c " ") (= c "\n"))) (flush)
          (> depth 0) (do
                        (table.insert cur c)
                        (if (= c "\"") (set in-str? true)
                            (= c "(") (set depth (+ depth 1))
                            (= c ")") (set depth (- depth 1)))))))
    items))

(fn append-commented [lines s]
  (each [_ line (ipairs (text.prefixed-lines s M.comment-prefix))]
    (table.insert lines line))
  lines)

(fn show-debugger [[thread level condition restarts frames]]
  (core.assoc (state) :debug {:thread thread :level level})
  (let [[msg kind] (parse-separated-list condition)
        rs (parse-separated-list restarts)
        lines (append-commented [] (.. "Debugger level " level ": " msg))]
    (append-commented lines kind)
    (table.insert lines "; Restarts:")
    (for [i 1 (length rs) 2]
      (append-commented
        lines
        (.. " " (math.floor (/ (- i 1) 2)) ": [" (. rs i) "] " (. rs (+ i 1)))))
    (table.insert lines "; Backtrace:")
    (each [i frame (ipairs (parse-separated-list frames))]
      (append-commented lines (.. " " (- i 1) ": " frame)))
    (log.append lines {:break? true})))

(fn M.handle-event [msg]
  "Handle a swank message that is not the :return of a request."
  (let [[kind & args] (split-list msg)]
    (match kind
      ":write-string" (display-stdout (core.first (parse-separated-list (core.first args))))
      ":debug" (show-debugger args)
      ":debug-return" (let [level (tonumber (. args 2))]
                        (core.assoc (state) :debug
                                    (when (> level 1)
                                      {:thread (. args 1) :level (- level 1)}))
                        (log.append [(.. "; Left debugger level " level)]))
      ":ping" (with-conn-or-warn
                #(remote.send $1 (.. "(:emacs-pong " (. args 1) " " (. args 2) ")"))))))

(fn M.invoke-restart [n]
  "Invoke restart number n of the innermost debugger level."
  (let [dbg (state :debug)]
    (if (and dbg n)
      (send-rex
        (.. "(swank:invoke-nth-restart-for-emacs " dbg.level " " n ")")
        nil dbg.thread (fn [_]))
      (log.append ["; Not in the debugger"]))))
(local hyperspec-indexes {})

(fn hyperspec-index [root]
  "Symbol name -> page path table, read once per root from Data/Map_Sym.txt,
  which alternates symbol lines and ../Body/page.htm lines."
  (or (. hyperspec-indexes root)
      (let [file (.. root "/Data/Map_Sym.txt")
            index {}]
        (when (= 1 (vim.fn.filereadable file))
          (let [lines (vim.fn.readfile file)]
            (for [i 1 (- (length lines) 1) 2]
              (tset index (. lines i) (pick-values 1 (string.gsub (. lines (+ i 1)) "^%.%./" ""))))))
        (tset hyperspec-indexes root index)
        index)))

(fn M.hyperspec-file [sym]
  "Path of the local HyperSpec page for sym, or nil."
  (let [root (config.get-in [:client :common_lisp :swank :hyperspec_root])]
    (when (and root (not (core.empty? sym)))
      (let [root (vim.fn.expand root)
            name (string.upper (pick-values 1 (string.gsub sym "^.*:" "")))
            page (. (hyperspec-index root) name)]
        (when page
          (.. root "/" page))))))

(fn M.hyperspec [sym]
  "Open the local HyperSpec page for sym with vim.ui.open."
  (local root (config.get-in [:client :common_lisp :swank :hyperspec_root]))
  (if
    (not root)
    (log.append ["; Set g:conjure#client#common_lisp#swank#hyperspec_root to use the HyperSpec"])

    (core.empty? (hyperspec-index (vim.fn.expand root)))
    (log.append [(.. "; No Data/Map_Sym.txt under " root)])

    (let [file (M.hyperspec-file sym)]
      (if file
        (do
          (log.append [(.. "; " file)])
          (vim.ui.open file))
        (log.append [(.. "; No HyperSpec entry for " (tostring sym))])))))
(fn unquote-lisp-string [s]
  "Turn a printed Lisp string such as \"(IF A\\n B)\" back into its contents."
  (-> (string.sub s 2 -2)
      (string.gsub "\\(.)" "%1")))

(fn M.macroexpand [swank-fn]
  "Expand the form under the cursor with swank-fn (e.g. swank-macroexpand-1)
  and append the expansion to the log."
  (let [form (extract.form {})]
    (when form
      (M.eval-str
        {:origin :custom
         :passive? true
         :context (M.context)
         :code (.. "(swank:" swank-fn " \"" (escape-string form.content) "\")")
         :on-result
         (fn [result]
           (log.append
             (text.split-lines (unquote-lisp-string result))
             {:break? true}))}))))
(fn M.toggle-trace [name]
  "Toggle TRACE on the function called name."
  (when (not (core.empty? name))
    (M.eval-str
      {:origin :custom
       :context (M.context)
       :code (.. "(swank:swank-toggle-trace \"" (escape-string name) "\")")})))

(fn M.untrace-all []
  (M.eval-str
    {:origin :custom
     :code "(swank:untrace-all)"}))

(fn M.eval-file [opts]
  (try-ensure-conn)
  (M.eval-str
    (core.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

(fn M.on-filetype []
  (mapping.buf
    :CommonLispDisconnect
    (config.get-in [:client :common_lisp :swank :mapping :disconnect])
    M.disconnect
    {:desc "Disconnect from the REPL"})

  (mapping.buf
    :CommonLispConnect
    (config.get-in [:client :common_lisp :swank :mapping :connect])
    #(M.connect {})
    {:desc "Connect to a REPL"})

  (mapping.buf
    :CommonLispInvokeRestart
    (config.get-in [:client :common_lisp :swank :mapping :invoke_restart])
    #(M.invoke-restart (tonumber (vim.fn.input "Restart: ")))
    {:desc "Invoke a debugger restart by number"})

  (mapping.buf
    :CommonLispStickerToggle
    (config.get-in [:client :common_lisp :swank :mapping :sticker_toggle])
    M.toggle-sticker
    {:desc "Toggle a sticker on the current form"})

  (mapping.buf
    :CommonLispStickerList
    (config.get-in [:client :common_lisp :swank :mapping :sticker_list])
    M.list-stickers
    {:desc "Log every value recorded by the stickers"})

  (mapping.buf
    :CommonLispStickerClear
    (config.get-in [:client :common_lisp :swank :mapping :sticker_clear])
    M.clear-stickers
    {:desc "Remove all stickers from the buffer"})

  (mapping.buf
    :CommonLispHyperSpec
    (config.get-in [:client :common_lisp :swank :mapping :hyperspec])
    #(M.hyperspec (vim.fn.expand "<cword>"))
    {:desc "Open the local HyperSpec page for the symbol under the cursor"})

  (mapping.buf
    :CommonLispMacroexpand1
    (config.get-in [:client :common_lisp :swank :mapping :macroexpand_1])
    #(M.macroexpand :swank-macroexpand-1)
    {:desc "Macroexpand the current form once"})

  (mapping.buf
    :CommonLispMacroexpandAll
    (config.get-in [:client :common_lisp :swank :mapping :macroexpand_all])
    #(M.macroexpand :swank-macroexpand-all)
    {:desc "Fully macroexpand the current form"})

  (mapping.buf
    :CommonLispTrace
    (config.get-in [:client :common_lisp :swank :mapping :trace])
    #(M.toggle-trace (vim.fn.expand "<cword>"))
    {:desc "Toggle tracing of the function under the cursor"})

  (mapping.buf
    :CommonLispUntraceAll
    (config.get-in [:client :common_lisp :swank :mapping :untrace_all])
    M.untrace-all
    {:desc "Untrace all functions"}))

(fn M.on-load []
  (when (completions-enabled?) 
    (cmpl.get-static-completions)) ; initial scan of tree speeds up later queries
  (M.connect {}))

(fn M.on-exit []
  (M.disconnect))

(fn build-completions-code 
  [prefix context]
  (.. "(swank:simple-completions " (core.pr-str prefix) " " (core.pr-str context) ")"))

(fn format-for-cmpl
  [rs]
  (let [cmpls (parse-separated-list rs)]
    (table.remove cmpls) ; last result is prefix
    cmpls))

;; completions - partially copied from client/fennel/aniseed.fnl.
(fn build-completions [opts]
 (let [prefix (or (. opts :prefix) "")
       static-completions (cmpl.get-static-completions prefix)]
   (if (connected?) 
     (let [code (build-completions-code opts.prefix opts.context)
           result-fn
           (fn [results]
             (let [parsed-results (format-for-cmpl results)
                   all-cmpl (core.concat static-completions parsed-results)
                   cmpl-list (util.ordered-distinct all-cmpl)]
               ;(log.append [(.. "; in completions()'s result-fn, called with: " (core.pr-str results))] )
               ;(log.append [(..  "; in completions()'s result-fn, calling opts.cb with " (core.pr-str cmpl-list))])
               (opts.cb cmpl-list) ; return the list of completions
               ))
           ]
       (core.assoc opts :code code)
       (core.assoc opts :on-result result-fn)
       (core.assoc opts :passive? true)
       (M.eval-str opts))
     (opts.cb static-completions))))

(fn M.completions [opts]
  ;(when (not= nil opts)
  ;  (log.append [(.. "; completions() called with: " (core.pr-str opts))] {:break? true}))
  (if (completions-enabled?)
    (build-completions opts)
    (opts.cb [])))

M
