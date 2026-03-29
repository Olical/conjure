(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local server (require :conjure.client.clojure.nrepl.server))
(local state (require :conjure.client.clojure.nrepl.state))
(local core (require :nfnl.core))

(fn make-conn [opts]
  "Create a minimal mock conn object for testing."
  (core.merge
    {:ready? false
     :pending-evals []
     :setup-timeout nil
     :host "localhost"
     :port 12345
     :session "test-session"
     :describe {}
     :seen-ns {}
     :send (fn [])
     :destroy (fn [])}
    opts))

(fn set-conn! [conn]
  (core.assoc (state.get) :conn conn))

(fn clear-conn! []
  (core.assoc (state.get) :conn nil))

(describe "client.clojure.nrepl.server"
  (fn []

    (describe "with-conn-or-warn"
      (fn []
        (it "calls f when conn exists"
          (fn []
            (set-conn! (make-conn))
            (var called? false)
            (server.with-conn-or-warn (fn [_conn] (set called? true)))
            (assert.is_true called?)
            (clear-conn!)))

        (it "does not call f when no conn"
          (fn []
            (clear-conn!)
            (var called? false)
            (server.with-conn-or-warn (fn [_conn] (set called? true)) {:silent? true})
            (assert.is_false called?)))))

    (describe "with-conn-ready-or-queue"
      (fn []
        (it "calls f immediately when conn is ready"
          (fn []
            (set-conn! (make-conn {:ready? true}))
            (var called? false)
            (server.with-conn-ready-or-queue (fn [_conn] (set called? true)))
            (assert.is_true called?)
            (clear-conn!)))

        (it "queues f when conn is not ready"
          (fn []
            (let [conn (make-conn {:ready? false})]
              (set-conn! conn)
              (var called? false)
              (server.with-conn-ready-or-queue (fn [_conn] (set called? true)))
              (assert.is_false called?)
              (assert.are.equals 1 (length conn.pending-evals))
              (clear-conn!))))

        (it "does not call f or queue when no conn"
          (fn []
            (clear-conn!)
            (var called? false)
            (server.with-conn-ready-or-queue (fn [_conn] (set called? true)) {:silent? true})
            (assert.is_false called?)))))

    (describe "mark-ready!"
      (fn []
        (it "sets ready? and drains pending evals in order"
          (fn []
            (let [conn (make-conn {:ready? false})
                  results []]
              (set-conn! conn)
              (table.insert conn.pending-evals (fn [_conn] (table.insert results :first)))
              (table.insert conn.pending-evals (fn [_conn] (table.insert results :second)))
              (table.insert conn.pending-evals (fn [_conn] (table.insert results :third)))
              (server.mark-ready!)
              (assert.is_true conn.ready?)
              (assert.same [:first :second :third] results)
              (assert.are.equals 0 (length conn.pending-evals))
              (clear-conn!))))

        (it "is idempotent — second call is a no-op"
          (fn []
            (let [conn (make-conn {:ready? false})
                  call-count {:n 0}]
              (set-conn! conn)
              (table.insert conn.pending-evals (fn [_conn] (set call-count.n (+ call-count.n 1))))
              (server.mark-ready!)
              (assert.are.equals 1 call-count.n)
              ;; Second call should not drain again.
              (table.insert conn.pending-evals (fn [_conn] (set call-count.n (+ call-count.n 1))))
              (server.mark-ready!)
              ;; The second pending-eval should NOT have been drained by mark-ready!
              ;; because ready? is already true.
              (assert.are.equals 1 call-count.n)
              (clear-conn!))))

        (it "no-ops when no conn exists"
          (fn []
            (clear-conn!)
            ;; Should not error.
            (server.mark-ready!)))))

    (describe "connected?"
      (fn []
        (it "returns true when conn exists"
          (fn []
            (set-conn! (make-conn))
            (assert.is_true (server.connected?))
            (clear-conn!)))

        (it "returns false when no conn"
          (fn []
            (clear-conn!)
            (assert.is_false (server.connected?))))))

    (describe "un-comment"
      (fn []
        (it "strips leading #_ from code"
          (fn []
            (assert.are.equals "(+ 1 2)" (server.un-comment "#_(+ 1 2)"))))

        (it "leaves code without #_ unchanged"
          (fn []
            (assert.are.equals "(+ 1 2)" (server.un-comment "(+ 1 2)"))))

        (it "returns nil for nil input"
          (fn []
            (assert.are.equals nil (server.un-comment nil))))))))
