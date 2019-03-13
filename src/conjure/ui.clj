(ns conjure.ui
  "Handle displaying and managing what's visible to the user."
  (:require [taoensso.timbre :as log]
            [conjure.nvim :as nvim]
            [conjure.util :as util]))

;; TODO Render this in the log window
(defn error [& parts]
  (let [msg (util/sentence parts)]
    (doseq [line (util/lines msg)]
      (log/error line))))

(defn- upsert-log
  "Get or create the log window and buffer."
  []
  (let [bufs (nvim/call (nvim/list-bufs))
        names (nvim/call-batch (map nvim/buf-get-name bufs))]
    names))
