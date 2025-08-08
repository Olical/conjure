(local {: describe : it } (require :plenary.busted))
(local assert (require :luassert.assert))
(local guile (require :conjure.client.guile.socket))
(local config (require :conjure.config))
(local fake-socket (require :conjure-spec.client.guile.fake-socket))
(require :conjure-spec.assertions)

(local completion-code-define-match "%(define%* %(%%conjure:get%-guile%-completions")

(fn set-repl-connected 
  [repl]
  (tset repl :status :connected))

(fn set-repl-busy
  [repl]
  (tset repl :current "some command"))

(describe "conjure.client.guile.socket"
  (fn []
    (tset package.loaded "conjure.remote.socket" fake-socket)
    (tset guile :valid-str? (fn [_] true))

    (describe "context extraction"
      (fn [] 
        (it "returns nil for hello world"
            (fn []
              (assert.are.equal nil (guile.context "(print \"Hello World\")"))))
        (it "returns (my-module) for (define-module (my-module))"
            (fn []
              (assert.are.equal "(my-module)" (guile.context "(define-module (my-module))"))))
        (it "returns (my-module) for (define-module\\n(my-module))"
            (fn []
              (assert.are.equal "(my-module)" (guile.context "(define-module\n(my-module))"))))
        (it "returns (my-module spaces) for (define-module ( my-module  spaces   ))"
            (fn []
              (assert.are.equal "(my-module spaces)" (guile.context "(define-module ( my-module  spaces   ))"))))
        (it "returns nil for ;(define-module (my-module))"
            (fn []
              (assert.are.equal nil (guile.context ";(define-module (my-module))"))))
        (it "returns nil for (define-m;odule (my-module))"
            (fn []
              (assert.are.equal nil (guile.context "(define-m;odule (my-module))"))))
        (it "returns (another-module) for ;\\n(define-module ( another-module ))"
            (fn []
              (assert.are.equal "(another-module)" (guile.context ";\n(define-module ( another-module ))"))))
        (it "returns (a-module specification) for ;\\n(define-module\\n;some comments\\n( a-module\\n; more comments\\n specification))"
            (fn []
              (assert.are.equal "(a-module specification)" (guile.context ";\n(define-module\n;some comments\n( a-module\n; more comments\n specification))"))))))

    (describe "parse-guile-result"
      (fn []
        (it "returns a result in the simple happy path"
          (fn []
            (assert.are.same
              {:done? true
               :error? false
               :result "1234"}
              (guile.parse-guile-result "$1 = 1234\nscheme@(guile-user)> "))))

        (it "handles single line output from display, missing a newline"
          (fn []
            (let [stray-output []
                  capture-stray-output (fn [output]
                                        (table.insert stray-output output))]
              (assert.are.same
                {:done? true
                 :error? false
                 :result nil}
                (guile.parse-guile-result "hischeme@(guile-user)> " capture-stray-output))
              (assert.are.same
                [["; (out) hi"]]
                stray-output))))
        
        (it "prompts with an error number report as an error"
          (fn []
            (assert.are.same
              {:done? true
               :error? true}
              (guile.parse-guile-result "scheme@(guile-user) [1]> "))))))

    (describe "eval-str" 
      (fn []
        (config.merge {:client {:guile {:socket
                        {:pipename "fake-pipe" :host_port nil}}}}
                      {:overwrite? true})
        (it "does eval string when valid-str? returns true"
            (fn []
              (let [expected-code "(valid form)"
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl (fake-socket.build-fake-repl spy-send)]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.eval-str {:code expected-code :context nil})
                (guile.disconnect)

                (assert.are.equal (.. ",m (guile-user)\n" expected-code) (. calls 3)))))

        (it "does not eval string when valid-str? returns false"
            (fn []
              (let [calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl (fake-socket.build-fake-repl spy-send)]
                (tset guile :valid-str? (fn [_] false))
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.eval-str {:code "(some invalid form" :context nil})
                (guile.disconnect)

                (assert.same [] calls)
                (tset guile :valid-str? (fn [_] true)))))))

    (describe "module initialization"
      (fn []
        (config.merge {:client {:guile {:socket
                        {:pipename "fake-pipe" :host_port nil}}}}
                      {:overwrite? true})
        (it "initializes (guile-user) when eval-str called on new repl in nil context"
            (fn []
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl (fake-socket.build-fake-repl spy-send)
                    expected-code "(print \"Hello world\")"]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.eval-str {:code expected-code :context nil})
                (guile.disconnect)

                (assert.are.equal ",m (guile-user)\n,import (guile)" (. calls 1))
                (assert.has-substring completion-code-define-match (. calls 2))
                (assert.are.equal (.. ",m (guile-user)\n" expected-code) (. calls 3)))))

        (it "initializes (guile-user) once when eval-str called twice on repl in nil context"
            (fn []
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl (fake-socket.build-fake-repl spy-send)
                    expected-code "(print \"Hello second call\")"]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.eval-str {:code "(first-call)" :context nil})
                (guile.eval-str {:code expected-code :context nil})
                (guile.disconnect)

                (assert.are.equal (.. ",m (guile-user)\n" expected-code) (. calls 4)))))

        (it "initializes (guile-user) again when eval-str disconnect eval-str is called in nil context"
            (fn []
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl (fake-socket.build-fake-repl spy-send)
                    expected-code "(print \"Hello second call\")"]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.eval-str {:code "(first-call)" :context nil})
                (guile.disconnect)
                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.eval-str {:code expected-code :context nil})
                (guile.disconnect)

                (assert.are.equal ",m (guile-user)\n,import (guile)" (. calls 4))
                (assert.has-substring completion-code-define-match (. calls 5))
                (assert.are.equal (.. ",m (guile-user)\n" expected-code) (. calls 6)))))

        (it "initializes (a-module) when eval-str in (guile-user) then eval-str in (a-module)"
            (fn []
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl {:send spy-send :status nil :destroy (fn [])}
                    expected-module "a-module"
                    expected-code "(print \"Hello second call\")"]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.eval-str {:code "(first-call)" :context nil})
                (guile.eval-str {:code expected-code :context expected-module})
                (guile.disconnect)

                (assert.are.equal (..  ",m " expected-module "\n,import (guile)") (. calls 4))
                (assert.has-substring completion-code-define-match (. calls 5))
                (assert.are.equal (.. ",m " expected-module "\n" expected-code) (. calls 6)))))))

    (describe "completions"
      (fn [] 
        (config.merge {:client {:guile {:socket
                         {:pipename "fake-pipe" :host_port nil}}}}
                      {:overwrite? true})
        (it "Does not execute completions in REPL when not connected"
            (fn []
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl (fake-socket.build-fake-repl spy-send)
                    callback-results  []
                    fake-callback (fn [result] (table.insert callback-results result))]
                (fake-socket.set-fake-repl fake-repl)

                (guile.completions {:cb fake-callback :prefix "something"})

                (assert.same [] calls)
                (assert.same [] (. callback-results 1)))))

        (it "Executes completions in REPL for prefix d with result define"
            (fn []
              (let [
                    calls []
                    spy-send (fn [call callback] (table.insert calls {:code call :callback callback}))
                    fake-repl {:send spy-send :status nil :destroy (fn [])}
                    expected-code "%(%%conjure:get%-guile%-completions \"d\"%)"
                    callback-results  []
                    fake-callback (fn [result] (table.insert callback-results result))]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.completions {:cb fake-callback :prefix "d"})
                (let [completion-call (. calls 3)]
                  ((. completion-call :callback) [{:out "(\"define\")"}])
                  (guile.disconnect)

                  (assert.has-substring expected-code (. completion-call :code))
                  (assert.same ["define"] (. callback-results 1))))))

        (it "Puts last completion first for prefix fu with results fun func and future"
            (fn []
              (let [
                    sent-callbacks []
                    spy-send (fn [_ callback] (table.insert sent-callbacks callback))
                    fake-repl (fake-socket.build-fake-repl spy-send)
                    callback-results  []
                    fake-callback (fn [result] (table.insert callback-results result))]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.completions {:cb fake-callback :prefix "fu"})
                ((. sent-callbacks 3) [{:out "(\"fun\" \"func\" \"future\")"}])
                (guile.disconnect)

                (assert.same ["future" "fun" "func"] (. callback-results 1)))))))

    (describe "enable completions config setting"
      (fn [] 
        (it "Does not load completion code when completions disabled in config"
            (fn []
              (config.merge {:client {:guile {:socket
                               {:pipename "fake-pipe" :host_port nil
                                :enable_completions false }}}}
                            {:overwrite? true})
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl {:send spy-send :status nil :destroy (fn [])}
                    expected-code "(print \"Hello world\")"]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.eval-str {:code expected-code :context nil})
                (guile.disconnect)

                (assert.are.equal ",m (guile-user)\n,import (guile)" (. calls 1))
                (assert.are.equal (.. ",m (guile-user)\n" expected-code) (. calls 2)))))

        (it "Does load completion code when completions enabled in config"
            (fn []
              (config.merge {:client {:guile {:socket
                               {:pipename "fake-pipe" :host_port nil
                                :enable_completions true}}}}
                            {:overwrite? true})
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl (fake-socket.build-fake-repl spy-send)
                    expected-code "(print \"Hello world\")"]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.eval-str {:code expected-code :context nil})
                (guile.disconnect)

                (assert.are.equal ",m (guile-user)\n,import (guile)" (. calls 1))
                (assert.has-substring completion-code-define-match (. calls 2))
                (assert.are.equal (.. ",m (guile-user)\n" expected-code) (. calls 3)))))

        (it "Does not execute completions in REPL when connected but completions disabled"
            (fn []
              (config.merge {:client {:guile {:socket
                               {:pipename "fake-pipe" :host_port nil
                                :enable_completions false}}}}
                            {:overwrite? true})
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl {:send spy-send :status nil :destroy (fn [])}
                    callback-results  []
                    fake-callback (fn [result] (table.insert callback-results result))]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (guile.completions {:cb fake-callback :prefix "something"})
                (guile.disconnect)

                (assert.same [] calls)
                (assert.same [] (. callback-results 1)))))

        (it "Does not execute completions in REPL when connected but busy"
            (fn []
              (config.merge {:client {:guile {:socket
                               {:pipename "fake-pipe" :host_port nil
                                :enable_completions true}}}}
                            {:overwrite? true})
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl {:send spy-send :status nil :destroy (fn [])}
                    callback-results  []
                    fake-callback (fn [result] (table.insert callback-results result))]
                (fake-socket.set-fake-repl fake-repl)

                (guile.connect {})
                (set-repl-connected fake-repl)
                (set-repl-busy fake-repl)
                (guile.completions {:cb fake-callback :prefix "something"})
                (guile.disconnect)

                (assert.same [] calls)
                (assert.same [] (. callback-results 1)))))))))
