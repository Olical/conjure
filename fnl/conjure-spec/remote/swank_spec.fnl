(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local swank (require :conjure.remote.swank))

(describe "conjure.remote.swank"
  (fn []
    (describe "message-id"
      (fn []
        (it "reads the kind and id of requests and returns"
          (fn []
            (assert.same [":return" "12"]
                         [(swank.message-id "(:return (:ok (\"\" \"(1 2)\")) 12)")])
            (assert.same [":emacs-rex" "3"]
                         [(swank.message-id "(:emacs-rex (swank:eval-and-grab-output \"1\") \"*package*\" t 3)")])))

        (it "returns nil for events without an id"
          (fn []
            (assert.is_nil (swank.message-id "(:debug-activate 42 1 nil)"))))))

    (describe "split-messages"
      (fn []
        (it "splits coalesced messages and keeps a partial one for later"
          (fn []
            (let [(msgs rest) (swank.split-messages "000003abc000002de00000")]
              (assert.same ["abc" "de"] msgs)
              (assert.are.equal "00000" rest))))

        (it "waits for the rest of a message split across reads"
          (fn []
            (let [(msgs rest) (swank.split-messages "000005ab")]
              (assert.same [] msgs)
              (assert.are.equal "000005ab" rest))))))))
