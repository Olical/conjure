(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local elisp (require :conjure.remote.transport.elisp))

(describe "remote.transport.elisp"
  (fn []
    (describe "reads"
      (fn []
        (it "strings and symbols"
          (fn []
            (assert.are.equals nil (elisp.read ""))
            (assert.are.equals "foo" (elisp.read "\"foo\""))
            (assert.are.equals "foo" (elisp.read "  \"foo\"  "))
            (assert.are.equals "foo" (elisp.read ":foo"))
            (assert.are.equals "foo" (elisp.read "   :foo    "))
            (assert.are.equals "bar" (elisp.read "   :foo \"hi\" \n :bar  "))))
        (it "numbers"
          (fn []
            (assert.are.equals 0 (elisp.read "0"))
            (assert.are.equals 1 (elisp.read " 1  "))
            (assert.are.equals 0.5 (elisp.read "  0.5"))
            (assert.are.equals 30 (elisp.read "   30 "))
            (assert.are.equals 30.2 (elisp.read "   30.2 "))
            (assert.are.equals 0.2 (elisp.read ".2 "))
            (assert.are.equals -0.3 (elisp.read "   -.3 "))
            (assert.are.equals -20.25 (elisp.read "   -20.25 "))))
        (it "lists"
          (fn []
            (assert.same [] (elisp.read "()"))
            (assert.same [ [] [] ] (elisp.read "(()())"))
            (assert.same [1 [2 3 4] 5 [6 :seven] :eight 9] (elisp.read "(1 (2 3 4) 5 (6 \"seven\") :eight 9)"))
            (assert.same [1 2 3] (elisp.read "(1 2 3)"))))
        (it "nested forms"
          (fn []
            (assert.same
              ["Class" ": " ["value" "clojure.lang.PersistentArrayMap" 0] ["newline"]
               "Contents: " ["newline"]
               "  " ["value" "a" 1] " = " ["value" "1" 2] ["newline"]
               "  " ["value" "b" 3] " = " ["value" "2" 4] ["newline"]]
              (elisp.read "(\"Class\" \": \" (:value \"clojure.lang.PersistentArrayMap\" 0) (:newline) \"Contents: \" (:newline) \"  \" (:value \"a\" 1) \" = \" (:value \"1\" 2) (:newline) \"  \" (:value \"b\" 3) \" = \" (:value \"2\" 4) (:newline))"))))))))
