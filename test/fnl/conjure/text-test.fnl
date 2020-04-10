(module conjure.text-test
  {require {text conjure.text}})

(deftest left-sample
  (t.= "" (text.left-sample "" 0) "handles empty strings")
  (t.= "f" (text.left-sample "f" 1) "handles single characters")
  (t.= "foo bar" (text.left-sample "foo bar" 10) "does nothing if correct")
  (t.= "foo bar" (text.left-sample "foo    \n\n bar" 10) "replaces lots of whitespace with a space")
  (t.= "foo bar b..." (text.left-sample "foo    \n\n bar \n\n baz" 10) "cuts the string if too long")
  (t.= "foo bar" (text.left-sample "   foo \n \n bar  \n" 10) "trims leading and trailing whitespace"))

(deftest right-sample
  (t.= "...o bar baz" (text.right-sample "foo    \n\n bar \n\n baz" 10) "same as left-sample, but we want the right"))

(deftest split-lines
  (t.pr= [] (text.split-lines "") "nothing to nothing")
  (t.pr= ["foo" "bar"] (text.split-lines "foo\nbar") "basic split"))

(deftest prefixed-lines
  (t.pr= [] (text.prefixed-lines "" "; ") "nothing to nothing")
  (t.pr= ["; foo"] (text.prefixed-lines "foo" "; ") "single line")
  (t.pr= ["; foo" "; bar"] (text.prefixed-lines "foo\nbar" "; ") "multiple lines"))
