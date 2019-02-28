(ns conjure.display
  "Ways to inform the user about responses, results and errors."
  (:require [clojure.spec.alpha :as s]
            [cljs.core.async :as a]
            [expound.alpha :as expound]
            [conjure.nvim :as nvim]))

(def log-buffer-name "/tmp/conjure-log.cljc")

(defn- <log-buffer []
  (a/go
    (loop [[buffer & buffers] (a/<! (nvim/<buffers))]
      (when buffer
        (if (= (a/<! (nvim/<name buffer)) log-buffer-name)
          buffer
          (recur buffers))))))

(defn- <upsert-log-buffer! []
  (a/go
    (if-let [buffer (a/<! (<log-buffer))]
      buffer
      (do
        (nvim/command! "badd" log-buffer-name)
        (a/<! (<log-buffer))))))

(comment
  (do
    (defn log! [{:keys [conn value]}]
      ;; Upsert the window+buffer if it's not in this tabpage
      ;; Append the log, changing how it renders depending on the kind of (:tag value)
      (a/go
        (let [buffer (a/<! (<upsert-log-buffer!))]
          (prn buffer))))
    (log! {:conn {:tag :test}
           :value {:tag :ret
                   :val ":yarp"}})))

(defn message! [tag & args]
  (apply nvim/out-write-line! (when tag (str "[" (name tag) "]")) args))

(defn error! [tag & args]
  (apply nvim/err-write-line! (when tag (str "[" (name tag) "]")) args))

(defn result! [tag result]
  (message! tag (name (:tag result)) "=>" (:val result)))

(defn ensure! [spec form]
  (if (s/valid? spec form)
    form
    (do
      (error! nil (expound/expound-str spec form))
      nil)))
