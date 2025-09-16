(local {: autoload : define} (require :conjure.nfnl.module))
(local client (autoload :conjure.client))

(local M (define :conjure.client.clojure.nrepl.state))

(set M.get
  (client.new-state
    (fn []
      {:conn nil
       :auto-repl-port nil
       :auto-repl-proc nil
       :join-next {:key nil}})))

M
