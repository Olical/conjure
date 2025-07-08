(local {: autoload} (require :conjure.nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local dyn (autoload :conjure.dynamic))
(local text (autoload :conjure.text))

;; INFO: Javascript don't allow to redeclare variables 'let' and 'const', but you 
;; can ommit the problem in Conjure REPL by selecting a variable after 'let' declaration 
;; and pressing <localleader>E

(config.merge {:client {:javascript {:stdio {:command "node --experimental-repl-await -i"
                                             :prompt-pattern "> "
                                             :delay-stderr-ms 10}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge {:client {:javascript {:stdio {:mapping {:start :cs
                                                         :stop :cS
                                                         :restart :cr
                                                         :interrupt :ei}}}}}))

(local cfg (config.get-in-fn [:client :javascript :stdio]))

(local state (client.new-state #(do
                                  {:repl nil})))

(local buf-suffix :.js)
(local comment-prefix "// ")

(fn form-node? [node]
  (or (= :function_declaration (node:type)) (= :export_statement (node:type))
      (= :try_statement (node:type)) (= :expression_statement (node:type))
      (= :lexical_declaration (node:type)) (= :for_statement (node:type))))

(fn is-dots? [s]
  (= (string.sub s 1 3) "..."))

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
        (f repl)
        (log.append [(.. comment-prefix "No REPL running")
                     (.. comment-prefix "Start REPL with "
                         (config.get-in [:mapping :prefix])
                         (cfg [:mapping :start]))]))))

