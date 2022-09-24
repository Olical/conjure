(module conjure.client.lua.neovim
  {autoload {a conjure.aniseed.core
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             stdio conjure.remote.stdio
             config conjure.config
             text conjure.text
             mapping conjure.mapping
             client conjure.client
             log conjure.log
             fs conjure.fs
             extract conjure.extract}
   require-macros [conjure.macros]})

(def buf-suffix ".lua")
(def comment-prefix "-- ")

(config.merge
  {:client
   {:lua
    {:neovim
     {:mapping {:reset_env "rr"
                :reset_all_envs "ra"}
      :persistent :debug}}}}) ;persistent can be either :debug or nil

(def- cfg (config.get-in-fn [:client :lua :neovim]))

(defonce- repls {})

;; Two following functions are modified client/fennel/aniseed.fnl
(defn reset-env [filename]
  (let [filename (or filename (fs.localise-path (extract.file-path)))]
    (tset repls filename nil)
    (log.append [(.. comment-prefix "Reset environment for " filename)] {:break? true})))

(defn reset-all-envs []
  (a.run!
    (fn [filename]
      (tset repls filename nil))
    (a.keys repls))
  (log.append [(.. comment-prefix "Reset all environments")] {:break? true}))

(defn on-filetype []
  (mapping.buf
    :LuaResetEnv (cfg [:mapping :reset_env])
    #(reset-env))

  (mapping.buf
    :LuaResetAllEnvs (cfg [:mapping :reset_all_envs])
    #(reset-all-envs)))

(defn- display [out ret err]
  (let [outs (->> (str.split (or out "") "\n")
                  (a.filter #(~= "" $1))
                  (a.map #(.. comment-prefix "(out) " $1)))
        errs (->> (str.split (or err "") "\n")
                  (a.filter #(~= "" $1))
                  (a.map #(.. comment-prefix "(err) " $1)))]
    (log.append outs)
    (log.append errs)
    (log.append (str.split (.. "res = " (vim.inspect ret)) "\n"))))

(defn- lua-compile [opts]
  (if (= opts.origin "file")
    (loadfile opts.file-path)
    (let [(f e) (load (.. "return (" opts.code "\n)"))]
      (if f (values f e) (load opts.code)))))

(defn default-env []
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

(defn- pcall-default [f]
  (let [env (default-env)]
    (setfenv f env)
    (let [(status ret) (pcall f)]
      (values status ret env.REDIRECTED-OUTPUT))))

;; this function is ugly due to the imperative interface of debug.getlocal
(defn- pcall-persistent-debug [file f]
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

(defn- lua-eval [opts]
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

(defn eval-str [opts]
  (let [(out ret err) (lua-eval opts)]
    (display out ret err)
    (when opts.on-result
      (opts.on-result (vim.inspect ret)))))

(defn eval-file [opts]
  (reset-env opts.file-path)
  (let [(out ret err) (lua-eval opts)]
    (display out ret err)
    (when opts.on-result
      (opts.on-result (vim.inspect ret)))))
