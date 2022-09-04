(module conjure.client.clojure.nrepl.parse)

(defn strip-meta [s]
  (-?> s
       (string.gsub "%^:.-%s+" "")
       (string.gsub "%^%b{}%s+" "")))

(defn strip-comments [s]
  (-?> s
       (string.gsub ";.-[\n$]" "")))

(defn strip-shebang [s]
  (-?> s
       (string.gsub "^#![^\n]*\n" "")))
