(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))

(local uv vim.loop)

(fn parse-cmd [x]
  (if
    (a.table? x)
    {:cmd (a.first x)
     :args (a.rest x)}

    (a.string? x)
    (parse-cmd (str.split x "%s"))))

{: parse-cmd}
