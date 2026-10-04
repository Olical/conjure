(local {: autoload } (require :conjure.nfnl.module))
(local {: describe : it : before_each} (require :plenary.busted))
(local a (autoload :conjure.nfnl.core))
(local assert (autoload :luassert.assert))
(local swank (autoload :conjure.client.common-lisp.swank))
(local config (autoload :conjure.config))
(require :conjure-spec.assertions)

(local mock-tsc (require :conjure-spec.mock-tree-sitter-completions))
(local mock-remote (require :conjure-spec.remote.mock-swank))
(local mock-log (require :conjure-spec.mock-log))

(tset package.loaded "conjure.remote.swank" mock-remote)
(tset package.loaded "conjure.tree-sitter-completions" mock-tsc)
(tset package.loaded "conjure.log" mock-log)

(fn format-swank-return [output]
  (let [formatted-output (string.sub (a.pr-str output) 2 -2)]
    (string.format "(:return (:ok (\"\" \"(%s)\")) 0)" formatted-output)))

(describe "conjure.client.common-lisp.swank"
  (fn []
    (before_each 
      (fn []
        (mock-remote.clear-send-calls)))

    (describe "completions"
      (fn []
        (it "returns empty list when not connected and no treesitter completions"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions [])

              (swank.completions 
                {:prefix ""
                 :cb completion-cb})

             (assert.same [] (. completion-cb-calls 1)))))

        (it "returns defun when connected and swank completions returns defun and no treesitter completions"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions [])

              (swank.connect {})
              (swank.completions 
                {:prefix "def"
                 :cb completion-cb})
              ((a.get-in mock-remote.send-calls [2 :cb]) 
               (format-swank-return "(\"defun\") \"def\""))
              (swank.disconnect)

              (assert.has-substring 
                "swank:simple%-completions \\\"def\\\"" 
                (a.get-in mock-remote.send-calls [2 :msg]))

              (assert.same ["defun"] (. completion-cb-calls 1)))))

        (it "returns some something when prefix nil swank completions returns something and treesitter completions returns some"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["some"])

              (swank.connect {})
              (swank.completions 
                {:prefix nil
                 :cb completion-cb})
              ((a.get-in mock-remote.send-calls [2 :cb]) 
               (format-swank-return "(\"something\") \"\""))
              (swank.disconnect)

              (assert.has-substring 
                "swank:simple%-completions nil" 
                (a.get-in mock-remote.send-calls [2 :msg]))

              (assert.same ["some" "something"] (. completion-cb-calls 1)))))


        (it "returns defunct defun when connected and swank completions returns defun and treesitter completions returns defunct"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["defunct"])

              (swank.connect {})
              (swank.completions 
                {:prefix "def"
                 :cb completion-cb})
              ((a.get-in mock-remote.send-calls [2 :cb]) 
               (format-swank-return "(\"defun\") \"def\""))
              (swank.disconnect)

              (assert.same ["defunct" "defun"] (. completion-cb-calls 1)))))

        (it "returns defunct when not connected and treesitter completions returns defunct"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["defunct"])

              (swank.completions 
                {:prefix "def"
                 :cb completion-cb})

              (assert.same [] mock-remote.send-calls)
              (assert.same ["defunct"] (. completion-cb-calls 1)))))

        (it "returns symbol when connected and swank completions returns symbol and treesitter completions returns symbol"
          (fn []
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["symbol"])

              (swank.connect {})
              (swank.completions 
                {:prefix "s"
                 :cb completion-cb})
              ((a.get-in mock-remote.send-calls [2 :cb]) 
               (format-swank-return "(\"symbol\") \"s\""))
              (swank.disconnect)

              (assert.same ["symbol"] (. completion-cb-calls 1)))))))

    (describe "config"
      (fn []
        (it "returns no completions when connected and completions disabled"
          (fn []
            (config.merge {:client {:common_lisp {:swank
                             {:enable_completions false}}}}
                          {:overwrite? true})
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["something"])

              (swank.connect {})
              (swank.completions 
                {:prefix "s"
                 :cb completion-cb})
              (swank.disconnect)

              (assert.are.equal 1 (length mock-remote.send-calls))
              (assert.same [] (. completion-cb-calls 1)))))

        (it "returns completions dots dotimes when connected with tree sitter results dots and completions enabled"
          (fn []
            (config.merge {:client {:common_lisp {:swank
                             {:enable_completions true}}}}
                          {:overwrite? true})
            (let [completion-cb-calls []
                  completion-cb 
                  (fn [res]
                    (table.insert completion-cb-calls res))]
              (mock-tsc.set-mock-completions ["dots"])

              (swank.connect {})
              (swank.completions 
                {:prefix "dot"
                 :cb completion-cb})
              ((a.get-in mock-remote.send-calls [2 :cb]) 
               (format-swank-return "(\"dotimes\") \"dot\""))
              (swank.disconnect)

              (assert.same ["dots" "dotimes"] (. completion-cb-calls 1)))))))

    (describe "debugger"
      (fn []
        (it "logs the condition, restarts and backtrace, then invokes a restart by number"
          (fn []
            (let [logged []
                  orig-append mock-log.append]
              (set mock-log.append (fn [lines] (table.insert logged lines)))
              (swank.connect {})
              (swank.handle-event
                (.. "(:debug 42 1 (\"break\" \"   [Condition of type SIMPLE-CONDITION]\" nil)"
                    " ((\"CONTINUE\" \"Return from BREAK.\") (\"ABORT\" \"abort (#<THREAD \\\"worker\\\">)\"))"
                    " ((0 \"(F 3)\") (1 \"(EVAL (F 3))\" (:restartable t))) (42))"))
              (swank.invoke-restart 0)
              (swank.disconnect)
              (set mock-log.append orig-append)
              (assert.same
                ["; Debugger level 1: break"
                 ";    [Condition of type SIMPLE-CONDITION]"
                 "; Restarts:"
                 ";  0: [CONTINUE] Return from BREAK."
                 ";  1: [ABORT] abort (#<THREAD \"worker\">)"
                 "; Backtrace:"
                 ";  0: (F 3)"
                 ";  1: (EVAL (F 3))"]
                (. logged 1))
              (assert.has-substring
                "%(:emacs%-rex %(swank:invoke%-nth%-restart%-for%-emacs 1 0%) \"%*package%*\" 42 %d+%)"
                (a.get-in mock-remote.send-calls [2 :msg])))))

        (it "does nothing but log when there is no debugger to answer"
          (fn []
            (swank.connect {})
            (swank.handle-event "(:debug-return 42 1 nil)")
            (swank.invoke-restart 0)
            (swank.disconnect)
            (assert.are.equal 1 (length mock-remote.send-calls))))))

    (describe "stickers"
      (fn []
        (fn rec [id form]
          (let [label (+ 7000000 id)]
            (.. "(let ((#" label "=#:v (multiple-value-list " form "))) (push #" label
                "# (get :conjure-sticker-" (vim.fn.getpid) "-" id " :values)) (values-list #"
                label "#))")))

        (it "wraps stickered forms, including nested ones, in the evaluated code"
          (fn []
            (vim.cmd "new")
            (vim.api.nvim_buf_set_lines 0 0 -1 false ["(defun f (x)" "  (+ 1 (* x x)))"])
            (vim.api.nvim_win_set_cursor 0 [2 9])
            (swank.toggle-sticker)
            (vim.api.nvim_win_set_cursor 0 [2 3])
            (swank.toggle-sticker)
            (let [code "(defun f (x)\n  (+ 1 (* x x)))"
                  out (swank.instrument-stickers 0 code {:start [1 0] :end [2 15]})]
              (vim.cmd "bwipeout!")
              (assert.are.equal
                (.. "(defun f (x)\n  " (rec 2 (.. "(+ 1 " (rec 1 "(* x x)") ")")) ")")
                out))))

        (it "removes a sticker when toggled again and leaves code alone"
          (fn []
            (vim.cmd "new")
            (vim.api.nvim_buf_set_lines 0 0 -1 false ["(* 2 3)"])
            (vim.api.nvim_win_set_cursor 0 [1 1])
            (swank.toggle-sticker)
            (swank.toggle-sticker)
            (let [out (swank.instrument-stickers 0 "(* 2 3)" {:start [1 0] :end [1 6]})]
              (vim.cmd "bwipeout!")
              (assert.are.equal "(* 2 3)" out))))))

    (describe "hyperspec"
      (fn []
        (it "resolves symbols through Data/Map_Sym.txt under hyperspec_root"
          (fn []
            (let [root (vim.fn.tempname)]
              (vim.fn.mkdir (.. root "/Data") "p")
              (vim.fn.writefile ["DEFUN" "../Body/m_defun.htm"
                                 "CAR" "../Body/f_car_c.htm"]
                                (.. root "/Data/Map_Sym.txt"))
              (config.merge {:client {:common_lisp {:swank {:hyperspec_root root}}}}
                            {:overwrite? true})
              (assert.are.equal (.. root "/Body/m_defun.htm") (swank.hyperspec-file "defun"))
              (assert.are.equal (.. root "/Body/f_car_c.htm") (swank.hyperspec-file "cl:car"))
              (assert.is_nil (swank.hyperspec-file "no-such-symbol"))
              (vim.fn.delete root "rf"))))))

    (describe "macroexpand"
      (fn []
        (it "sends the current form to swank-macroexpand-1 and logs the expansion"
          (fn []
            (let [logged []
                  orig-append mock-log.append]
              (set mock-log.append (fn [lines] (table.insert logged lines)))
              (vim.cmd "new")
              (vim.api.nvim_buf_set_lines 0 0 -1 false ["(when a b)"])
              (vim.api.nvim_win_set_cursor 0 [1 1])
              (swank.connect {})
              (swank.macroexpand :swank-macroexpand-1)
              (assert.has-substring
                "%(swank:swank%-macroexpand%-1 \\\"%(when a b%)\\\"%)"
                (a.get-in mock-remote.send-calls [2 :msg]))
              ((a.get-in mock-remote.send-calls [2 :cb])
               "(:return (:ok (\"\" \"\\\"(IF A\n    B)\\\"\")) 2)")
              (swank.disconnect)
              (vim.cmd "bwipeout!")
              (set mock-log.append orig-append)
              (assert.same ["(IF A" "    B)"] (. logged 1)))))))

    (describe "trace"
      (fn []
        (it "toggles trace through swank"
          (fn []
            (swank.connect {})
            (swank.toggle-trace "sq")
            (swank.disconnect)
            (assert.has-substring
              "%(swank:swank%-toggle%-trace \\\"sq\\\"%)"
              (a.get-in mock-remote.send-calls [2 :msg]))))

        (it "binds *trace-output* to the captured stdout of every eval"
          (fn []
            (swank.connect {})
            (swank.eval-str {:code "(sq 5)"})
            (swank.disconnect)
            (assert.has-substring
              "%(let %(%(%*trace%-output%* %*standard%-output%*%)%) %(sq 5%)%)"
              (a.get-in mock-remote.send-calls [2 :msg]))))))))
