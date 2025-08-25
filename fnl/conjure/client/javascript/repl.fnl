(local {: autoload : define} (require :conjure.nfnl.module))
(local config (autoload :conjure.config))

(local M (define :conjure.client.javascript.repl))

(fn filetype [] vim.bo.filetype)

(fn M.type [] 
  (if (= "javascript" (filetype))
      :js 

      (= "typescript" (filetype))
      :ts))

(fn get-repl-cmd []
  (if (= :js (M.type))
      "node -i"

      (= :ts (M.type))
      "ts-node -i"))

(fn M.update-repl-cmd []
  (config.merge {:client 
                 {:javascript 
                  {:stdio 
                   {:command (get-repl-cmd)}}}}
                {:overwrite? true}))

M
