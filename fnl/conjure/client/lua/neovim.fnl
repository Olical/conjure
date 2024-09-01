(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))
(local stdio (autoload :conjure.remote.stdio))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))
(local mapping (autoload :conjure.mapping))
(local client (autoload :conjure.client))
(local log (autoload :conjure.log))
(local fs (autoload :conjure.fs))
(local extract (autoload :conjure.extract))

(local buf-suffix ".lua")
(local comment-prefix "-- ")

; These types of nodes are roughly equivalent to Lisp forms. This should make
; it more intuitive when using <localleader>ee to evaluate the "current form".
(fn form-node? [node]
  (or (= "function_call" (node:type))
      (= "function_definition" (node:type))
      (= "function_declaration" (node:type))
      (= "local_declaration" (node:type))
      (= "variable_declaration" (node:type))
      (= "if_statement" (node:type))))

(config.merge
  {:client
   {:lua
    {:neovim
     {:persistent :debug}}}}) ;persistent can be either :debug or nil

(when (config.get-in [:mapping :enable_defaults])
  (config.merge
    {:client
     {:lua
      {:neovim
       {:mapping {:reset_env "rr"
                  :reset_all_envs "ra"}}}}}))

(local cfg (config.get-in-fn [:client :lua :neovim]))
(local repls {})

;; Two following functions are modified client/fennel/aniseed.fnl
(fn reset-env [filename]
  (let [filename (or filename (fs.localise-path (extract.file-path)))]
    (tset repls filename nil)
    (log.append [(.. comment-prefix "Reset environment for " filename)] {:break? true})))

(fn reset-all-envs []
  (a.run!
    (fn [filename]
      (tset repls filename nil))
    (a.keys repls))
  (log.append [(.. comment-prefix "Reset all environments")] {:break? true}))

(fn on-filetype []
  (mapping.buf
    :LuaResetEnv (cfg [:mapping :reset_env])
    #(reset-env))

  (mapping.buf
    :LuaResetAllEnvs (cfg [:mapping :reset_all_envs])
    #(reset-all-envs)))

(fn display [out ret err]
  (let [outs (->> (str.split (or out "") "\n")
                  (a.filter #(~= "" $1))
                  (a.map #(.. comment-prefix "(out) " $1)))
        errs (->> (str.split (or err "") "\n")
                  (a.filter #(~= "" $1))
                  (a.map #(.. comment-prefix "(err) " $1)))]
    (log.append outs)
    (log.append errs)
    (log.append (str.split (.. "res = " (vim.inspect ret)) "\n"))))

(fn lua-compile [opts]
  (if (= opts.origin "file")
    (loadfile opts.file-path)
    (let [(f e) (load (.. "return (" opts.code "\n)"))]
      (if f (values f e) (load opts.code)))))

(fn default-env []
  (let [base (setmetatable {:REDIRECTED-OUTPUT ""
                            :io (setmetatable {} {:__index _G.io})}
                           {:__index _G})
        print-redirected
        (fn [...]
          (tset base :REDIRECTED-OUTPUT
                (.. base.REDIRECTED-OUTPUT (str.join "\t" [...]) "\n")))
        io-write-redirected
        (fn [...]
          (tset base :REDIRECTED-OUTPUT
                (.. base.REDIRECTED-OUTPUT (str.join [...]))))
        io-read-redirected
        (fn []
          (.. (or (extract.prompt "Input required: ") "") "\n"))]
    (tset base :print print-redirected)
    (tset base.io :write io-write-redirected)
    (tset base.io :read io-read-redirected)
    base))

(fn pcall-default [f]
  (let [env (default-env)]
    (setfenv f env)
    (let [(status ret) (pcall f)]
      (values status ret env.REDIRECTED-OUTPUT))))

;; this function is ugly due to the imperative interface of debug.getlocal
(fn pcall-persistent-debug [file f]
  (tset repls file (or (. repls file) {}))
  (tset (. repls file) :env (or (. repls file :env) (default-env)))
  (tset (. repls file :env) :REDIRECTED-OUTPUT "") ;; Clear last output
  (setfenv f (. repls file :env))
  (let [collect-env
        (fn [_ _]
          (debug.sethook)
          (var i 1)
          (var n true)
          (var v nil)
          (while n
            (set (n v) (debug.getlocal 2 i))
            (if n
              (do
                (tset (. repls file :env) n v)
                (set i (+ i 1))))))]
    (debug.sethook collect-env :r)
    (let [(status ret) (pcall f)]
      (values status ret (. repls file :env :REDIRECTED-OUTPUT)))))

(fn lua-eval [opts]
  (let [(f e) (lua-compile opts)]
    (if f
      (let [pcall-custom (match (cfg [:persistent])
                           :debug (partial pcall-persistent-debug opts.file-path)
                           _ pcall-default)
            (status ret out) (pcall-custom f)]
        (if status
          (values out ret "")
          (values out nil (.. "Execution error: " ret))))
      (values "" nil (.. "Compilation error: " e)))))

(fn eval-str [opts]
  (let [(out ret err) (lua-eval opts)]
    (display out ret err)
    (when opts.on-result
      (opts.on-result (vim.inspect ret)))))

(fn eval-file [opts]
  (reset-env opts.file-path)
  (let [(out ret err) (lua-eval opts)]
    (display out ret err)
    (when opts.on-result
      (opts.on-result (vim.inspect ret)))))

{: buf-suffix
 : comment-prefix
 : form-node?
 : reset-env
 : reset-all-envs
 : on-filetype
 : default-env
 : eval-str
 : eval-file}
