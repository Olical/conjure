(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local action (require :conjure.client.clojure.nrepl.action))

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
            (assert.are.equals "foo" (action.extract-test-name-from-form "(deftest ^:kaocha/skip foo :xyz)"))))))))

;;;;;;;;;;;;;;;;;;;;
(comment

(local parse (require :conjure.client.clojure.nrepl.parse))
(local str (require :conjure.aniseed.string))
(local a (require :conjure.aniseed.core))
(local text (require :conjure.text))
(local config (require :conjure.config))


(parse.strip-meta "(deftest foo (+ 10 20))")
(str.split (parse.strip-meta "(deftest foo (+ 10 20))") "%s+") ; ["(deftest" "foo" "(+" "10" "20))"]
(r (str.split (parse.strip-meta "(deftest foo (+ 10 20))") "%s+")) ; "foo"

(parse.strip-meta "(   deftest  foo  (+ 10 20))")
(str.split (parse.strip-meta "(   deftest  foo  (+ 10 20))") "%s+") ; ["(" "deftest" "foo" "(+" "10" "20))"]
(r  (str.split (parse.strip-meta "(   deftest  foo  (+ 10 20))") "%s+")) ; "("

(parse.strip-meta "(deftest ^:kaocha/skip foo :xyz)")
(str.split (parse.strip-meta "(deftest ^:kaocha/skip foo :xyz)") "%s+") ; ["(deftest" "foo" ":xyz)"]
(r (str.split (parse.strip-meta "(deftest ^:kaocha/skip foo :xyz)") "%s+")) ; "foo"

;;; Expected Clojure config
(local cfg (config.get-in-fn [:client :clojure :nrepl]))

(cfg [:connection :port_number]) ; nil

;; g:conjure#client#clojure#nrepl#test#current_form_names
(cfg [:test :current_form_names]) ; ["deftest"]

;; g:conjure#client#clojure#nrepl#test#runner
(cfg [:test :runner]) ; "clojure"

;; g:conjure#client#clojure#nrepl#test#raw_out
(cfg [:test :raw_out]) ; false

;; print(vim.g["conjure#client#clojure#nrepl#test#current_form_names"])
(. vim.g "conjure#client#clojure#nrepl#test#current_form_names") ; ["deftest"]

(cfg [:test :current_form_names]) ; ["deftest"]

;; Create config items with [:test :current_form_names] for clojure client.
(set vim.g.conjure#client#clojure#nrepl#test#current_form_names [:deftest])


(fn r [words]
  ;; return first truthy result of applying fn to each word in words
  (var seen-deftest? false)
  (a.some
    (fn [part]
      (if
        (a.some (fn [config-current-form-name]
                  (text.ends-with part config-current-form-name))
                (cfg [:test :current_form_names]))
        (do (set seen-deftest? true) false)

        seen-deftest?
        part)) words))


)
