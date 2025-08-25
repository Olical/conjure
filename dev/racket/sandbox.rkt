#lang racket/base

(define (add a b)
  (+ a b))

(+ 1 2) ; 3
(add 10 20) ; 30

(print "Hello, World!")

(null? 'a) ; #f
(null? '()) ; #t

(let ([alist  '(("the" ("rain" "in") 42 "falls") "to" 7.2)])
      (cdadar alist)) ; '("in")


;; from https://www-old.cs.utah.edu/plt/dagstuhl19/example-langs.html

(define (fib n)
  (cond
    [(= n 0) 0]
    [(= n 1) 1]
    [else (+ (fib (- n 1)) (fib (- n 2)))]))
 
(fib 30) ; 832040


;; from https://docs.racket-lang.org/reference/for.html#%28part._.Iteration_and_.Comprehension_.Forms%29
(for ([i '(1 2 3)]
      [j "abc"]
      [k #(#t #f)])
    #:break (not (or (odd? i) k))
    (display (list i j k))) ; (1 a #t)


;; from https://docs.racket-lang.org/guide/Lists__Iteration__and_Recursion.html#(part._.Recursion_versus_.Iteration)
(require racket/list)  ; for definition of empty?

(define (remove-dups l)
  (cond
    [(empty? l) empty]
    [(empty? (rest l)) l]
    [else
     (let ([i (first l)])
       (if (equal? i (first (rest l)))
           (remove-dups (rest l))
           (cons i (remove-dups (rest l)))))]))
 
(remove-dups (list "a" "b" "b" "b" "c" "c")) ; '("a" "b" "c")

(remove-dups (list "a" "b" "b" "b" "b" "b")) ; '("a" "b")

