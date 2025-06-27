(local {: describe : it : spy} (require :plenary.busted))
(local assert (require :luassert.assert))
(local guile (require :conjure.client.guile.socket))
(local config (require :conjure.config))
(local fake-socket (require :conjure-spec.client.guile.fake-socket))


(describe "conjure.client.guile.socket"
  (fn []
    (tset package.loaded "conjure.remote.socket" fake-socket)
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
        (it "returns (another-module) for ;\n(define-module ( another-module ))"
            (fn []
              (assert.are.equal "(another-module)" (guile.context ";\n(define-module ( another-module ))"))))
        (it "returns (a-module specification) for ;\\n(define-module\\n;some comments\\n( a-module\\n; more comments\\n specification))"
            (fn []
              (assert.are.equal "(a-module specification)" (guile.context ";\n(define-module\n;some comments\n( a-module\n; more comments\n specification))"))))))

    (describe "module initialization"
      (fn []
        (config.merge {:client {:guile {:socket
                      {:pipename "fake-pipe" :host-port nil}}}})
        (it "initializes (guile-user) when eval-str called on new repl in nil context"
            (fn []
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl {:send spy-send :status nil :destroy (fn [])}
                    expected-code "(print \"Hello world\")"]

                (fake-socket.set-fake-repl fake-repl)
                (guile.connect {})
                (tset fake-repl :status :connected)
                (guile.eval-str {:code expected-code :context nil})
                (guile.disconnect)
                (assert.are.equal ",m (guile-user)\n,import (guile)" (. calls 1))
                (assert.are.equal (.. ",m (guile-user)\n" expected-code) (. calls 2)))))

        (it "initializes (guile-user) once when eval-str called twice on repl in nil context"
            (fn []
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl {:send spy-send :status nil :destroy (fn [])}
                    expected-code "(print \"Hello second call\")"]

                (fake-socket.set-fake-repl fake-repl)
                (guile.connect {})
                (tset fake-repl :status :connected)
                (guile.eval-str {:code "(first-call)" :context nil})
                (guile.eval-str {:code expected-code :context nil})
                (guile.disconnect)
                (assert.are.equal (.. ",m (guile-user)\n" expected-code) (. calls 3)))))

        (it "initializes (guile-user) again when eval-str disconnect eval-str is called in nil context"
            (fn []
              (let [
                    calls []
                    spy-send (fn [call] (table.insert calls call))
                    fake-repl {:send spy-send :status nil :destroy (fn [])}
                    expected-code "(print \"Hello second call\")"]

                (fake-socket.set-fake-repl fake-repl)
                (guile.connect {})
                (tset fake-repl :status :connected)
                (guile.eval-str {:code "(first-call)" :context nil})
                (guile.disconnect)
                (guile.connect {})
                (tset fake-repl :status :connected)
                (guile.eval-str {:code expected-code :context nil})
                (assert.are.equal ",m (guile-user)\n,import (guile)" (. calls 3))
                (assert.are.equal (.. ",m (guile-user)\n" expected-code) (. calls 4)))))

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
                (tset fake-repl :status :connected)
                (guile.eval-str {:code "(first-call)" :context nil})
                (guile.eval-str {:code expected-code :context expected-module})
                (assert.are.equal (..  ",m " expected-module "\n,import (guile)") (. calls 3))
                (assert.are.equal (.. ",m " expected-module "\n" expected-code) (. calls 4)))))))))
