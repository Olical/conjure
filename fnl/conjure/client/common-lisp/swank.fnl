(module conjure.client.common-lisp.swank
  {autoload {a conjure.aniseed.core
             nvim conjure.aniseed.nvim
             bridge conjure.bridge
             mapping conjure.mapping
             text conjure.text
             log conjure.log
             config conjure.config
             client conjure.client
             remote conjure.remote.swank}})

(def buf-suffix ".lisp")
(def comment-prefix "; ")

(config.merge
  {:client
   {:common-lisp
    {:swank
     {:connection {:default_host "127.0.0.1"
                   :default_port "4005"}
      :mapping {:connect "cc"
                :disconnect "cd"}}}}})

(defonce- state (client.new-state #(do {:conn nil})))

(defn- with-conn-or-warn [f opts]
  (let [conn (state :conn)]
    (if conn
      (f conn)
      (log.append ("; No connection")))))

(defn- connected? []
  (if (state :conn)
    true
    false))

(defn- display-conn-status [status]
  (with-conn-or-warn
    (fn [conn]
      (log.append
        [(.. "; " conn.host ":" conn.port " (" status ")")]
        {:break? true}))))

(defn disconnect []
  (with-conn-or-warn
    (fn [conn]
      (conn.destroy)
      (display-conn-status :disconnected)
      (a.assoc (state) :conn nil))))

(defn- escape-string [in]
  "puts leading slashes infront of \\ and \"
  so that swank can correctly interpret the results."
  (fn replace [in pat rep]
    (let [(s c) (string.gsub in pat rep)] s))
  (-> in
      (replace "\\" "\\\\")
      (replace "\"" "\\\"")))

(defn- send [msg cb]
  (with-conn-or-warn
    (fn [conn]
      ;; TODO: the '1' at the end is indicating the expression given
      ;; and should be incremented at each call
      ;; this is so the results that return can be married up to the
      ;; expression that is sent, asynchronously.
      (remote.send conn
                   (.. "(:emacs-rex (swank:eval-and-grab-output \"" 
                       (escape-string msg)
                       "\") \"cl-user\" t 1)")
                   cb))))

(defn connect [opts]
  (let [opts (or opts {})
        host (or opts.host (config.get-in [:client :common-lisp :swank :connection :default_host]))
        port (or opts.port (config.get-in [:client :common-lisp :swank :connection :default_port]))]

    (when (state :conn)
      (disconnect))

    (a.assoc
      (state) :conn
      (remote.connect
        {:host host
         :port port

         :on-failure
         (fn [err]
           (display-conn-status err)
           (disconnect))

         :on-success
         (fn []
           (display-conn-status :connected))

         :on-error
         (fn [err]
           (if err
             (display-conn-status err)
             (disconnect)))}))))

(defn- try-ensure-conn []
  (when (not (connected?))
    (connect {:silent? true})))

(defn eval-str [opts]
  (try-ensure-conn)
  (send
    opts.code
    (fn [msg]
      (log.append ["callback result " msg]))))
      ; (let [clean (text.trim-last-newline msg)]
      ;   (when opts.on-result
      ;     ;; ANSI escape trimming happens here AND in log append (if enabled)
      ;     ;; so the "eval and replace form" won't end up inserting ANSI codes.
      ;     (opts.on-result (text.strip-ansi-escape-sequences clean)))
      ;   (when (not opts.passive?)
      ;     (log.append (text.split-lines clean)))))))

; Needs to be adjusted
; (defn doc-str [opts]
;   (try-ensure-conn)
;   (eval-str (a.update opts :code #(.. "(doc " $1 ")"))))

; (defn eval-file [opts]
;   (try-ensure-conn)
;   (eval-str
;     (a.assoc opts :code (.. "(do (dofile \"" opts.file-path
;                             "\" :env (fiber/getenv (fiber/current))) nil)"))))

(defn on-filetype []
  (mapping.buf :n :CommonLispDisconnect
               (config.get-in [:client :common-lisp :swank :mapping :disconnect])
               :conjure.client.common-lisp :disconnect)
  (mapping.buf :n :CommonLispConnect
               (config.get-in [:client :common-lisp :swank :mapping :connect])
               :conjure.client.common-lisp :connect))

(defn on-load []
  (connect {}))

(defn on-exit []
  (disconnect))
