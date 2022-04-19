;;;; Common Lisp Conjure Sandbox 

(defpackage :sandbox
  (:use :cl))

(in-package :sandbox)

*package*

;; We can call regular functions
(+ 1 2 3)

;; We can define functions
(defun some-function (a b c)
  "This is a function that prints the first var
  and adds the second two"
  (princ a)
  (+ b c))



;; Then we can call it: (press K for documentation
(some-function 1 2 3)

(reverse
  (list 1 2 3 "4" "5 6 7"))

;; you can of course, quote things out
(quote (list 1 2 3))

(print '(list 1 2 3))

;; and define and use macros

(defmacro do-primes ((var start end) &body body)
  (let ((ending-value-name (gensym)))
    `(do ((,var (next-prime ,start ) (next-prime (1+ ,var)))
          (,ending-value-name ,end))
       ((> ,var ,ending-value-name))
       ,@body)))

;; try this for macro expansion:
(macroexpand-1 '(do-primes (ending-value 0 10) (print ending-value)))

;; this will show up as an error,
(do-primes (p 0 10)
           (format t "~d " p))

;; until you define these functions: (Taken from Practical Common Lisp book)
(defun primep (number)
  (when (> number 1)
    (loop for fac from 2 to (isqrt number) never (zerop (mod number fac)))))

(defun next-prime (number)
  (loop for n from number when (primep n) return n))

;; (then go back and run line 35 again
