(ns conjure.nvim
  (:require [applied-science.js-interop :as j]))

(defonce api! (atom nil))

(defn hello []
  (-> (j/get-in @api! [:buffer :append])
      (apply "Hello, World! From Conjure ClojureScript!")))

(defn setup! [plugin]
  (reset! api! (j/get plugin :nvim))

  (let [register-command (j/get plugin :registerCommand)]
    (register-command plugin "ConjureCLJS" hello)))
