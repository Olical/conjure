(ns conjure.main
  (:require [cljs.nodejs :as nodejs]
            [applied-science.js-interop :as j]
            [conjure.nvim :as nvim]))

(nodejs/enable-util-print!)

(defn -main []
  (j/assoc! js/module :exports nvim/setup!))

(set! *main-cli-fn* -main)
