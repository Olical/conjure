(module conjure.remote.transport.elisp-test
  {require {elisp conjure.remote.transport.elisp}})

(deftest read
  (t.= nil (elisp.read ""))
  (t.= "foo" (elisp.read "\"foo\""))
  (t.= "foo" (elisp.read "  \"foo\"  "))
  (t.= "foo" (elisp.read ":foo"))
  (t.= "foo" (elisp.read "   :foo    "))
  (t.= "bar" (elisp.read "   :foo \"hi\" \n :bar  "))

  (t.= 0 (elisp.read "0"))
  (t.= 1 (elisp.read " 1  "))
  (t.= 0.5 (elisp.read "  0.5"))
  (t.= 30 (elisp.read "   30 "))
  (t.= 30.2 (elisp.read "   30.2 "))
  (t.= 0.2 (elisp.read ".2 "))
  (t.= -0.3 (elisp.read "   -.3 "))
  (t.= -20.25 (elisp.read "   -20.25 "))

  (t.pr= [] (elisp.read "()"))
  (t.pr= [ [] [] ] (elisp.read "(()())"))
  (t.pr= [1 [2 3 4] 5 [6 :seven] :eight 9] (elisp.read "(1 (2 3 4) 5 (6 \"seven\") :eight 9)"))
  (t.pr= [1 2 3] (elisp.read "(1 2 3)"))

  (t.pr=
    ["Class" ": " ["value" "clojure.lang.PersistentArrayMap" 0] ["newline"]
     "Contents: " ["newline"]
     "  " ["value" "a" 1] " = " ["value" "1" 2] ["newline"]
     "  " ["value" "b" 3] " = " ["value" "2" 4] ["newline"]]
    (elisp.read "(\"Class\" \": \" (:value \"clojure.lang.PersistentArrayMap\" 0) (:newline) \"Contents: \" (:newline) \"  \" (:value \"a\" 1) \" = \" (:value \"1\" 2) (:newline) \"  \" (:value \"b\" 3) \" = \" (:value \"2\" 4) (:newline))")))
