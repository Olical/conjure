(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local a (require :nfnl.core))
(local uuid (require :conjure.uuid))

(describe "uuid"
  (fn []
    ;; Helper: Is word in xs?
    (fn is-in [word xs]
      (a.some (fn [x] (= word x)) xs))

    (describe "turns a UUID"
      (fn []
        (it "into something human-readable"
          (fn []
            (assert.are.equals
              "Wirehaired Pointing Griffon"
              (uuid.pretty "c7ef277c-160c-45f4-a5c3-03ac16a93788"))))
        (it "into something human-readable but wrong string"
          (fn []
            (assert.are.not.equals
              "Wirehaired Pointing Griffon"
              (uuid.pretty "d7ef277c-160c-45f4-a5c3-03ac16a93788"))))))

    (describe "generated UUID"
      (fn []
        (it "is turned into something human-readable"
          (fn []
            (assert.are.equals
              true
              (is-in (uuid.pretty (uuid.v4))
                     uuid.cats-and-dogs))))
        (it "has the correct format"
          (fn []
            (assert.are.not.equals
              nil
              (string.match
                (uuid.v4)
                "^%x+-%x+-%x+-%x+-%x+$"))))))))
