(local {: describe : it } (require :plenary.busted))
(local assert (require :luassert.assert))
(local scheme (require :conjure.client.scheme.stdio))
(local mock-stdio (require :conjure-spec.client.scheme.mock-stdio))

(describe "conjure.client.scheme.stdio"
  (fn []
    (tset package.loaded "conjure.remote.stdio" mock-stdio)

    (it "eval-str sends code to repl when parses"
      (fn [] 
        (let [expected-code "(some code)"
              send-calls [] 
              mock-send (fn [val] (table.insert send-calls val))]
          (tset scheme :valid-str? (fn [_] true))
          (mock-stdio.set-mock-send mock-send) 

          (scheme.start)
          (scheme.eval-str {:code expected-code})
          (scheme.stop)

          (assert.same [(.. expected-code "\n")] send-calls))))

    (it "eval-str does not send code to repl when valid-str? returns false"
      (fn [] 
        (let [send-calls [] 
              mock-send (fn [val] (table.insert send-calls val))]
          (tset scheme :valid-str? (fn [_] false))
          (mock-stdio.set-mock-send mock-send) 

          (scheme.start)
          (scheme.eval-str {:code "(some invalid form"})
          (scheme.stop)

          (assert.same [] send-calls))))))


