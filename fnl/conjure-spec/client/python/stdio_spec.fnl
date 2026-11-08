(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local python (require :conjure.client.python.stdio))
(local ts (require :conjure.tree-sitter))
(local mock-log (require :conjure-spec.mock-log))

(tset package.loaded "conjure.log" mock-log)

;; Behaves like `python3 -iq` with a non-tty stdin: a `>>> ` on stderr at
;; startup and after every line read. Lines with exec( are slow, like a first
;; `import numpy`. Lines with print_prompt print text containing the prompt.
(local fake-python-repl
  ["printf '>>> ' >&2"
   "while IFS= read -r line; do"
   "  case \"$line\" in"
   "    *exec\\(*) sleep 0.1; echo None;;"
   "    *print_prompt*) printf '>>> look\\nNone\\n';;"
   "  esac"
   "  printf '>>> ' >&2"
   "done"])

(describe "conjure.client.python.stdio"
  (fn []
    (describe "prep-code"
      (fn []
        (it "sets __file__ before evaluating expressions on a single line"
            (fn []
              (tset python :str-is-python-expr? (fn [_] true))

              (assert.same
                "__file__ = base64.b64decode('L3RtcC9leGFtcGxlLnB5').decode(); __file__\n"
                (python.prep-code
                  {:code "__file__"
                   :file-path "/tmp/example.py"}))))

        (it "sets __file__ and uses it as the filename for exec evaluations on a single line"
            (fn []
              (tset python :str-is-python-expr? (fn [_] false))

              (assert.same
                "__file__ = base64.b64decode('L3RtcC9leGFtcGxlLnB5').decode(); exec(compile(base64.b64decode('cHJpbnQoX19maWxlX18p'), __file__, 'exec'))\n"
                (python.prep-code
                  {:code "print(__file__)"
                   :file-path "/tmp/example.py"}))))

        (it "uses a fallback filename when no file path is available"
            (fn []
              (tset python :str-is-python-expr? (fn [_] true))

              (assert.same
                "__file__ = base64.b64decode('PGNvbmp1cmU+').decode(); __file__\n"
                (python.prep-code
                  {:code "__file__"}))))

        (it "does not depend on __file__ being defined when auto_set_file is disabled"
            (fn []
              (tset python :str-is-python-expr? (fn [_] false))
              (set vim.g.conjure#client#python#stdio#auto_set_file false)
              (let [code (python.prep-code {:code "print(1)" :file-path "/tmp/example.py"})]
                (set vim.g.conjure#client#python#stdio#auto_set_file nil)
                (assert.same
                  "exec(compile(base64.b64decode('cHJpbnQoMSk='), base64.b64decode('L3RtcC9leGFtcGxlLnB5').decode(), 'exec'))\n"
                  code))))))

    (describe "eval-str against a prompt-per-line REPL"
      (fn []
        (it "completes each eval on its own prompt, not an earlier or printed one"
            (fn []
              (let [repl-path (vim.fn.tempname)
                    previous-add-language ts.add-language
                    results []]
                (vim.fn.writefile fake-python-repl repl-path)
                (set vim.g.conjure#client#python#stdio#command (.. "sh " repl-path))
                (tset ts :add-language (fn [] true))
                (python.start)
                (each [_ [code expr?] (ipairs [["print_prompt()" true] ["slow()" false] ["slow()" false]])]
                  (tset python :str-is-python-expr? (fn [_] expr?))
                  (python.eval-str {: code :file-path "/tmp/example.py" :on-result #(table.insert results $1)}))
                (vim.wait 3000 #(= 3 (length results)))
                (python.stop)
                (set vim.g.conjure#client#python#stdio#command nil)
                (tset ts :add-language previous-add-language)
                (assert.same ["None" "None" "None"] results))
              nil))))))
