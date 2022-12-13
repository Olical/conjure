(module conjure.text
  {require {a conjure.aniseed.core
            str conjure.aniseed.string}})

(defn trailing-newline? [s]
  (string.match s "\r?\n$"))

(defn trim-last-newline [s]
  (string.gsub s "\r?\n$" ""))

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
  (str.split s "\r?\n"))

(defn prefixed-lines [s prefix opts]
  (->> (split-lines s)
       (a.map-indexed
         (fn [[n line]]
           (if (and (= 1 n)
                    (a.get opts :skip-first?))
             line
             (.. prefix line))))))

(defn starts-with [str start]
  (when str
    (= (string.sub str 1 (a.count start)) start)))

(defn ends-with [str end]
  (when str
    (or (= end "") (= end (string.sub str (- (a.count end)))))))

(defn first-and-last-chars [str]
  (when str
    (if (> (a.count str) 1)
      (.. (string.sub str 1 1)
          (string.sub str -1 -1))
      str)))

(defn strip-ansi-escape-sequences [s]
  (-> s
      (string.gsub "\x1b%[%d+;%d+;%d+;%d+;%d+m" "")
      (string.gsub "\x1b%[%d+;%d+;%d+;%d+m" "")
      (string.gsub "\x1b%[%d+;%d+;%d+m" "")
      (string.gsub "\x1b%[%d+;%d+m" "")
      (string.gsub "\x1b%[%d+m" "")))

(defn chars [s]
  (local res [])
  (when s
    (each [c (string.gmatch s ".")]
      (table.insert res c)))
  res)

(defn upper-first [s]
  (when s
    (s:gsub "^%l" string.upper)))
