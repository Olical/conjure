(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local nvim (require :conjure.aniseed.nvim))
(local process (require :conjure.process))

(describe "conjure.process"
  (fn []
    (describe "executable?"
      (fn []
        (it "thing's that don't exist return false"
          (fn []
            (assert.are.equals false (process.executable? "nope-this-does-not-exist"))))
        (it "sh should always exist, I hope"
          (fn []
            (assert.are.equals true (process.executable? "sh"))))
        (it "only the first word is checked"
          (fn []
            (assert.are.equals true (process.executable? "sh foo bar"))))))

    (describe "execute-stop-lifecycle"
      (fn []
        (let [sh (process.execute "sh")]
          (it "we get a table to identify the process"
            (fn []
              (assert.are.equals :table (type sh))))
          (it "it starts out as running"
            (fn []
              (assert.are.equals true (process.running? sh))))
          (it "the running check handles nils"
            (fn []
              (assert.are.equals false (process.running? nil))))
          (it "a buffer is created for the terminal / process"
            (fn []
              (assert.are.equals 1 (nvim.fn.bufexists sh.buf))))
          (it "stopping returns the process table"
            (fn []
              (assert.are.equals sh (process.stop sh))))
          (it "stopping is idempotent"
            (fn []
              (assert.are.equals sh (process.stop sh))))
          (it "now it's not running"
            (fn []
              (assert.are.equals false (process.running? sh)))))))

    (describe "on-exit-hook"
      (fn []
        (let [state {:args nil}
              sh (process.execute
                   "sh"
                   {:on-exit (fn [...]
                               (tset state :args [...]))})]
        (it "called and given the proc"
          (fn []
            (process.stop sh)
            (assert.same [sh] state.args))))))))
