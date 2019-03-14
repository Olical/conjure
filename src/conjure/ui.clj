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

(defonce log-buffer-name (str "/tmp/conjure-log-" (util/now) ".cljc"))

(defn- upsert-log
  "Get or create the log window and buffer."
  []
  ;; Get tabpage wins
  ;; Get their buffers
  ;; Find the one that matches
  ;; Return both or vspl and setup the window
  (let [bufs (nvim/call (nvim/list-bufs))
        names (nvim/call-batch (map nvim/buf-get-name bufs))
        buf (->> names
                 (keep-indexed
                   (fn [idx name]
                     (when (= name log-buffer-name)
                       (get bufs idx))))
                 (first))]
    {:buf buf
     :win nil}))
