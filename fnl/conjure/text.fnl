(module conjure.text
  {:require {a conjure.aniseed.core
             str conjure.aniseed.string}})

(defn- trim [s]
  (string.gsub s "^%s*(.-)%s*$" "%1"))

(defn left-sample [s limit]
  (let [flat (-> (string.gsub s "\n" " ")
                 (string.gsub "%s+" " ")
                 (trim))]
    (if (>= limit (a.count flat))
      flat
      (.. (string.sub flat 0 (a.dec limit)) "..."))))

(defn right-sample [s limit]
  (string.reverse (left-sample (string.reverse s) limit)))

(defn split-lines [s]
  (str.split s "[^\n]+"))

(defn prefixed-lines [s prefix]
  (->> (split-lines s)
       (a.map (fn [line]
                (.. prefix line)))))

(defn starts-with [str start]
  (= (string.sub str 1 (a.count start)) start))
