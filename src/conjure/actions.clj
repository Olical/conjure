(ns conjure.actions
  "Things the user can do that probably trigger some sort of UI update."
  (:require [taoensso.timbre :as log]))

(defn evaluate [code]
  (log/info "Would evaluate" code))
