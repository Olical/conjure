(ns conjure.nvim
  "Tools to interact with Neovim at a higher level than RPC."
  (:require [conjure.rpc :as rpc]))

;; TODO Handle batch calls
;; TODO Handle errors nicely (do I throw?)
;; TODO Maybe change how these calls are structured, a map?
(defn call
  "Simply a thin nvim specific wrapper around rpc/request."
  [[method params]]
  (let [{:keys [error result]} (rpc/request method params)]
    result))

(defn get-current-buf []
  [:nvim-get-current-buf []])

(comment
  (call (get-current-buf)))
