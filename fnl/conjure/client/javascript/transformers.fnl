(local {: autoload : define } (require :conjure.nfnl.module))
(local a (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local text (autoload :conjure.text))

(local M (define :conjure.client.javascript.transformers))

(fn is-arrow-fn? [code]
  (when (or (text.starts-with code "let")
            (text.starts-with code "const"))
    (let [pat (if (string.find code "async")
                  ".*=%s*async%s+%(.*%)%s*:+.*=>"
                  ".*=%s*%(.*%)%s*:?.*=>")]
      (if (string.match code pat)
          true 
          false))))

;; Before sending code to the REPL, all comments must be removed
(fn M.remove-comments [s]
  (let [(sub _) (-> s  
                    (string.gsub "^//.-\n" "")
                    (string.gsub "%s*[^:]//.-\n" "\n")
                    (string.gsub "([^:]//).-\n" "")
                    (string.gsub "%/%*.-%*%/" "")
                    (string.gsub "^%s*%*.*" "")
                    (string.gsub "^%s*%/%*+.*" ""))]
    sub))

;; Arrow functions are automatically transformed into standard functions, 
;; allowing them to be redefined in the Node.js REPL.
(fn M.replace-arrows [s]
  (if (not (is-arrow-fn? s)) s
      (let [decl (if (text.starts-with s :const) "const" 
                     (text.starts-with s :let) "let")
            pattern (.. decl "%s*([%w_]+)%s*=%s*(.-)%((.-)%)%s*(.-)%s*=>%s*(.*)")
            replace-fn (fn [name before-args args after-args body]
                         (let [async-kw (if (before-args:find :async) "async " "")
                               final-body (if (body:find "^%s*%{")
                                              (.. " " body)
                                              (.. " { return " body " }"))]
                           (.. async-kw "function " name "(" args ")" after-args final-body)))
            (replace _) (s:gsub pattern replace-fn)]
        replace)))

(fn not-declaration? [ln]
  (and (not (or (text.starts-with ln "let")
                (text.starts-with ln "const")))
       (or (string.match ln ".-%&%&.-")
           (text.starts-with ln "?")
           (text.starts-with ln ":"))))

;; For better user experience, in some scenarios semicolons must be automatically appended 
(fn add-semicolon [s]
  (let [spl (str.split s "\n")
        sub-fn (fn [ln]
                 (let [ln (str.trim ln)]
                   (if (or (text.starts-with ln :.)
                           (string.match ln "%s*@")
                           (text.ends-with ln "{")
                           (text.ends-with ln ";")
                           (text.ends-with ln ",")
                           (not-declaration? ln)
                           (str.blank? ln))
                       ln
                       (.. ln ";"))))
        sub (a.map sub-fn spl)]
    (str.join " " sub)))

(fn M.manage-semicolons [s]
  (if (or 
        (text.starts-with s "function")
        (text.starts-with s "namespace")
        (text.starts-with s "class")
        (text.starts-with s "@")
        (string.match s ".-%s*:%s*%[.-%]%s*=%s*.-"))
      (add-semicolon s)
      s))

(fn flat-dot-lines [s]
  (string.gsub s "%s+" " "))

(fn M.transform [s]
  (-> s 
      M.remove-comments 
      M.manage-semicolons
      flat-dot-lines
      M.replace-arrows))

M
