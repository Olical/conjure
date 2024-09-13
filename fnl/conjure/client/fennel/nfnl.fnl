(local {: autoload} (require :nfnl.module))
(local ts (autoload :conjure.tree-sitter))
(local config (autoload :conjure.config))

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

{: comment-node?
 : form-node?
 : buf-suffix
 : comment-prefix}
