(local {: autoload} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))

(local uv vim.uv)

(fn parse-cmd [x]
  (if
    (core.table? x)
    {:cmd (core.first x)
     :args (core.rest x)}

    (core.string? x)
    (parse-cmd (str.split x "%s"))))

{: parse-cmd}
