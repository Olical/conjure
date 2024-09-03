(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))

(local dyn (require :conjure.dynamic))

(describe "conjure.dynamic"
  (fn []
    (describe "new-and-unbox"
      (fn []
        (let [foo (dyn.new #(do :bar))]
          (it "new returns a function"
              (fn []
                (assert.are.equals :function (type foo))))
          (it "function is wrapped"
              (fn []
                (assert.are.equals :bar (foo)))))))

    (describe "bind"
      (fn []
        (let [foo (dyn.new #(do 1))]
          (it "one level deep"
              (fn []
                (assert.are.equals 1 (foo))))
          (it "two levels deep"
              (fn []
                (dyn.bind
                  {foo #(do 2)}
                  (fn [expected]
                    (assert.are.equals expected (foo)))
                  2)))
          (it "no more than two levels deep"
              (fn []
                (dyn.bind
                  {foo #(do 2)}
                  (fn []
                    (assert.are.equals 2 (foo))
                    (dyn.bind
                      {foo #(do 3)}
                      (fn []
                        (assert.are.equals 3 (foo))))
                    (dyn.bind
                      {foo #(error "OHNO")}
                      (fn []
                        (let [(ok? result) (pcall foo)]
                          (assert.are.equals false ok?)
                          (assert.are.equals result "OHNO"))))
                    (assert.are.equals 2 (foo)))))))))

    (describe "set!"
      (fn []
        (let [foo (dyn.new #(do 1))]
          (it "one level deep"
              (fn []
                (assert.are.equals (foo) 1)))
          (it "more than two levels deep"
              (fn []
                (dyn.bind
                  {foo #(do 2)}
                  (fn []
                    (assert.are.equals (foo) 2)
                    (assert.are.equals nil (dyn.set! foo #(do 3)))
                    (assert.are.equals (foo) 3))))))))

    (describe "set-root!"
      (fn []
        (let [foo (dyn.new #(do 1))]
          (it "one level deep"
              (fn []
                (assert.are.equals (foo) 1)))
          (it "three levels deep"
              (fn []
                (dyn.bind
                  {foo #(do 2)}
                  (fn []
                    (assert.are.equals (foo) 2)
                    (assert.are.equals nil (dyn.set-root! foo #(do 3)))
                    (assert.are.equals (foo) 2)))))
          (it "remembers binding from three levels deep"
              (fn []
                (assert.are.equals (foo) 3)))
          (it "four levels deep"
              (fn []
                (dyn.set-root! foo #(do 4))))
          (it "remembers binding from four levels deep"
              (fn []
                (assert.are.equals (foo) 4))))))

    (describe "type-guard"
      (fn []
        (let [(ok? result) (pcall dyn.new :foo)]
          (it "direct call of conjure.dynamic value fails"
              (fn []
                (assert.are.equals false ok?)
                ))
          (it "returns why failed"
              (fn []
                (assert.is_not_nil (string.match result "conjure.dynamic values must always be wrapped in a function"))
                nil)))))))
