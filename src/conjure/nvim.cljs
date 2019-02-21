(ns conjure.nvim
  (:require [applied-science.js-interop :as j]))

(defonce api! (atom nil))

(defn hello []
  (-> (j/get-in @api! [:buffer])
      (j/call :append "Hello, World! From Conjure ClojureScript!")))

(defn setup! [plugin]
  (reset! api! (j/get plugin :nvim))
  (j/call plugin :registerCommand "ConjureCLJS" hello))
