(import ./other)

(defn add
  "It adds things!"
  [a b]
  (+ a b))

(print "Hello, World!")
(print "\e[32mHello, World!\e[0m")
(eprint "ohno")

(do
  (print "Hi...")
  (range 10))

(comment
  (explode))

# TODO: How can I ,ef then access other/sub in here.
# I need to be able to require this module _and_ the things it requires.
(+ (add 10 20) (other/sub 10 5))
