(ns conjure.nvim
  "Tools to interact with Neovim at a higher level than RPC."
  (:require [taoensso.timbre :as log]
            [conjure.rpc :as rpc]))

(defn call
  "Simply a thin nvim specific wrapper around rpc/request."
  [req]
  (let [{:keys [error result] :as resp} (rpc/request req)]
    (when error
      (log/error "Error while making nvim call" req "->" resp))
    result))

(defn- ->atomic-call [{:keys [method params]}]
  [(rpc/kw->method method) (vec params)])

(defn call-batch [& reqs]
  (let [[results [err-idx err-type err-msg]]
        (call {:method :nvim-call-atomic
               :params [(map ->atomic-call reqs)]})]
    (when err-idx
      (log/error "Error while making atomic batch call"
                 (get reqs err-idx) "->" err-type err-msg))
    results))

(defn get-current-buf []
  {:method :nvim-get-current-buf})

(defn get-current-win []
  {:method :nvim-get-current-win})

(defn win-get-cursor [win]
  {:method :nvim-win-get-cursor
   :params [win]})

(defn win-set-cursor [win pos]
  {:method :nvim-win-set-cursor
   :params [win pos]})

(comment
  (let [win (call (get-current-win))
        [row col] (call (win-get-cursor win))]
    (call (win-set-cursor win [(- row 10) (inc col)]))))
