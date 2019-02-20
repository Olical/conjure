(ns conjure.main
  (:require [cljs.nodejs :as nodejs]
            [conjure.interop :as in]
            [conjure.nvim :as nvim]))

(nodejs/enable-util-print!)

(defn -main []
  (in/oset js/module :exports nvim/setup!))

(set! *main-cli-fn* -main)
