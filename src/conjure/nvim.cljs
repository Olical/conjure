(ns conjure.nvim
  "Wrapper around all nvim functions."
  (:require [cljs.nodejs :as node]
            [applied-science.js-interop :as j]
            [cljs.core.async :as a]
            [conjure.async :as async :include-macros true]
            [conjure.util :as util]))

(defonce plugin! (atom nil))
(defonce api! (atom nil))

(defn require-api! []
  (-> (node/require "neovim/scripts/nvim")
      (j/call :then #(reset! api! %))))

(defn reset-plugin! [plugin]
  (reset! plugin! plugin)
  (reset! api! (j/get plugin :nvim)))

(defn <buffer
  ([] (<buffer @api!))
  ([o] (-> (j/get o :buffer) (async/->chan))))

(defn <window
  ([] (<window @api!))
  ([o] (-> (j/get o :window) (async/->chan))))

(defn <tabpage
  ([] (<tabpage @api!))
  ([o] (-> (j/get o :tabpage) (async/->chan))))

(defn <buffers
  ([] (<buffers @api!))
  ([o] (-> (j/get o :buffers)
           (j/call :then array-seq)
           (async/->chan))))

(defn <windows
  ([] (<windows @api!))
  ([o] (-> (j/get o :windows)
           (j/call :then array-seq)
           (async/->chan))))

(defn <tabpages []
  (-> (j/get @api! :tabpages)
      (j/call :then array-seq)
      (async/->chan)))

(defn <name ([buffer]
  (-> (j/get buffer :name) (async/->chan))))

(defn <length [buffer]
  (-> (j/get buffer :length) (async/->chan)))

(defn set-width! [window width]
  (j/assoc! window :width width))

(defn set-cursor! [window {:keys [x y]}]
  (j/assoc! window :cursor #js [y x]))

(defn <all-lines [buffer]
  (-> (j/get buffer :lines)
      (j/call :then array-seq)
      (async/->chan)))

(defn <get-lines [buffer opts]
  (-> (j/call buffer :getLines (util/->js opts))
      (j/call :then array-seq)
      (async/->chan)))

(defn set-lines! [buffer opts & lines]
  (j/call buffer :setLines
          (util/->js (flatten lines))
          (util/->js opts)))

(defn append! [buffer & args]
  (j/call buffer :append (util/->js (flatten args))))

(defn scroll-to-bottom! [window]
  (async/go
    (let [buffer (a/<! (<buffer window))
          length (a/<! (<length buffer))]
      (set-cursor! window {:x 0, :y length}))))

(defn command! [& args]
  (j/call @api! :command (util/join args)))

(defn out-write! [& args]
  (j/call @api! :outWrite (util/join args)))

(defn out-write-line! [& args]
  (j/call @api! :outWriteLine (util/join args)))

(defn err-write! [& args]
  (j/call @api! :errWrite (util/join args)))

(defn err-write-line! [& args]
  (j/call @api! :errWriteLine (util/join args)))

(defn register-command!
  ([k f] (register-command! k f {}))
  ([k f opts]
   (j/call @plugin! :registerCommand
           (name k)
           (fn [s]
             (try
               (f (str s))
               (catch :default error
                 (err-write-line! error))))
           (util/->js opts))))

(defn enable-error-print! []
  (a/go-loop []
    (when-let [error (a/<! async/error-chan)]
      (async/catch! (err-write-line! error))
      (recur))))
