(local {: autoload : define } (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local text (autoload :conjure.text))
(local str (autoload :conjure.nfnl.string))

(local M (define :conjure.client.javascript.import-replacer))

(fn get-absolute-path [f]
  (string.format
    "%q"
    (vim.fs.normalize (vim.fs.joinpath (vim.fn.expand "%:p:h") f))))

(fn replace-imports-path [s]
  (if (or (string.find s :import)
          (string.find s :require))
      (string.gsub s "[\"\'](.-)[\"\']" 
                   (fn [m]
                     (if (text.starts-with m ".")
                         (get-absolute-path m)

                         (.. "\"" m "\""))))
      s))

(fn curly-replacer [bd]
  (let [spl (str.split bd ",")
        spl->nms (->> 
                   spl 
                   (a.map (fn [el] (el:gsub " as " ": ")))
                   (str.join ","))]
    spl->nms))

(local patterns-replacements 
  [["^%s*import%s+([\"'])(.-)%1%s*" "require(\"%2\")"]
   ["^%s*import%s+([^%s{]+)%s+from%s+([\"'])(.-)%2%s*"
    "const %1 = require(\"%3\")"]
   ["import%s+%{(.-)%}%s+from%s+[\"'](.-)[\"']"
    (fn [bd path]
      (string.format "const {%s} = require(\"%s\")"
                     (curly-replacer bd) path))]
   ["^%s*import%s+([^%s{,]+)%s*,%s*%{([^}]+)%}%s+from%s+([\"'])(.-)%3%s*"
    (fn [default curly _ mod]
      (string.format "const {%s,%s} = require(\"%s\")" 
                     default (curly-replacer curly) mod))]
   ["^%s*import%s+(.-)%s*%,%s*%*%s*as%s+(.-)%s*from%s+[\"'](.-)[\"']%s*"
    (fn [default nm mod]
      (string.format "const %s = require(\"%s\");\nconst %s = %s.default"
                     nm mod default nm))]
   ["^%s*import%s+%*%s+as%s+([^%s]+)%s+from%s+([\"'])(.-)%2%s*"
    (fn [alias _ mod]
      (string.format "const %s = require(\"%s\")" alias mod))]])

(fn M.replace-imports-regex [s]
  (let [initial-acc {:applied? false :result s}
        r-fn (fn [acc [pat repl]]
                      (if acc.applied?
                          acc
                          (let [(r c) (string.gsub acc.result pat repl)]
                            (if (> c 0)
                                {:applied? true :result r}
                                acc))))
        final-acc (a.reduce r-fn initial-acc patterns-replacements)]
    final-acc.result))

;; To avoid Node.js REPL complaints, imports are automatically converted for the user.
;; See https://github.com/nodejs/node/issues/48084
(fn M.replace-imports [s]
  (let [s (replace-imports-path s)]
    (if (and (text.starts-with s :import)
             (not (text.starts-with s "import type")))
        (M.replace-imports-regex s)
        s)))

M
