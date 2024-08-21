(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local text (require :conjure.text))

(describe "text"
  (fn []
    (describe "left-sample"
      (fn []
        (it "handles empty strings"
          (fn []
            (assert.are.equals "" (text.left-sample "" 0))))

        (it "handles single characters"
          (fn []
            (assert.are.equals "f" (text.left-sample "f" 1))))

        (it "does nothing if correct"
          (fn []
            (assert.are.equals "foo bar" (text.left-sample "foo bar" 10))))

        (it "replaces lots of whitespace with a space"
          (fn []
            (assert.are.equals "foo bar" (text.left-sample "foo    \n\n bar" 10))))

        (it "cuts the string if too long"
          (fn []
            (assert.are.equals "foo bar b..." (text.left-sample "foo    \n\n bar \n\n baz" 10))))

        (it "trims leading and trailing whitespace"
          (fn []
            (assert.are.equals "foo bar" (text.left-sample "   foo \n \n bar  \n" 10))))))

    (describe "right-sample"
      (fn []
        (it "same as left-sample, but we want the right"
          (fn []
            (assert.are.equals "...o bar baz" (text.right-sample "foo    \n\n bar \n\n baz" 10))))))

    (describe "split-lines"
      (fn []
        (it "nothing to nothing"
          (fn []
            (assert.same [""] (text.split-lines "") "")))

        (it "basic split"
          (fn []
            (assert.same ["foo" "bar"] (text.split-lines "foo\nbar") "")))

        (it "blank lines"
          (fn []
            (assert.same ["foo" "" "bar"] (text.split-lines "foo\n\nbar") "")))

        (it "Windows CRLF"
          (fn []
            (assert.same ["foo" "bar"] (text.split-lines "foo\r\nbar") "")
            ))))

    (describe "prefixed-lines"
      (fn []
        (it "nothing to nothing"
          (fn []
            (assert.same ["; "] (text.prefixed-lines "" "; "))))

        (it "single line"
          (fn []
            (assert.same ["; foo"] (text.prefixed-lines "foo" "; "))))

        (it "multiple lines"
          (fn []
            (assert.same ["; foo" "; bar"] (text.prefixed-lines "foo\nbar" "; "))))))

    (describe "starts-with"
      (fn []
        (it "foo"
          (fn []
            (assert.are.equals true (text.starts-with "foobar" "foo"))))

        (it "foob"
          (fn []
            (assert.are.equals true (text.starts-with "foobar" "foob"))))

        (it "foox"
          (fn []
            (assert.are.equals false (text.starts-with "foobar" "foox"))))

        (it "ohno"
          (fn []
            (assert.are.equals nil (text.starts-with nil "ohno"))))))

    (describe "ends-with"
      (fn []
        (it "bar"
          (fn []
            (assert.are.equals true (text.ends-with "foobar" "bar"))))

        (it "obar"
          (fn []
            (assert.are.equals true (text.ends-with "foobar" "obar"))))

        (it "xbar"
          (fn []
            (assert.are.equals false (text.ends-with "foobar" "xbar"))))

        (it "ohno"
          (fn []
            (assert.are.equals nil (text.ends-with nil "ohno"))))))

    (describe "first-and-last-chars"
      (fn []
        (it "of parentheses around words"
          (fn []
            (assert.are.equals "()" (text.first-and-last-chars "(hello-world)"))))
        (it "of empty string"
          (fn []
            (assert.are.equals "" (text.first-and-last-chars ""))))
        (it "of single opening parenthesis"
          (fn []
            (assert.are.equals "(" (text.first-and-last-chars "("))))
        (it "of nil"
          (fn []
            (assert.are.equals nil (text.first-and-last-chars nil))))))

    (describe "chars"
      (fn []
        (it "of nothing"
          (fn []
            (assert.same [] (text.chars))))
        (it "of empty string"
          (fn []
            (assert.same [] (text.chars ""))))
        (it "of \"abc\""
          (fn []
            (assert.same [:a :b :c] (text.chars "abc"))))))

    (describe "upper-first"
      (fn []
        (it "of empty string"
            (fn []
              (assert.are.equals "" (text.upper-first ""))))
        (it "of \"A\""
            (fn []
              (assert.are.equals "A" (text.upper-first "A"))))
        (it "of \"a\""
            (fn []
              (assert.are.equals "A" (text.upper-first "a"))))
        (it "of first word of many words"
            (fn []
              (assert.are.equals "Foo bar bAZ 5" (text.upper-first "foo bar bAZ 5"))))
        (it "of nil"
            (fn []
              (assert.are.equals nil (text.upper-first nil))))
        (it "of string of numbers"
            (fn []
              (assert.are.equals "123" (text.upper-first "123"))
              ))))))
