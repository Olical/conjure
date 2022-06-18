(module conjure.stack-test
  {require {stack conjure.stack}})

(deftest push
  (t.pr= [1 2 3] (-> (stack.push [] 1)
                     (stack.push 2)
                     (stack.push 3))))

(deftest pop
  (t.pr= [1 2] (stack.pop [1 2 3]))
  (t.pr= [] (stack.pop [])))

(deftest peek
  (t.= 3 (stack.peek [1 2 3]))
  (t.= nil (stack.peek [])))
