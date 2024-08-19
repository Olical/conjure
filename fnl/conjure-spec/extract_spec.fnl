(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local extract (require :conjure.extract))
(local {: with-buf} (require :conjure-spec.util))

(describe :extract
  (fn []
    (describe :current-form
      (fn []
        (with-buf ["(ns foo)" "" "(+ 10 20 (* 10 2))"]
          (fn [at]
            (it "inside the form"
              (fn []
                (at [3 10])
                (assert.same {:range {:start [3 9]
                                      :end [3 16]}
                              :content "(* 10 2)"}
                              (extract.form {}))))
            (it "on the opening paren"
              (fn []
                (at [3 9])
                (assert.same {:range {:start [3 9]
                                      :end [3 16]}
                              :content "(* 10 2)"}
                              (extract.form {}))))
            (it "on the closing paren"
              (fn []
                (at [3 16])
                (assert.same {:range {:start [3 9]
                                      :end [3 16]}
                              :content "(* 10 2)"}
                              (extract.form {}))))
            (it "one before the inner form"
              (fn []
                (at [3 8])
                (assert.same {:range {:start [3 0]
                                      :end [3 17]}
                              :content "(+ 10 20 (* 10 2))"}
                              (extract.form {}))))
            (it "on the last paren of the outer form"
              (fn []
                (at [3 17])
                (assert.same {:range {:start [3 0]
                                      :end [3 17]}
                              :content "(+ 10 20 (* 10 2))"}
                              (extract.form {}))))
            (it "matching nothing"
              (fn []
                (at [2 0])
                (assert.are.equals nil (extract.form {}))))
            (it "ns form"
              (fn []
                (at [1 0])
                (assert.same {:range {:start [1 0]
                                      :end [1 7]}
                              :content "(ns foo)"}
                              (extract.form {}))))))))
    (describe :root-form
      (fn []
        (with-buf ["(ns foo)" "" "(+ 10 20 (* 10 2))"]
          (fn [at]
            (it "root from inside a child form"
                (fn []
                  (at [3 10])
                  (assert.same {:range {:start [3 0]
                                        :end [3 17]}
                                :content "(+ 10 20 (* 10 2))"}
                                (extract.form {:root? true}))))
            (it "root from the root"
              (fn []
                (at [3 6])
                (assert.same {:range {:start [3 0]
                                      :end [3 17]}
                              :content "(+ 10 20 (* 10 2))"}
                              (extract.form {:root? true}))))
            (it "root from the opening paren of the root"
              (fn []
                (at [3 0])
                (assert.same {:range {:start [3 0]
                                      :end [3 17]}
                              :content "(+ 10 20 (* 10 2))"}
                              (extract.form {:root? true}))))
            (it "root from the opening paren of the child form"
              (fn []
                (at [3 9])
                (assert.same {:range {:start [3 0]
                                      :end [3 17]}
                              :content "(+ 10 20 (* 10 2))"}
                              (extract.form {:root? true}))))
            (it "matching nothing for root"
              (fn []
                (at [2 0])
                (assert.equals nil
                                (extract.form {:root? true}))))))))
    (describe :ignoring-comments
      (fn []
        (with-buf ["(ns ohno)" "" "(inc" " ; ()" " 5)"]
          (fn [at]
            (it "skips the comment paren with current form"
              (fn []
                (at [4 0])
                (assert.same {:range {:start [3 0]
                                      :end [5 2]}
                              :content "(inc\n ; ()\n 5)"}
                              (extract.form {}))))
            (it "skips the comment paren with root form"
              (fn []
                (at [4 0])
                (assert.same {:range {:start [3 0]
                                      :end [5 2]}
                              :content "(inc\n ; ()\n 5)"}
                              (extract.form {:root? true}))))))))
    (describe :escaped-parens
      (fn []
        (with-buf ["(str \\))"]
          (fn [at]
            (it "escaped parens are skipped over"
              (fn []
                (at [1 0])
                (assert.same {:range {:start [1 0]
                                      :end [1 7]}
                              :content "(str \\))"}
                              (extract.form {}))))))
        (with-buf
          ["(ns foo)"
           ""
           "(+ 10 20 (* 10 2))"
           ""
           "(+ 1 2)"
           "; )"
           ""
           "(+ 4 6)"]
          (fn [at]
            ;; https://github.com/Olical/conjure/issues/246
            (it "root from a form with a commented closing paren on the next line"
              (fn []
                (at [5 2])
                (assert.same {:range {:start [5 0]
                                      :end [5 6]}
                              :content "(+ 1 2)"}
                              (extract.form {:root? true}))))))))))
