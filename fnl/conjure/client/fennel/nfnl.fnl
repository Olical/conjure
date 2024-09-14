(local {: autoload} (require :nfnl.module))
(local ts (autoload :conjure.tree-sitter))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))
(local log (autoload :conjure.log))
(local core (autoload :nfnl.core))
(local fennel (autoload :nfnl.fennel))
(local str (autoload :nfnl.string))
(local repl (autoload :nfnl.repl))

(local comment-node? ts.lisp-comment-node?)

(fn form-node? [node]
  (ts.node-surrounded-by-form-pair-chars? node [["#(" ")"]]))

(local buf-suffix ".fnl")
(local comment-prefix "; ")

(config.merge
  {:client
   {:fennel
    {:nfnl
     {}}}})

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
   {:client
    {:fennel
     {:nfnl
      {:mapping {}}}}}))

(local cfg (config.get-in-fn [:client :fennel :nfnl]))

(fn eval-str [opts]
  (let [eval (repl.new)
        results (eval opts.code)
        result-strs (core.map fennel.view results)
        lines (text.split-lines (str.join "\n" result-strs))]
    (log.append lines)))

(comment
  (+ 10 20))

{: comment-node?
 : form-node?
 : buf-suffix
 : comment-prefix
 : eval-str}
