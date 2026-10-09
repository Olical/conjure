(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local remote (autoload :conjure.remote.swank))
(local str (autoload :conjure.nfnl.string))
(local text (autoload :conjure.text))
(local ts (autoload :conjure.tree-sitter))
(local cmpl (autoload :conjure.client.common-lisp.completions))

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
                 :invoke_restart "dr"}}}}}))

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

(fn M.eval-str [opts]
  (log.dbg (.. "eval-str() called with: " (core.pr-str opts)))
  (try-ensure-conn)

  (when (not (core.empty? opts.code))
    (send
      (if (= :buf opts.origin)
        (.. "(list " opts.code ")")
        opts.code)
      (when (not (core.empty? opts.context))
        opts.context)
      (fn [msg] ;; handle results from Swank server
        (let [(stdout result) (M.parse-result msg)]
          (display-stdout stdout)
          (when (not= nil result)
            (when opts.on-result
              (opts.on-result result))

            (when (not opts.passive?) ;; log results when not true
              (log.append (text.split-lines result)))))))))

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
    {:desc "Invoke a debugger restart by number"}))

(fn M.on-load []
  (when (completions-enabled?) 
    (cmpl.get-static-completions)) ; initial scan of tree speeds up later queries
  (M.connect {}))

(fn M.on-exit []
  (M.disconnect))

(fn build-completions-code
  [prefix context]
  "SLIME 2.30 and older return (names common-prefix), 2.31 and newer return
  ((name flags qualified-name) ...). Both are flattened to (name flags ...) in
  Lisp so parse-separated-list can read them."
  (.. "(let ((r (swank:simple-completions " (core.pr-str prefix) " " (core.pr-str context) ")))"
      " (loop for e in (if (stringp (second r)) (mapcar #'list (first r)) r)"
      " append (list (first e) (or (second e) \"\"))))"))

;; Flags come from swank's symbol-classification-string, most specific first.
(local kind-by-flag
  [["s" "special-operator"]
   ["m" "macro"]
   ["g" "generic-function"]
   ["a" "accessor"]
   ["f" "function"]
   ["c" "class"]
   ["t" "type"]
   ["b" "variable"]
   ["p" "package"]])

(fn flags->kind [flags]
  (accumulate [kind nil
               _ [flag flag-kind] (ipairs kind-by-flag)
               &until kind]
    (when (string.find flags flag 1 true)
      flag-kind)))

(fn M.parse-completions [result]
  (let [strs (parse-separated-list result)]
    (fcollect [i 1 (length strs) 2]
      (let [word (. strs i)
            kind (flags->kind (or (. strs (+ i 1)) ""))]
        (if kind
          {:word word :kind kind}
          word)))))

(fn completion-word [completion]
  (if (= :string (type completion))
    completion
    completion.word))

(fn merge-completions [static-completions swank-completions]
  (let [swank-by-word (collect [_ c (ipairs swank-completions)]
                        (completion-word c) c)
        seen {}
        merged []]
    (each [_ c (ipairs (core.concat static-completions swank-completions))]
      (let [word (completion-word c)]
        (when (not (. seen word))
          (tset seen word true)
          (table.insert merged (or (. swank-by-word word) c)))))
    merged))

;; completions - partially copied from client/fennel/aniseed.fnl.
(fn build-completions [opts]
 (let [prefix (or (. opts :prefix) "")
       static-completions (cmpl.get-static-completions prefix)]
   (if (connected?) 
     (let [code (build-completions-code opts.prefix opts.context)
           result-fn
           (fn [results]
             (let [cmpl-list (merge-completions
                               static-completions
                               (M.parse-completions results))]
               ;(log.append [(.. "; in completions()'s result-fn, called with: " (core.pr-str results))] )
               ;(log.append [(..  "; in completions()'s result-fn, calling opts.cb with " (core.pr-str cmpl-list))])
               (opts.cb cmpl-list) ; return the list of completions
               ))
           ]
       (core.assoc opts :code code)
       ;; The buffer's package might not use CL, the code above needs it.
       (core.assoc opts :context "COMMON-LISP-USER")
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
