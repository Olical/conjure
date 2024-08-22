(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local a (require :nfnl.core))
(local promise (require :conjure.promise))

(describe "conjure.promise"
  (fn []
    (describe "basics"
      (let [p (promise.new)]
        (fn []
          (it "starts incomplete"
            (fn []
              (assert.are.equals false (promise.done? p))))
          (it "done after deliver"
            (fn []
              (promise.deliver p :foo)
              (assert.are.equals true (promise.done? p))))
          (it "returns the value on close"
            (fn []
              (assert.are.equals :foo (promise.close p)))))))

    (describe "multiple-deliveries"
      (fn []
        (let [p (promise.new)]
          (it "only the first delivery works"
            (fn []
              (promise.deliver p :foo)
              (promise.deliver p :bar)
              (assert.are.equals :foo (promise.close p)))))))

    (describe "async"
      (let [p (promise.new)
            del (promise.deliver-fn p)]
        (vim.schedule (fn [] (del :later)))
        (fn []
          (it "async delivery hasn't happened yet"
            (fn []
              (assert.are.equals false (promise.done? p))))
          (it "await returns 0 from wait()"
            (fn []
              (assert.are.equals 0 (promise.await p))))
          (it "complete after await"
            (fn []
              (assert.are.equals true (promise.done? p))))
          (it "value is correct"
            (fn []
              (assert.are.equals :later (promise.close p)))))))
))
