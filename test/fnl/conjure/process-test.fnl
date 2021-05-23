(module conjure.process-test
  {require {process conjure.process
            nvim conjure.aniseed.nvim}})

(deftest executable?
  (t.= false (process.executable? "nope-this-does-not-exist")
       "thing's that don't exist return false")
  (t.= true (process.executable? "sh")
       "sh should always exist, I hope"))

(deftest execute-stop-lifecycle
  (let [sh (process.execute "sh")]
    (t.= :table (type sh)
         "we get a table to identify the process")
    (t.= true (process.running? sh)
         "it starts out as running")
    (t.= 1 (nvim.fn.bufexists (. sh :buf))
         "a buffer is created for the terminal / process")
    (t.= sh (process.stop sh)
         "stopping returns the process table")
    (t.= sh (process.stop sh)
         "stopping is idempotent")
    (t.= false (process.running? sh)
         "now it's not running")
    (t.= 0 (nvim.fn.bufexists (. sh :buf))
         "the buffer should also be deleted")))
