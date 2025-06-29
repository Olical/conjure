(local assert (require :luassert.assert))
(local say (require :say))

(fn assert-has-substring [_ args]
  (if (not= (string.match (. args 2) (. args 1)) nil)
      true
      false))

(say:set :assertion.has-substring.positive
         "Expected %s \nto be a substring of %s")
(say:set :assertion.has-substring.negative
         "Expected %s \nnot to be a substring of %s")

(assert:register 
  :assertion :has-substring
  assert-has-substring
  :assertion.has-substring.positive 
  :assertion.has-substring.negative)

