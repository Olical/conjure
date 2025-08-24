(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local client (autoload :conjure.client))
(local config (autoload :conjure.config))
(local log (autoload :conjure.log))
(local mapping (autoload :conjure.mapping))
(local remote (autoload :conjure.remote.swank))
(local str (autoload :conjure.aniseed.string))
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
                 :disconnect "cd"}}}}}))

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
      (a.assoc (state) :conn nil))))

(fn escape-string [in]
  "puts leading slashes infront of \\ and \"
  so that swank can correctly interpret the results."
  (fn replace [in pat rep]
    (let [(s c) (string.gsub in pat rep)] s))
  (-> in
      (replace "\\" "\\\\")
      (replace "\"" "\\\"")))

(fn send [msg context cb]
  (log.dbg (.. "swank.send called with msg: " (a.pr-str msg) ", context: " (a.pr-str context)))
  (with-conn-or-warn
    (fn [conn]
      (let [eval-id (a.get (a.update (state) :eval-id a.inc) :eval-id)]
        ;; TODO: the 'eval-id' at the end is indicating the expression given
        ;; this is so the results that return can be married up to the
        ;; expression that is sent, asynchronously.
        (remote.send
          conn
          (str.join
            ["(:emacs-rex (swank:eval-and-grab-output \""
             (escape-string msg)
             "\") \"" (or context "*package*") "\" t " eval-id ")"])
          cb)))))

(fn M.connect [opts]
  (log.dbg (.. "connect called with: " (a.pr-str opts)))
  (let [opts (or opts {})
        host (or opts.host (config.get-in [:client :common_lisp :swank :connection :default_host]))
        port (or opts.port (config.get-in [:client :common_lisp :swank :connection :default_port]))]

    (when (state :conn)
      (M.disconnect))

    (a.assoc
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
             (M.disconnect)))}))

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
            (str.join (a.map string.char stack)))
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
  (log.dbg (.. "eval-str() called with: " (a.pr-str opts)))
  (try-ensure-conn)

  (when (not (a.empty? opts.code))
    (send
      (if (= :buf opts.origin)
        (.. "(list " opts.code ")")
        opts.code)
      (when (not (a.empty? opts.context))
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
  (M.eval-str (a.update opts :code #(.. "(describe '" $1 ")"))))

(fn M.eval-file [opts]
  (try-ensure-conn)
  (M.eval-str
    (a.assoc opts :code (.. "(load \"" opts.file-path "\")"))))

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
    {:desc "Connect to a REPL"}))

(fn M.on-load []
  (when (completions-enabled?) 
    (cmpl.get-static-completions)) ; initial scan of tree speeds up later queries
  (M.connect {}))

(fn M.on-exit []
  (M.disconnect))

(fn build-completions-code 
  [prefix context]
  (.. "(swank:simple-completions " (a.pr-str prefix) " " (a.pr-str context) ")"))

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
                   all-cmpl (a.concat static-completions parsed-results)
                   cmpl-list (util.ordered-distinct all-cmpl)]
               ;(log.append [(.. "; in completions()'s result-fn, called with: " (a.pr-str results))] )
               ;(log.append [(..  "; in completions()'s result-fn, calling opts.cb with " (a.pr-str cmpl-list))])
               (opts.cb cmpl-list) ; return the list of completions
               ))
           ]
       (a.assoc opts :code code)
       (a.assoc opts :on-result result-fn)
       (a.assoc opts :passive? true)
       (M.eval-str opts))
     (opts.cb static-completions))))

(fn M.completions [opts]
  ;(when (not= nil opts)
  ;  (log.append [(.. "; completions() called with: " (a.pr-str opts))] {:break? true}))
  (if (completions-enabled?)
    (build-completions opts)
    (opts.cb [])))

M
