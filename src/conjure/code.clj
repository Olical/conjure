(ns conjure.code
  "Tools to render or format Clojure code."
  (:require [zprint.core :as zp]
            [taoensso.timbre :as log]))

(defn zprint [src]
  (try
    (zp/zprint-str src {:parse-string-all? true})
    (catch Exception e
      (log/error "Error while zprinting" e)
      src)))
