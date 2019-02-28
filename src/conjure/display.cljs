(ns conjure.display
  "Ways to inform the user about responses, results and errors."
  (:require [clojure.spec.alpha :as s]
            [cljs.core.async :as a]
            [expound.alpha :as expound]
            [conjure.nvim :as nvim]))

(def log-buffer-name "/tmp/conjure-log.cljc")

(defn- <tabpage-log-window []
  (a/go
    (let [tabpage (a/<! (nvim/<tabpage))]
      (loop [[window & windows] (a/<! (nvim/<windows tabpage))]
        (when window
          (let [buffer (a/<! (nvim/<buffer window))]
            (if (= (a/<! (nvim/<name buffer)) log-buffer-name)
              window
              (recur windows))))))))

(defn- <upsert-tabpage-log-window! []
  (a/go
    (if-let [window (a/<! (<tabpage-log-window))]
      window
      (do
        (nvim/command! "vsplit" log-buffer-name)
        (a/<! (<tabpage-log-window))))))

(do
  ;; TODO Format these nicely
  ;; TODO Run all output through here
  ;; TODO Ensure the window displays correctly (small right side)
  ;; TODO Make the window auto expand and hide 
  ;; TODO Have a way to open it (optionally focus)
  (defn log! [{:keys [conn value]}]
    (a/go
      (let [window (a/<! (<upsert-tabpage-log-window!))
            buffer (a/<! (nvim/<buffer window))]
        (nvim/append! buffer conn value))))
  (log! {:conn {:tag :test}
         :value {:tag :ret
                 :val ":yarp"}}))

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
