(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))

(fn trailing-newline? [s]
  (string.match s "\r?\n$"))

(fn trim-last-newline [s]
  (string.gsub s "\r?\n$" ""))

(fn left-sample [s limit]
  (let [flat (-> (string.gsub s "\n" " ")
                 (string.gsub "%s+" " ")
                 (str.trim))]
    (if (>= limit (a.count flat))
      flat
      (.. (string.sub flat 0 (a.dec limit)) "..."))))

(fn right-sample [s limit]
  (string.reverse (left-sample (string.reverse s) limit)))

(fn split-lines [s]
  (str.split s "\r?\n"))

(fn prefixed-lines [s prefix opts]
  (->> (split-lines s)
       (a.map-indexed
         (fn [[n line]]
           (if (and (= 1 n)
                    (a.get opts :skip-first?))
             line
             (.. prefix line))))))

(fn starts-with [str start]
  (when str
    (= (string.sub str 1 (a.count start)) start)))

(fn ends-with [str end]
  (when str
    (or (= end "") (= end (string.sub str (- (a.count end)))))))

(fn first-and-last-chars [str]
  (when str
    (if (> (a.count str) 1)
      (.. (string.sub str 1 1)
          (string.sub str -1 -1))
      str)))

(fn strip-ansi-escape-sequences [s]
  (-> s
      (string.gsub "\x1b%[%d+;%d+;%d+;%d+;%d+m" "")
      (string.gsub "\x1b%[%d+;%d+;%d+;%d+m" "")
      (string.gsub "\x1b%[%d+;%d+;%d+m" "")
      (string.gsub "\x1b%[%d+;%d+m" "")
      (string.gsub "\x1b%[%d+m" "")))

(fn chars [s]
  (local res [])
  (when s
    (each [c (string.gmatch s ".")]
      (table.insert res c)))
  res)

(fn upper-first [s]
  (when s
    (s:gsub "^%l" string.upper)))

{
 : trailing-newline?
 : trim-last-newline
 : left-sample
 : right-sample
 : split-lines
 : prefixed-lines
 : starts-with
 : ends-with
 : first-and-last-chars
 : strip-ansi-escape-sequences
 : chars
 : upper-first
 }
