(create-ns 'conjure.internal)
(intern 'conjure.internal 'initial-ns (symbol (str *ns*)))

(ns conjure.internal
  (:require [clojure.pprint :as pp]
            [clojure.test]
            [clojure.data]
            [clojure.string]))

;; This is a shim that inserts a pprint fn in the place that CIDER would create it if it's not found.
;; We shim instead of creating our own distinct function because babashka requires us
;; to refer to `cider.nrepl.pprint/pprint` if we want to use pretty printing.
;; https://github.com/Olical/conjure/issues/406
(when-not (find-ns 'cider.nrepl.pprint)
  (create-ns 'cider.nrepl.pprint)
  (intern 'cider.nrepl.pprint 'pprint
          (fn pprint [val w opts]
            (apply pp/write val
                   (mapcat identity (assoc opts :stream w))))))

(defn bounded-conj [queue x limit]
  (->> x (conj queue) (take limit)))

(def tap-queue-size :conjure.template/queue-size)
(defonce tap-queue! (atom (list)))

;; Must be a defonce so that we always have the same function
;; reference to remove-tap and add-tap. If we make a new
;; function each time we'll end up adding more and more tap
;; functions.
(defonce enqueue-tap!
  (fn [x] (swap! tap-queue! bounded-conj x tap-queue-size)))

;; No setup for older Clojure versions.
(when (resolve 'add-tap)
  (remove-tap enqueue-tap!)
  (add-tap enqueue-tap!))

(defn dump-tap-queue! []
  (reverse (first (reset-vals! tap-queue! (list)))))

(when :conjure.template/pretty-print-test-failures?
  (defmethod clojure.test/report :fail [m]
    (clojure.test/with-test-out
      (clojure.test/inc-report-counter :fail)
      (println "\nFAIL in" (clojure.test/testing-vars-str m))
      (when (seq clojure.test/*testing-contexts*) (println (clojure.test/testing-contexts-str)))
      (when-let [message (:message m)] (println message))
      (print "expected:" (with-out-str (prn (:expected m))))
      (print "  actual:" (with-out-str (prn (:actual m))))
      (when (and (seq? (:actual m))
                 (= #'clojure.core/not (resolve (first (:actual m))))
                 (seq? (second (:actual m)))
                 (= #'clojure.core/= (resolve (first (second (:actual m)))))
                 (= 3 (count (second (:actual m)))))
        (let [[missing extra _] (clojure.data/diff (second (second (:actual m))) (last (second (:actual m))))
              missing-str (with-out-str (pp/pprint missing))
              missing-lines (clojure.string/split-lines missing-str)
              extra-str (with-out-str (pp/pprint extra))
              extra-lines (clojure.string/split-lines extra-str)]
          (when (some? missing) (doseq [m missing-lines] (println "- " m)))
          (when (some? extra) (doseq [e extra-lines] (println "+ " e))))))))

(in-ns initial-ns)
