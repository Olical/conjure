(local {: autoload : define} (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local text (autoload :conjure.text))

(local M (define :conjure.client.javascript.stdio {}))

(config.merge {:client 
               {:javascript 
                {:stdio 
                 {:command "node --experimental-repl-await -i"
                  :prompt-pattern "> "}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge 
    {:client 
     {:javascript 
      {:stdio 
       {:mapping {:start :cs
                  :stop :cS
                  :restart :cr
                  :interrupt :ei}}}}}))

(local cfg (config.get-in-fn [:client :javascript :stdio]))
(local state (client.new-state #(do {:repl nil})))
(set M.buf-suffix ".js")
(set M.comment-prefix "// ")

(fn M.form-node? [node]
  (or (= :function_declaration (node:type)) (= :export_statement (node:type))
      (= :try_statement (node:type)) (= :expression_statement (node:type))
      (= :import_statement (node:type)) (= :class_declaration (node:type))
      (= :lexical_declaration (node:type)) (= :for_statement (node:type))))

(fn with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
        (f repl)
        (log.append [(.. M.comment-prefix "No REPL running")
                     (.. M.comment-prefix "Start REPL with "
                         (config.get-in [:mapping :prefix])
                         (cfg [:mapping :start]))]))))

(fn display-result [msg]
  (log.append msg))

(fn replace-require-path [s cwd]
  (if (string.find s :require)
      (string.gsub s "require%(\"(.-)\"%)"
                   (fn [m]
                     (if (text.starts-with m "./")
                         (.. "require(\"" cwd (m:sub 2) "\")")
                         (.. "require(\"" m "\")"))))
      s))

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
  (if (text.starts-with s :import)
      (let [initial-acc {:applied? false :result s}
            final-acc (a.reduce 
                        (fn [acc [pat repl]]
                          (if acc.applied?
                              acc
                              (let [(r c) (string.gsub acc.result pat repl)]
                                (if (> c 0)
                                    {:applied? true :result r}
                                    acc))))
                                initial-acc patterns-replacements)]
        final-acc.result)
      s))

(fn is-arrow-fn? [s]
  (if (not= :string (type s)) false)
  (let [ts (s:match "^%s*(.-)%s*$")
        expr (or (ts:match "=%s*(.*)") ts)
        parens "^%s*%b()%s*=>"
        ident "^%s*[%a_$][%w_$]*%s*=>"]
    (if (not (or (ts:find "=> ") (ts:find "%f[%w]function%f[%W]"))) false
        (expr:match parens) true
        (expr:match ident) true
        false)))

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
  (.. 
    (->> (str.split (replace-arrows s) "\n")
         (a.filter #(not= "" $1))
         (a.map #(-> $1
                     str.trim 
                     replace-imports
                     (replace-require-path (vim.uv.fs_realpath (vim.fn.expand "%:p:h")))))
         (str.join "\n")) "\n"))

(fn replace-dots [s with]
  (let [(s _count) (string.gsub s "%.%.%.%s?" with)] s))

(fn M.format-msg [msg]
  (->> (str.split msg "\n")
       (a.filter #(not= "" $1))
       (a.map #(replace-dots $1 ""))))

(fn sanitize-msg [msg field]
  (->> (str.split (a.get msg field) "\n")
       (a.map #(replace-dots $1 ""))
       (a.filter (partial (not str.blank?)))
       (a.map #(.. "(" field ") " $1 "\n"))
       (str.join "")))

(fn prepare-out [msg]
  (if (a.get msg :out) 
      (sanitize-msg msg :out)

      (a.get msg :err)
      (sanitize-msg msg :err)))

(fn M.unbatch [msgs]
  (->> msgs
       (a.map prepare-out)
       (str.join "")))

(fn M.eval-str [opts]
  (with-repl-or-warn 
    (fn [repl]
      (repl.send (prep-code opts.code)
                 (fn [msgs]
                   (let [msgs (-> msgs M.unbatch M.format-msg)]
                     (display-result msgs)
                     (when opts.on-result
                       (opts.on-result (str.join " " msgs)))))
                 {:batch? true}))))

(fn M.eval-file [opts]
  (M.eval-str (a.assoc opts :code (a.slurp opts.file-path))))

(fn display-repl-status [status]
  (let [repl (state :repl)]
    (when repl
      (log.append
        [(.. M.comment-prefix (a.pr-str (a.get-in repl [:opts :cmd]))
             " (" status ")")] {:break? true}))))

(fn M.stop []
  (let [repl (state :repl)]
    (when repl
      (repl.destroy)
      (display-repl-status :stopped)
      (a.assoc (state) :repl nil))))

(set M.initialise-repl-code "")

(fn M.start []
  (if (state :repl)
      (log.append [(.. M.comment-prefix "Can't start, REPL is already running.")
                   (.. M.comment-prefix "Stop the REPL with "
                       (config.get-in [:mapping :prefix])
                       (cfg [:mapping :stop]))]
                  {:break? true})
      (a.assoc 
        (state) :repl
        (stdio.start
          {:prompt-pattern (cfg [:prompt-pattern])
           :cmd (cfg [:command])
           :delay-stderr-ms (cfg [:delay-stderr-ms])

           :on-success 
           (fn []
             (display-repl-status :started)
             (with-repl-or-warn
                 (fn [repl]
                   (repl.send 
                     (prep-code M.initialise-repl-code) 
                     (fn [msgs]
                       (display-result (-> msgs
                                           M.unbatch
                                           M.format-msg)))
                     {:batch true}))))

           :on-error (fn [err]
                       (display-repl-status err))

           :on-exit (fn [code signal]
                      (when (and (= :number (type code)) (> code 0))
                        (log.append
                          [(.. M.comment-prefix
                               "process exited with code "
                               code)]))
                      (when (and (= :number (type signal)) (> signal 0))
                        (log.append 
                          [(.. M.comment-prefix
                               "process exited with signal "
                               signal)]))
                      (M.stop))

           :on-stray-output
           (fn [msg]
             (log.dbg (-> [msg] 
                          M.unbatch
                          M.format-msg)
                      {:join-first? true}))}))))

(fn warning-msg []
  (a.map #(log.append [$1])
         ["// WARNING! Node.js REPL limitations require transformations:"
          "// 1. ES6 'import' statements are converted to 'require(...)' calls."
          "// 2. Arrow functions ('const fn = () => ...') are converted to 'function fn() ...' declarations to allow re-definition."]))

(fn M.on-load []
  (if (config.get-in [:client_on_load])
      (do
        (M.start)
        (warning-msg))
      (log.append ["Not starting repl"])))

(fn M.on-exit [] (M.stop))

(fn M.interrupt []
  (with-repl-or-warn 
    (fn [repl]
      (log.append [(.. M.comment-prefix
                       " Sending interrupt signal.")]
                  {:break? true})
      (repl.send-signal :sigint))))

(fn M.on-filetype []
  (mapping.buf :JavascriptStart 
               (cfg [:mapping :start]) 
               M.start
               {:desc "Start the Javascript REPL"})
  (mapping.buf :JavascriptStop 
               (cfg [:mapping :stop])
               M.stop
               {:desc "Stop the Javascript REPL"})
  (mapping.buf :JavascriptRestart 
               (cfg [:mapping :restart])
               (fn []
                 (M.stop)
                 (M.start))
               {:desc "Restart the Javascript REPL"})
  (mapping.buf :JavascriptInterrupt 
               (cfg [:mapping :interrupt]) 
               M.interrupt
               {:desc "Interrupt the current evaluation"}))

M
