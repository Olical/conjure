(ns conjure.nvim
  "Wrapper around all nvim functions."
  (:require [clojure.string :as str]
            [applied-science.js-interop :as j]
            [conjure.util :as util]))

(defonce plugin! (atom nil))
(defonce api! (atom nil))

(defn reset-api! [api]
  (reset! api! api))

(defn reset-plugin! [plugin]
  (reset! plugin! plugin)
  (reset-api! (j/get plugin :nvim)))

(defn buffer []
  (j/get @api! :buffer))

(defn path [buffer]
  (j/get buffer :name))

(defn out-write! [& args]
  (j/call @api! :outWrite (str/join " " args)))

(defn out-write-line! [& args]
  (j/call @api! :outWriteLine (str/join " " args)))

(defn err-write! [& args]
  (j/call @api! :errWrite (str/join " " args)))

(defn err-write-line! [& args]
  (j/call @api! :errWriteLine (str/join " " args)))

(defn register-command!
  ([k f] (register-command! k f {}))
  ([k f opts]
   (j/call @plugin! :registerCommand
           (name k)
           (fn [s]
             (try
               (f (str s))
               (catch :default e
                 (err-write-line! e))))
           (util/->js opts))))
