(local {: describe : it : before-each } (require :plenary.busted))
(local assert (require :luassert.assert))
(local client (require :conjure.client))

(describe "multiple-states? before a change"
  (fn []
    (it "returns false before the first change"
      (fn []
        (assert.is_false (client.multiple-states?))))))

(describe "state-key"
  (fn []
    (it "can be executed to get the current state key"
      (fn []
        (assert.equal :default (client.state-key))))))

(describe "set-state-key!"
  (fn []
    (it "changes the state key value"
      (fn []
        (client.set-state-key! :new-key)
        (assert.equal :new-key (client.state-key))))))

(describe "multiple-states? after a change"
  (fn []
    (it "returns true after the first change"
      (fn []
        (assert.is_true (client.multiple-states?))))))

;; TODO Carry on with this file!
; (describe "new-state"
;   (fn []
;     ))
