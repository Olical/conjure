(define (add a b)
  (+ a b))

(display "hi")

(+ 5 6)
(add 1 2)

(define (print-hi-and-return x)
  (begin
    (display "Hi")
    (newline))
  x)

(print-hi-and-return 123)

(define (return-values)
  (values 123 "Hi"))

(return-values)
