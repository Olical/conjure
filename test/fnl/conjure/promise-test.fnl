(module conjure.promise-test
  {require {promise conjure.promise
            a conjure.aniseed.core}}) 

(deftest basics
  (let [p (promise.new)]
    (t.= false (promise.done? p) "starts incomplete")
    (promise.deliver p :foo)
    (t.= true (promise.done? p) "done after deliver")
    (t.= :foo (promise.close p) "returns the value on close")
    (promise.deliver p :bar)
    (t.= nil (promise.done? p) "nil if already closed")))

(deftest multiple-deliveries
  (let [p (promise.new)]
    (promise.deliver p :foo)
    (promise.deliver p :bar)
    (t.= :foo (promise.close p) "only the first delivery works")))

(deftest async
  (let [p (promise.new)
        del (promise.deliver-fn p)]
    (vim.schedule (fn [] (del :later)))
    (t.= false (promise.done? p) "async delivery hasn't happened yet")
    (t.= 0 (promise.await p) "await returns 0 from wait()")
    (t.= true (promise.done? p) "complete after await")
    (t.= :later (promise.close p) "value is correct")))
