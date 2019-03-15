(ns conjure.ui
  "Handle displaying and managing what's visible to the user."
  (:require [taoensso.timbre :as log]
            [camel-snake-kebab.extras :as cske]
            [conjure.nvim :as nvim]
            [conjure.util :as util]))

(def log-window-widths {:small 40 :large 80})
(def max-log-buffer-length 10000)
(defonce log-buffer-name (str "/tmp/conjure-log-" (util/now) ".cljc"))
(def upsert-log-lua "return conjure_utils.upsert_log(...)")

;; TODO Render this in the log window
(defn error [& parts]
  (let [msg (util/sentence parts)]
    (doseq [line (util/lines msg)]
      (log/error line))))

;; TODO Auto close this somehow...
(defn upsert-log
  "Get, create, or update the log window and buffer."
  [{:keys [focus? width] :or {focus? false, width :small}}]
  (->> (nvim/execute-lua
         upsert-log-lua
         log-buffer-name
         (get log-window-widths width)
         focus?)
       (nvim/call)
       (cske/transform-keys util/snake->kw)))
