(use-modules ((ice-9 readline) 
      #:select (apropos-completion-function)
      #:prefix %conjure:))

(define* (%conjure:get-guile-completions prefix #:optional (continued #f))
    (let ((suggestion (%conjure:apropos-completion-function prefix continued)))
      (if (not suggestion)
        '()
        (cons suggestion (%conjure:get-guile-completions prefix #t)))))
