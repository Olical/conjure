(ns conjure.main
  (:require [cljs.nodejs :as node]
            [applied-science.js-interop :as j]
            [conjure.nvim :as n]))

(node/enable-util-print!)

(defn hello []
  (-> (n/buffer)
      (n/append "Hello, World! From Conjure ClojureScript!")))

(defn setup! [plugin]
  (n/reset-plugin! plugin)
  (n/register-command :ConjureCLJS hello))

(j/assoc! js/module :exports setup!)
