(ns conjure.async)

(defmacro catch! [& body]
  `(try
     ~@body
     (catch :default error#
       (a/go (a/>! error-chan error#)))))

(defmacro go [& body]
  `(a/go (catch! ~@body)))
