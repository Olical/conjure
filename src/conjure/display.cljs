(ns conjure.display
  "Ways to inform the user about responses, results and errors."
  (:require [clojure.spec.alpha :as s]
            [clojure.string :as str]
            [expound.alpha :as expound]
            [cljs.core.async :as a]
            [conjure.async :as async :include-macros true]
            [conjure.nvim :as nvim]
            [conjure.util :as util]))

;; TODO Rename this to just conjure.cljc once I completely replace the Rust version.
(def log-buffer-name "/tmp/conjure-log.cljc")
(def log-window-widths {:small 40 :large 80})
(def max-log-buffer-length 10000)
(defonce log-chan (a/chan))

(defn- <tabpage-log-window []
  (async/go
    (let [tabpage (a/<! (nvim/<tabpage))]
      (loop [[window & windows] (a/<! (nvim/<windows tabpage))]
        (when window
          (let [buffer (a/<! (nvim/<buffer window))]
            (if (= (a/<! (nvim/<name buffer)) log-buffer-name)
              window
              (recur windows))))))))

(defn <upsert-tabpage-log-window! []
  (async/go
    (if-let [window (a/<! (<tabpage-log-window))]
      window
      (do
        (nvim/command! "botright" (str (:small log-window-widths) "vnew") log-buffer-name)
        (nvim/command! "setlocal winfixwidth")
        (nvim/command! "setlocal buftype=nofile")
        (nvim/command! "setlocal bufhidden=hide")
        (nvim/command! "setlocal nowrap")
        (nvim/command! "setlocal noswapfile")
        (nvim/command! "wincmd w")
        (a/<! (<tabpage-log-window))))))

;; TODO Make the window auto expand and hide
(defn- <log!* [{:keys [conn value]}]
  (async/go
    (let [window (a/<! (<upsert-tabpage-log-window!))
          buffer (a/<! (nvim/<buffer window))
          length (a/<! (nvim/<length buffer))
          sample (a/<! (nvim/<get-lines buffer {:start 0, :end 1}))
          prefix (str ";" (name (:tag conn)) "/" (name (:tag value)) ";")
          val-lines (str/split (:val value) #"\n")]

      (when (and (= length 1) (= sample [""]))
        (nvim/set-lines! buffer {:start 0} ";conjure/out; Welcome!"))

      (when (> length max-log-buffer-length)
        (nvim/set-lines! buffer {:start 0, :end (/ max-log-buffer-length 2)} ""))

      (if (contains? #{:ret :tap} (:tag value))
        (nvim/append! buffer prefix val-lines)
        (nvim/append! buffer (map #(str prefix " " %) val-lines)))

      (nvim/scroll-to-bottom! window))))

(defn log! [opts]
  (async/go (a/>! log-chan opts)))

(defn info! [& args]
  (log! {:conn {:tag :conjure}, :value {:tag :out, :val (util/join args)}}))

(defn error! [& args]
  (log! {:conn {:tag :conjure}, :value {:tag :err, :val (util/join args)}}))

(defn enable-log-print! []
  (a/go-loop []
    (when-let [opts (a/<! log-chan)]
      (a/<! (<log!* opts))
      (recur))))

(defn ensure! [spec form]
  (if (s/valid? spec form)
    form
    (do
      (log! {:conn {:tag :conjure}, :value {:tag :err, :val (expound/expound-str spec form)}})
      nil)))
