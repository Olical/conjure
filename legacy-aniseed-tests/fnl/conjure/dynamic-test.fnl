(module conjure.dynamic-test
  {require {dyn conjure.dynamic}})

(deftest new-and-unbox
  (let [foo (dyn.new #(do :bar))]
    (t.= :function (type foo))
    (t.= :bar (foo))))

(deftest bind
  (let [foo (dyn.new #(do 1))]
    (t.= 1 (foo))

    (dyn.bind
      {foo #(do 2)}
      (fn [expected]
        (t.= expected (foo)))
      2)

    (dyn.bind
      {foo #(do 2)}
      (fn []
        (t.= 2 (foo))
        (dyn.bind
          {foo #(do 3)}
          (fn []
            (t.= 3 (foo))))
        (dyn.bind
          {foo #(error "OHNO")}
          (fn []
            (let [(ok? result) (pcall foo)]
              (t.= false ok?)
              (t.= result "OHNO"))))
        (t.= 2 (foo))))

    (t.= 1 (foo))))

(deftest set!
  (let [foo (dyn.new #(do 1))]
    (t.= (foo) 1)
    (dyn.bind
      {foo #(do 2)}
      (fn []
        (t.= (foo) 2)
        (t.= nil (dyn.set! foo #(do 3)))
        (t.= (foo) 3)))
    (t.= (foo) 1)))

(deftest set-root!
  (let [foo (dyn.new #(do 1))]
    (t.= (foo) 1)
    (dyn.bind
      {foo #(do 2)}
      (fn []
        (t.= (foo) 2)
        (t.= nil (dyn.set-root! foo #(do 3)))
        (t.= (foo) 2)))
    (t.= (foo) 3)
    (dyn.set-root! foo #(do 4))
    (t.= (foo) 4)))

(deftest type-guard
  (let [(ok? result) (pcall dyn.new :foo)]
    (t.= false ok?)
    (t.ok? (string.match result "conjure.dynamic values must always be wrapped in a function"))))
