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
  (t.pr= [""] (text.split-lines "") "nothing to nothing")
  (t.pr= ["foo" "bar"] (text.split-lines "foo\nbar") "basic split")
  (t.pr= ["foo" "" "bar"] (text.split-lines "foo\n\nbar") "blank lines")
  (t.pr= ["foo" "bar"] (text.split-lines "foo\r\nbar") "Windows CRLF"))

(deftest prefixed-lines
  (t.pr= ["; "] (text.prefixed-lines "" "; ") "nothing to nothing")
  (t.pr= ["; foo"] (text.prefixed-lines "foo" "; ") "single line")
  (t.pr= ["; foo" "; bar"] (text.prefixed-lines "foo\nbar" "; ") "multiple lines"))

(deftest starts-with
  (t.= true (text.starts-with "foobar" "foo"))
  (t.= true (text.starts-with "foobar" "foob"))
  (t.= false (text.starts-with "foobar" "foox"))
  (t.= nil (text.starts-with nil "ohno")))

(deftest ends-with
  (t.= true (text.ends-with "foobar" "bar"))
  (t.= true (text.ends-with "foobar" "obar"))
  (t.= false (text.ends-with "foobar" "xbar"))
  (t.= nil (text.ends-with nil "ohno")))

(deftest first-and-last-chars
  (t.= "()" (text.first-and-last-chars "(hello-world)"))
  (t.= "" (text.first-and-last-chars ""))
  (t.= "(" (text.first-and-last-chars "("))
  (t.= nil (text.first-and-last-chars nil)))

(deftest chars
  (t.pr= [] (text.chars))
  (t.pr= [] (text.chars ""))
  (t.pr= [:a :b :c] (text.chars "abc")))

(deftest upper-first
  (t.= "" (text.upper-first ""))
  (t.= "A" (text.upper-first "A"))
  (t.= "A" (text.upper-first "a"))
  (t.= "Foo bar bAZ 5" (text.upper-first "foo bar bAZ 5"))
  (t.= nil (text.upper-first nil))
  (t.= "123" (text.upper-first "123")))
