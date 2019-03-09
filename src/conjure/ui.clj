(ns conjure.ui
  "Handle displaying and managing what's visible to the user."
  (:require [taoensso.timbre :as log]
            [conjure.util :as util]))

;; TODO When we have a log buffer, log to that
(defn error [& parts]
  (let [msg (util/sentence parts)]
    (doseq [line (util/lines msg)]
      (log/error line))))
