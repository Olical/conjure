(ns conjure.main
  (:require [clojure.core.async :as a]
            [taoensso.timbre :as log]
            [conjure.dev :as dev]
            [conjure.rpc :as rpc]))

(defn -main []
  (dev/init!)
  (rpc/init!)

  (log/info "Everything's up and running")

  (let [fry (a/chan)]
    ;; https://www.youtube.com/watch?v=6UHlXLmsDGA
    ;;      __
    ;; (___()'`;
    ;; /,    /`
    ;; \\"--\\
    (a/<!! fry)))
