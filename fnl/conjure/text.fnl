(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))

(local M (define :conjure.text))

(fn M.trailing-newline? [s]
  (string.match s "\r?\n$"))

(fn M.trim-last-newline [s]
  (string.gsub s "\r?\n$" ""))

(fn M.left-sample [s limit]
  (let [flat (-> (string.gsub s "\n" " ")
                 (string.gsub "%s+" " ")
                 (str.trim))]
    (if (>= limit (core.count flat))
      flat
      (.. (string.sub flat 0 (core.dec limit)) "..."))))

(fn M.right-sample [s limit]
  (string.reverse (M.left-sample (string.reverse s) limit)))

(fn M.split-lines [s]
  (str.split s "\r?\n"))

(fn M.prefixed-lines [s prefix opts]
  (->> (M.split-lines s)
       (core.map-indexed
         (fn [[n line]]
           (if (and (= 1 n)
                    (core.get opts :skip-first?))
             line
             (.. prefix line))))))

(fn M.starts-with [str start]
  (when (and str start)
    (vim.startswith str start)))

(fn M.ends-with [str end]
  (when (and str end)
    (or (= end "")
        (vim.endswith str end))))

(fn M.first-and-last-chars [str]
  (when str
    (if (> (core.count str) 1)
      (.. (string.sub str 1 1)
          (string.sub str -1 -1))
      str)))

(fn M.strip-ansi-escape-sequences [s]
  (-> s
      (string.gsub "\x1b%[%d+;%d+;%d+;%d+;%d+m" "")
      (string.gsub "\x1b%[%d+;%d+;%d+;%d+m" "")
      (string.gsub "\x1b%[%d+;%d+;%d+m" "")
      (string.gsub "\x1b%[%d+;%d+m" "")
      (string.gsub "\x1b%[%d+m" "")))

(fn M.chars [s]
  (local res [])
  (when s
    (each [c (string.gmatch s ".")]
      (table.insert res c)))
  res)

(fn M.upper-first [s]
  (when s
    (s:gsub "^%l" string.upper)))

M
