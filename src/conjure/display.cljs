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
(def log-window-widths {:small 40 :large 80})
(def max-log-buffer-length 10000)
(def grace-period-ms 500)
(defonce log-buffer-name (str "/tmp/conjure-log-" (util/now) ".cljc"))
(defonce log-chan (a/chan))
(defonce last-update-ms! (atom 0))

(defn- <tabpage-log-window []
  (async/go
    (let [tabpage (a/<! (nvim/<tabpage))]
      (loop [[window & windows] (a/<! (nvim/<windows tabpage))]
        (when window
          (let [buffer (a/<! (nvim/<buffer window))]
            (if (= (a/<! (nvim/<name buffer)) log-buffer-name)
              window
              (recur windows))))))))

(defn- <upsert-tabpage-log-window! [{:keys [focus?]}]
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

        (when-not focus?
          (nvim/command! "wincmd p"))

        (a/<! (<tabpage-log-window))))))

(defn- <log!* [{:keys [conn value]}]
  (async/go
    (let [window (a/<! (<upsert-tabpage-log-window! {:focus? false}))
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

      (nvim/scroll-to-bottom! window)
      (reset! last-update-ms! (util/now)))))

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

(defn show-log! []
  (async/go
    (a/<! (<upsert-tabpage-log-window! {:focus? true}))))

(defn hide-log! []
  (async/go
    (when-let [window (a/<! (<tabpage-log-window))]
      (nvim/command! (str (a/<! (nvim/<number window)) "close")))))

;; The update timer and grace period is required because when I call
;; nvim/set-lines! it triggers a CursorMoved autocmd inside the user's
;; current buffer. Even though the cursor moved inside the log buffer!
;;
;; To "fix" this I just ignore calls to close the log 500ms after log lines
;; are altered any way.
(defn hide-background-log! []
  (async/go
    (when (and (not= log-buffer-name (a/<! (nvim/<name (a/<! (nvim/<buffer)))))
               (> (util/now) (+ @last-update-ms! grace-period-ms)))
      (a/<! (hide-log!)))))

(defn set-log-size! [size]
  (async/go
    (when-let [window (a/<! (<tabpage-log-window))]
      (nvim/set-width! window (get log-window-widths size)))))
