(fn strip-meta [s]
  (-?> s
       (string.gsub "%^:.-%s+" "")
       (string.gsub "%^%b{}%s+" "")))

(fn strip-comments [s]
  (-?> s
       (string.gsub ";.-[\n$]" "")))

(fn strip-shebang [s]
  (-?> s
       (string.gsub "^#![^\n]*\n" "")))

{: strip-comments : strip-meta : strip-shebang}