(fn display-result [msg]
  (->> msg
       (a.map #(.. "(out) " $1))
       log.append))

;; INFO: It's not possible to use functions declared as 'const fn = (args) => {}'
;; because you can't redeclare the functions in the Node REPL. 
;; The solution is not to use that form; instead, use a standard 'function' declaration.
;; Also, imports cannot be used in the Node REPL, this is why the import change trick was used.

(local patterns-replacements
       [["^%s*import%s+%{%s*([^}]+)%s+as%s+([^}]+)%s+%}%s+from%s+[\"'](%w+:?%w+)[\"']%s*;?%s?"
         "const {%1:%2} = require(\"%3\");"]
        ["^%s*import%s+([^%s{]+)%s+from%s+([\"'])(.-)%2%s*;?%s?"
         "const %1 = require(\"%3\");"]
        ["^%s*import%s+%*%s+as%s+([^%s]+)%s+from%s+([\"'])(.-)%2%s*;?%s?"
         "const %1 = require(\"%3\");"]
        ["^%s*import%s+%{([^}]+)%}%s+from%s+([\"'])(.-)%2%s*;?%s?"
         "const {%1} = require(\"%3\");"]
        ["^%s*import%s+([^%s{,]+)%s*,%s*%{([^}]+)%}%s+from%s+([\"'])(.-)%3%s*;?%s?"
         "const { default: %1, %2 } = require(\"%4\");"]
        ["^%s*import%s+([\"'])(.-)%1%s*;?%s?" "require(\"%2\");"]])

(fn replace-imports [s]
  (if (not (text.starts-with s :import))
      s
      (let [initial-acc {:applied? false :result s}
            final-acc (a.reduce (fn [acc [pat repl]]
                                  (if acc.applied?
                                      acc
                                      (let [(r c) (string.gsub acc.result pat
                                                               repl)]
                                        (if (> c 0)
                                            {:applied? true :result r}
                                            acc))))
                                initial-acc patterns-replacements)]
        final-acc.result)))

(fn is-arrow-fn? [s]
  (if (not= :string (type s)) false)
  (let [ts (s:match "^%s*(.-)%s*$")
        expr (or (ts:match "=%s*(.*)") ts)
        parens "^%s*%b()%s*=>"
        ident "^%s*[%a_$][%w_$]*%s*=>"]
    (if (not (or (ts:find "=> ") (ts:find "%f[%w]function%f[%W]")))
        false)
    (if (expr:match parens) true)
    (if (expr:match ident) true)
    false))

(fn replace-arrows [s]
  (if (not (is-arrow-fn? s)) s
      (s:gsub "const%s*([%w_]+)%s*=%s*(.-)%((.-)%)%s*=>%s*(.*)"
              (fn [name before-args args body]
                (let [async-kw (if (before-args:find :async) "async " "")
                      final-body (if (body:find "^%s*%{")
                                     (.. " " body)
                                     (.. " { return " body " }"))]
                  (.. async-kw "function " name "(" args ")" final-body))))))

(fn prep-code [s]
  (let [consts (replace-arrows s)
        res (.. (->> (str.split consts "\n")
                     (a.filter #(not= "" $1))
                     (a.map #(-> $1 str.trim replace-imports))
                     (str.join "\n")) "\n")]
    res))

(fn replace-dots [s with]
  (string.gsub s "%.%.%.%s?" with))

(fn format-msg [msg]
  (->> (str.split msg "\n")
       (a.filter #(not= "" $1))
       (a.map #(replace-dots $1 ""))))

(fn get-console-output-msgs [msgs]
  (->> (a.butlast msgs)
       (a.map #(.. comment-prefix "(out) " $1))))

(fn get-expression-result [msgs]
  (let [result (a.last msgs)]
    (if (or (a.nil? result) (is-dots? result))
        nil
        result)))

(fn unbatch [msgs]
  (->> msgs
       (a.map #(or (a.get $1 :out) (a.get $1 :err)))
       (str.join "")))

(fn eval-str [opts]
  (with-repl-or-warn (fn [repl]
                       (repl.send (prep-code opts.code)
                                  (fn [msgs]
                                    (let [msgs (-> msgs unbatch format-msg)]
                                      (display-result msgs)
                                      (when opts.on-result
                                        (opts.on-result (str.join " " msgs)))))
                                  {:batch? true}))))

(fn eval-file [opts]
  (eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(fn display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append [(.. comment-prefix (a.pr-str (a.get-in repl [:opts :cmd]))
                       " (" status ")")] {:break? true}))))

(fn stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(local initialise-repl-code "")

(fn start []
  (if (state :repl)
      (log.append [(.. comment-prefix "Can't start, REPL is already running.")
                   (.. comment-prefix "Stop the REPL with "
                       (config.get-in [:mapping :prefix]) (cfg [:mapping :stop]))]
                  {:break? true})
      (a.assoc (state) :repl
               (stdio.start {:prompt-pattern (cfg [:prompt-pattern])
                             :cmd (cfg [:command])
                             :delay-stderr-ms (cfg [:delay-stderr-ms])
                             :on-success (fn []
                                           (display-repl-status :started
                                                                (with-repl-or-warn (fn [repl]
                                                                                     (repl.send (prep-code initialise-repl-code)
                                                                                                (fn [msgs]
                                                                                                  (display-result (-> msgs
                                                                                                                      unbatch
                                                                                                                      format-msg)))
                                                                                                {:batch true})))))
                             :on-error (fn [err]
                                         (display-repl-status err))
                             :on-exit (fn [code signal]
                                        (when (and (= :number (type code))
                                                   (> code 0))
                                          (log.append [(.. comment-prefix
                                                           "process exited with code "
                                                           code)]))
                                        (when (and (= :number (type signal))
                                                   (> signal 0))
                                          (log.append [(.. comment-prefix
                                                           "process exited with signal "
                                                           signal)]))
                                        (stop))
                             :on-stray-output (fn [msg]
                                                (log.dbg (-> [msg] unbatch
                                                             format-msg)
                                                         {:join-first? true}))}))))

(fn warning-msg []
  (a.map #(log.append [$1])
         ["// WARNING! Node.js REPL limitations require transformations:"
          "// 1. ES6 'import' statements are converted to 'require(...)' calls."
          "// 2. Arrow functions ('const fn = () => ...') are converted to 'function fn() ...' declarations to allow re-definition."]))

(fn on-load []
  (if (config.get-in [:client_on_load])
      (do
        (start)
        (warning-msg))
      (log.append ["Not starting repl"])))

(fn on-exit [] (stop))

(fn interrupt []
  (with-repl-or-warn (fn [repl]
                       (log.append [(.. comment-prefix
                                        " Sending interrupt signal.")]
                                   {:break? true})
                       (repl.send-signal vim.loop.constants.SIGINT))))

(fn on-filetype []
  (mapping.buf :JavascriptStart (cfg [:mapping :start]) start
               {:desc "Start the Javascript REPL"})
  (mapping.buf :JavascriptStop (cfg [:mapping :stop]) stop
               {:desc "Stop the Javascript REPL"})
  (mapping.buf :JavascriptRestart (cfg [:mapping :restart])
               (fn []
                 (stop)
                 (start)) {:desc "Restart the Javascript REPL"})
  (mapping.buf :JavascriptInterrupt (cfg [:mapping :interrupt]) interrupt
               {:desc "Interrupt the current evaluation"}))

{: buf-suffix
 : comment-prefix
 : form-node?
 : format-msg
 : unbatch
 : eval-str
 : eval-file
 : stop
 : initialise-repl-code
 : start
 : on-load
 : on-exit
 : interrupt
 : on-filetype}
