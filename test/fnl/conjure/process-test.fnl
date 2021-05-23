(module conjure.process-test
  {require {process conjure.process
            nvim conjure.aniseed.nvim}})

(deftest executable?
  (t.= false (process.executable? "nope-this-does-not-exist")
       "thing's that don't exist return false")
  (t.= true (process.executable? "sh")
       "sh should always exist, I hope")
  (t.= true (process.executable? "sh foo bar")
       "only the first word is checked"))

(deftest execute-stop-lifecycle
  (let [sh (process.execute "sh")]
    (t.= :table (type sh)
         "we get a table to identify the process")
    (t.= true (process.running? sh)
         "it starts out as running")
    (t.= false (process.running? nil)
         "the running check handles nils")
    (t.= 1 (nvim.fn.bufexists sh.buf)
         "a buffer is created for the terminal / process")
    (t.= sh (process.stop sh)
         "stopping returns the process table")
    (t.= sh (process.stop sh)
         "stopping is idempotent")
    (t.= false (process.running? sh)
         "now it's not running")))

(deftest on-exit-hook
  (let [state {:args nil}
        sh (process.execute
             "sh"
             {:on-exit (fn [...]
                         (tset state :args [...]))})]
    (process.stop sh)
    (t.pr= [sh] state.args "called and given the proc")))
