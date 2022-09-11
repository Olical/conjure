(module conjure.remote.transport.slynk-test
  {require {trn conjure.remote.transport.slynk}})

(deftest encode
  (t.= "000007foobar\n" (trn.encode "foobar"))
  (t.= "000004baz\n" (trn.encode "baz")))
            
(deftest decode
  (t.= "foobar" (trn.decode "000007foobar"))
  (t.= "baz" (trn.decode     "000004baz")))

(deftest parse-string-to-nested-list
  (t.pr= [[]]             (trn.parse-string-to-nested-list "()"))
  (t.pr= [ "a" "b" "c"]   (trn.parse-string-to-nested-list "a b c"))
  (t.pr= [ "a" ":b" ":c"] (trn.parse-string-to-nested-list "a :b :c"))
  (t.pr= [ "a" ["b" "c"]] (trn.parse-string-to-nested-list "a (b c)")) 
  (t.pr= [ "a" "(b c)"]   (trn.parse-string-to-nested-list "a \"(b c)\"")))
