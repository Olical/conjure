(module conjure.promise-test
  {require {promise conjure.promise
            a conjure.aniseed.core}}) 

(deftest basics
  (let [p (promise.new)]
    (t.= false (promise.done? p) "starts incomplete")
    (t.= :table (type (a.get promise.state p))
         "exists in state at first")
    (promise.deliver p :foo)
    (t.= true (promise.done? p) "done after deliver")
    (t.= :foo (promise.close p) "returns the value on close")
    (t.= :nil (type (a.get promise.state p)) "gone after close")
    (promise.deliver p :bar)
    (t.= nil (promise.done? p) "nil if already closed")
    (t.= :nil (type (a.get promise.state p))
         "still nil after second deliver")))

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
