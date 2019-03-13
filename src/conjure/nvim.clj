(ns conjure.nvim
  "Tools to interact with Neovim at a higher level than RPC."
  (:require [taoensso.timbre :as log]
            [conjure.rpc :as rpc]))

;; TODO Handle batch calls
(defn call
  "Simply a thin nvim specific wrapper around rpc/request."
  [req]
  (let [{:keys [error result] :as resp} (rpc/request req)]
    (when error
      (log/error "Error while making nvim call" req "->" resp))
    result))

(defn get-current-buf []
  {:method :nvim-get-current-buf})

(comment
  (call (get-current-buf)))
