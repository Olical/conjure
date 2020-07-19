(module conjure.extract-test
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
