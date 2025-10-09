(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local config (autoload :conjure.config))
(local mapping (autoload :conjure.mapping))
(local log (autoload :conjure.log))
(local fs (autoload :conjure.fs))
(local extract (autoload :conjure.extract))

(local M
  (define :conjure.client.lua.neovim
    {:buf-suffix ".lua"
    :comment-prefix "-- "}))

; moved the set forms into the define like client.fennel.nfnl does.
; (set M.buf-suffix ".lua")
; (set M.comment-prefix "-- ")

; These types of nodes are roughly equivalent to Lisp forms. This should make
; it more intuitive when using <localleader>ee to evaluate the "current form".
(fn M.form-node? [node]
  (or (= "function_call" (node:type))
      (= "function_definition" (node:type))
      (= "function_declaration" (node:type))
      (= "local_declaration" (node:type))
      (= "variable_declaration" (node:type))
      (= "if_statement" (node:type))
      (= "for_statement" (node:type))
      (= "assignment_statement" (node:type))))

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
(set M.repls (or M.repls {}))

;; Two following functions are modified client/fennel/aniseed.fnl
(fn M.reset-env [filename]
  (let [filename (or filename (fs.localise-path (extract.file-path)))]
    (tset M.repls filename nil)
    (log.append [(.. M.comment-prefix "Reset environment for " filename)] {:break? true})))

(fn M.reset-all-envs []
  (core.run!
    (fn [filename]
      (tset M.repls filename nil))
    (core.keys M.repls))
  (log.append [(.. M.comment-prefix "Reset all environments")] {:break? true}))

(fn M.on-filetype []
  (mapping.buf
    :LuaResetEnv (cfg [:mapping :reset_env])
    #(M.reset-env)
    {:desc "Reset the Lua REPL environment"})

  (mapping.buf
    :LuaResetAllEnvs (cfg [:mapping :reset_all_envs])
    #(M.reset-all-envs)
    {:desc "Reset all Lua REPL environments"}))

(fn display [out ret err]
  (let [outs (->> (str.split (or out "") "\n")
                  (core.filter #(~= "" $1))
                  (core.map #(.. M.comment-prefix "(out) " $1)))
        errs (->> (str.split (or err "") "\n")
                  (core.filter #(~= "" $1))
                  (core.map #(.. M.comment-prefix "(err) " $1)))]
    (log.append outs)
    (log.append errs)
    (log.append (str.split (.. "res = " (vim.inspect ret)) "\n"))))

(fn lua-compile [opts]
  (if (= opts.origin "file")
    (loadfile opts.file-path)
    (let [(f e) (load (.. "return (" opts.code "\n)"))]
      (if f (values f e) (load opts.code)))))

(fn M.default-env []
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
  (let [env (M.default-env)]
    (setfenv f env)
    (let [(status ret) (pcall f)]
      (values status ret env.REDIRECTED-OUTPUT))))

;; this function is ugly due to the imperative interface of debug.getlocal
(fn pcall-persistent-debug [file f]
  (tset M.repls file (or (. M.repls file) {}))
  (tset (. M.repls file) :env (or (. M.repls file :env) (M.default-env)))
  (tset (. M.repls file :env) :REDIRECTED-OUTPUT "") ;; Clear last output
  (setfenv f (. M.repls file :env))
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
                (tset (. M.repls file :env) n v)
                (set i (+ i 1))))))]
    (debug.sethook collect-env :r)
    (let [(status ret) (pcall f)]
      (values status ret (. M.repls file :env :REDIRECTED-OUTPUT)))))

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

(fn M.eval-str [opts]
  (let [(out ret err) (lua-eval opts)]
    (display out ret err)
    (when opts.on-result
      (opts.on-result (vim.inspect ret)))))

(fn M.eval-file [opts]
  (M.reset-env opts.file-path)
  (let [(out ret err) (lua-eval opts)]
    (display out ret err)
    (when opts.on-result
      (opts.on-result (vim.inspect ret)))))

M
