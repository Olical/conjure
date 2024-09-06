(local {: autoload} (require :nfnl.module))
(local client (autoload :conjure.client))

(local get
  (client.new-state
    (fn []
      {:conn nil
       :auto-repl-port nil
       :auto-repl-proc nil
       :join-next {:key nil}})))

{: get}
