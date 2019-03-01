(ns conjure.async)

(defmacro go [& forms]
  `(a/go
     (try
       ~@forms
       (catch :default error#
         (a/>! error-chan error#)))))
