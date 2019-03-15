(ns conjure.ui
  "Handle displaying and managing what's visible to the user."
  (:require [conjure.nvim :as nvim]
            [conjure.util :as util]))

;; TODO Trim when long
;; TODO Auto close

(def log-window-widths {:small 40 :large 80})
(def max-log-buffer-length 10000)
(defonce log-buffer-name (str "/tmp/conjure-log-" (util/now) ".cljc"))
(def upsert-log-lua "return conjure_utils.upsert_log(...)")

(defn upsert-log
  "Get, create, or update the log window and buffer."
  ([] (upsert-log {}))
  ([{:keys [focus? width] :or {focus? false, width :small}}]
   (->> (nvim/execute-lua
          upsert-log-lua
          log-buffer-name
          (get log-window-widths width)
          focus?)
        (nvim/call)
        (util/snake->kw-map))))

(defn error [parts]
  (let [lines (for [line (util/lines parts)]
                (str ";conjure/err " line))
        {:keys [buf win]} (upsert-log)
        line-count (nvim/call (nvim/buf-line-count buf))
        new-line-count (+ line-count (count lines))]

    (nvim/call-batch
      [(when (= line-count 1)
         (nvim/buf-set-lines buf
                             {:start 0, :end 1}
                             [";conjure/out Welcome to Conjure!"]))
       (nvim/buf-set-lines buf {:start -1, :end -1} lines)
       (nvim/win-set-cursor win {:col 0, :row new-line-count})])))

(comment
  (time (error "Henlo, World!\nConjure is magic.")))
