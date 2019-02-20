(ns conjure.main
  (:require [goog.object :as go]
            [conjure.nvim :as nvim]))

(defn -main []
  (go/set js/module "exports" nvim/setup!))

(set! *main-cli-fn* -main)
