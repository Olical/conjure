(import ./other)

(defn add
  "It adds things!"
  [a b]
  (+ a b))

(print "Hello, World!")
(print "\e[32mHello, World!\e[0m")
(print "\0")
(eprint "ohno")

(do
  (print "Hi...")
  (range 10))

(comment
  (explode))

(+ (add 10 20) (other/sub 10 5))
