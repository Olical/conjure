(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local action (require :conjure.client.clojure.nrepl.action))
(local state (require :conjure.client.clojure.nrepl.state))
(local core (require :conjure.nfnl.core))
(local log (require :conjure.log))
(require :conjure.client.clojure.nrepl)

(describe "client.clojure.nrepl.action"
  (fn []
    (describe "extract-test-name-from-form"
      (fn []
        ;; Simulate config items with [:test :current_form_names] for clojure client.
        (set vim.g.conjure#client#clojure#nrepl#test#current_form_names [:deftest])

        (it "deftest form with missing name"
          (fn []
            (assert.are.equals nil (action.extract-test-name-from-form ""))))
        (it "normal deftest form"
          (fn []
            (assert.are.equals "foo" (action.extract-test-name-from-form "(deftest foo (+ 10 20))"))))
        (it "deftest form with extra spaces"
          (fn []
            (assert.are.equals "foo" (action.extract-test-name-from-form "(   deftest  foo  (+ 10 20))"))))
        (it "deftest form with metadata"
          (fn []
            (assert.are.equals "foo" (action.extract-test-name-from-form "(deftest ^:kaocha/skip foo :xyz)"))))))

    (describe "clojure->vim-completion"
      (fn []
        (it "uses the full nREPL type as the kind"
          (fn []
            (each [_ t (ipairs [:function :macro :special-form :var :local
                                :namespace :class :keyword :resource :method
                                :static-method :field :static-field :data-reader])]
              (assert.are.equals
                t
                (. (action.clojure->vim-completion {:candidate "x" :type t}) :kind)))))

        (it "has no kind when the type is missing or empty"
          (fn []
            (assert.is_nil (. (action.clojure->vim-completion {:candidate "x"}) :kind))
            (assert.is_nil (. (action.clojure->vim-completion {:candidate "x" :type ""}) :kind))))

        (it "builds the menu and info from the other fields"
          (fn []
            (assert.same
              {:word "map"
               :menu "clojure.core ([f coll]) ([f c1 c2])"
               :info "Returns a lazy sequence."
               :kind "function"}
              (action.clojure->vim-completion
                {:candidate "map"
                 :type "function"
                 :ns "clojure.core"
                 :doc "Returns a lazy sequence."
                 :arglists ["([f coll])" "([f c1 c2])"]}))))))

    (describe "interrupt"
      (fn []
        (local current-session "c0ffee00-0000-4000-8000-000000000001")
        (local eval-session "e7a10000-0000-4000-8000-000000000002")
        (local other-session "07e40000-0000-4000-8000-000000000003")

        (fn pending-msg [id op session sent-at code]
          {:msg {:id id :op op :session session :code code}
           :sent-at sent-at})

        (fn interrupt-with-pending-msgs [pending-msgs]
          (let [sent []
                logged []
                original-append log.append
                conn {:ready? true
                      :session current-session
                      :state {:msgs pending-msgs}
                      :send (fn [msg cb]
                              (table.insert sent msg)
                              (when (= :eval msg.op)
                                (cb {:value "clj" :status {:done true}})))}]
            (set log.append (fn [lines] (each [_ line (ipairs lines)] (table.insert logged line))))
            (core.assoc (state.get) :conn conn)
            (action.interrupt)
            (core.assoc (state.get) :conn nil)
            (set log.append original-append)
            {:interrupts (core.map
                           #(core.select-keys $1 [:op :interrupt-id :session])
                           (core.filter #(= :interrupt (. $1 :op)) sent))
             : logged}))

        (it "targets the oldest pending eval with its id and session"
          (fn []
            (let [{: interrupts : logged}
                  (interrupt-with-pending-msgs
                    {"eval-new" (pending-msg "eval-new" :eval other-session 200 "(new)")
                     "eval-old" (pending-msg "eval-old" :eval eval-session 100 "(Thread/sleep 20000)")
                     "describe" (pending-msg "describe" :describe current-session 50)})]
              (assert.same
                [{:op :interrupt :interrupt-id "eval-old" :session eval-session}]
                interrupts)
              (assert.same ["; Interrupted: (Thread/sleep 20000)"] logged))))

        (it "interrupts the current session without an interrupt-id when no eval is pending"
          (fn []
            (let [{: interrupts : logged} (interrupt-with-pending-msgs {})]
              (assert.same [{:op :interrupt :session current-session}] interrupts)
              (assert.is_truthy (string.find (core.first logged) "^; Interrupted: session: ")))))))))
