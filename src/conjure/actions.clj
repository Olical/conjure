(ns conjure.actions
  "Things the user can do that probably trigger some sort of UI update."
  (:require [taoensso.timbre :as log]
            [conjure.pool :as pool]))

(defn evaluate [code]
  (log/info "TODO Would evaluate" code))
