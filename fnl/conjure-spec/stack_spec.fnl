(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))

(local stack (require :conjure.stack))



;;;;;;;;;;
;;; module/file being tested
(describe "conjure.stack"
  (fn []
    (describe "push"
      (fn []
        (it "item on a stack"
          (fn []
            (assert.same [1 2 3] (-> (stack.push [] 1)
                                     (stack.push 2)
                                     (stack.push 3)))))))

    (describe "pop"
      (fn []
        (it "top of stack"
          (fn []
            (assert.same [1 2] (stack.pop [1 2 3]))))

        (it "empty stack"
          (fn []
            (assert.same [] (stack.pop []))))))

    (describe "peek"
      (fn []
        (it "top of stack"
          (fn []
            (assert.are.equals 3 (stack.peek [1 2 3]))))

        (it "empty stack"
          (fn []
            (assert.are.equals nil (stack.peek []))))
        ))))
