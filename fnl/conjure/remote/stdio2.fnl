(module conjure.remote.stdio2
  {autoload {a conjure.aniseed.core
             nvim conjure.aniseed.nvim
             str conjure.aniseed.string
             client conjure.client
             log conjure.log}})

(def- uv vim.loop)

(defn parse-cmd [x]
  (if
    (a.table? x)
    {:cmd (a.first x)
     :args (a.rest x)}

    (a.string? x)
    (parse-cmd (str.split x "%s"))))
