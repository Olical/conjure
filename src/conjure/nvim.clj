(ns conjure.nvim
  "Tools to interact with Neovim at a higher level than RPC."
  (:require [conjure.rpc :as rpc]))

;; TODO Handle batch calls
;; TODO Handle errors nicely (do I throw?)
(defn call
  "Simply a thin nvim specific wrapper around rpc/request."
  [req]
  (let [{:keys [error result]} (rpc/request req)]
    result))

(defn get-current-buf []
  {:method :nvim-get-current-buf})

(comment
  (call (get-current-buf)))
