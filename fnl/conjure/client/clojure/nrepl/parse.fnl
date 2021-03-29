(module conjure.client.clojure.nrepl.parse)

(defn strip-meta [s]
  (-?> s
       (string.gsub "%^:.-%s+" "")
       (string.gsub "%^%b{}%s+" "")))
