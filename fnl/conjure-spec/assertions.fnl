(local assert (require :luassert.assert))
(local say (require :say))

(fn assert_contains [_ args]
  (if (not= (string.match (. args 2) (. args 1)) nil)
      true
      false))

(say:set :assertion.contains.positive 
         "Expected %s \nto be a substring of %s")
(say:set :assertion.contains.negative 
         "Expected %s \nnot to be a substring of %s")

(assert:register 
  :assertion :contains 
  assert_contains 
  :assertion.contains.positive 
  :assertion.contains.negative)

