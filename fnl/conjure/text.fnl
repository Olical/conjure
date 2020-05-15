(module conjure.text
  {:require {a conjure.aniseed.core
             str conjure.aniseed.string}})

(defn trailing-newline? [s]
  (= "\n" (string.sub s -1)))

(defn trim-last-newline [s]
  (if (trailing-newline? s)
    (string.sub s 1 -2)
    s))

(defn left-sample [s limit]
  (let [flat (-> (string.gsub s "\n" " ")
                 (string.gsub "%s+" " ")
                 (str.trim))]
    (if (>= limit (a.count flat))
      flat
      (.. (string.sub flat 0 (a.dec limit)) "..."))))

(defn right-sample [s limit]
  (string.reverse (left-sample (string.reverse s) limit)))

(defn split-lines [s]
  (str.split s "\n"))

(defn prefixed-lines [s prefix opts]
  (->> (split-lines s)
       (a.map-indexed
         (fn [[n line]]
           (if (and (= 1 n)
                    (a.get opts :skip-first?))
             line
             (.. prefix line))))))

(defn starts-with [str start]
  (= (string.sub str 1 (a.count start)) start))

(defn ends-with [str end]
  (or (= end "") (= end (string.sub str (- (a.count end))))))
