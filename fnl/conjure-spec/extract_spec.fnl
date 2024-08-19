(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local extract (require :conjure.extract))
(local nvim (require :conjure.aniseed.nvim))

(describe "extract"
  (fn []
    ;; Three functions to approximate the functionality in
    ;; legacy-aniseed-tests/fnl/conjure/test/buffer.fnl.

    ;; A function to position the cursor in the buffer.
    (fn at [cursor]
      (nvim.win_set_cursor 0 cursor))

    ;; Set up a buffer with lines to use for tests.
    (fn setup [lines]
      (nvim.ex.silent_ :syntax :on)
      (nvim.ex.silent_ :filetype :on)
      (nvim.ex.silent_ :set :filetype :clojure)
      (nvim.ex.silent_ :edit (.. (nvim.fn.tempname) "_test.clj"))
      (nvim.buf_set_lines 0 0 -1 false lines))

    ;; Delete the buffer used for tests.
    (fn teardown []
      (nvim.ex.silent_ :bdelete!))

    ;; Test groups.
    (describe "current-form"
      (fn []
        (setup ["(ns foo)"
                ""
                "(+ 10 20 (* 10 2))"])

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
                         (extract.form {}))))

        (teardown)))

  (describe "root-form"
    (fn []
      (setup ["(ns foo)"
              ""
              "(+ 10 20 (* 10 2))"])

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
          (assert.equals nil (extract.form {:root? true}))))

      (teardown)))

  (describe "ignoring-comments"
    (fn []
      (setup ["(ns ohno)"
              ""
              "(inc"
              " ; ()"
              " 5)"])

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
                 (extract.form {:root? true}))))

      (teardown)))

  (describe "escaped-parens"
    (fn []
      (setup ["(str \\))"])

      (it "escaped parens are skipped over"
        (fn []
          (at [1 0])
          (assert.same {:range {:start [1 0]
                          :end [1 7]}
                  :content "(str \\))"}
                 (extract.form {}))))

      (teardown)

      ;; https://github.com/Olical/conjure/issues/246
      (setup ["(ns foo)"
              ""
              "(+ 10 20 (* 10 2))"
              ""
              "(+ 1 2)"
              "; )"
              ""
              "(+ 4 6)"])

      (it "root from a form with a commented closing paren on the next line"
        (fn []
          (at [5 2])
          (assert.same {:range {:start [5 0]
                                :end [5 6]}
                        :content "(+ 1 2)"}
                 (extract.form {:root? true}))))

      (teardown)))))

