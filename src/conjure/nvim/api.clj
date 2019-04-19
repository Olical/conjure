(ns conjure.nvim.api
  "Tools to interact with Neovim at a higher level than RPC."
  (:require [taoensso.timbre :as log]
            [conjure.rpc :as rpc]
            [conjure.util :as util]))

(defn call
  "Simply a thin nvim specific wrapper around rpc/request."
  [req]
  (let [{:keys [error result] :as resp} (rpc/request req)]
    (when error
      (log/error "Error while making nvim call" req "->" resp))
    result))

(defn- ->atomic-call
  "Transform a regular call into an atomic call param."
  [{:keys [method params] :as req}]
  (when req
    [(util/kw->snake method) (vec params)]))

(defn call-batch
  "Perform multiple calls together atomically."
  [reqs]
  (let [[results [err-idx err-type err-msg]]
        (call {:method :nvim-call-atomic
               :params [(keep ->atomic-call reqs)]})]
    (when err-idx
      (log/error "Error while making atomic batch call"
                 (nth reqs err-idx) "->" err-type err-msg))
    results))

;; These functions return the data that you can pass to call or call-batch.
;; I don't care that it's not DRY, it's easy to understand and special case.

(defn get-current-buf []
  {:method :nvim-get-current-buf})

(defn get-current-win []
  {:method :nvim-get-current-win})

(defn win-get-cursor [win]
  {:method :nvim-win-get-cursor
   :params [win]})

(defn win-set-cursor [win {:keys [row col]}]
  {:method :nvim-win-set-cursor
   :params [win [row col]]})

(defn list-wins []
  {:method :nvim-list-wins})

(defn list-bufs []
  {:method :nvim-list-bufs})

(defn buf-get-name [buf]
  {:method :nvim-buf-get-name
   :params [buf]})

(defn buf-get-var [buf name]
  {:method :nvim-buf-get-var
   :params [buf (util/kw->snake name)]})

(defn buf-set-var [buf name value]
  {:method :nvim-buf-set-var
   :params [buf (util/kw->snake name) value]})

(defn execute-lua [code & args]
  {:method :nvim-execute-lua
   :params [code args]})

(defn buf-line-count [buf]
  {:method :nvim-buf-line-count
   :params [buf]})

(defn buf-get-lines [buf {:keys [start end strict-indexing?]}]
  {:method :nvim-buf-get-lines
   :params [buf start end (boolean strict-indexing?)]})

(defn buf-set-lines [buf {:keys [start end strict-indexing?]} lines]
  {:method :nvim-buf-set-lines
   :params [buf start end (boolean strict-indexing?) lines]})

(defn call-function [fn-name & args]
  {:method :nvim-call-function
   :params [(util/kw->snake fn-name) args]})

(defn eval* [expr]
  {:method :nvim-eval
   :params [expr]})

(defn command-output [expr]
  {:method :nvim-command-output
   :params [expr]})

(defn feedkeys [{:keys [keys mode escape-csi] :or {mode :m, escape-csi false}}]
  {:method :nvim-feedkeys
   :params [keys (name mode) escape-csi]})
