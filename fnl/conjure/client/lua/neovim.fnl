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

(defn on-filetype []
  (mapping.buf :n :LuaResetEnv
               (cfg [:mapping :reset_env]) *module-name* :reset-env)
  (mapping.buf :n :LuaResetAllEnvs
               (cfg [:mapping :reset_all_envs]) *module-name* :reset-all-envs))

(defonce- repls {})

;; Two following functions are modified client/fennel/aniseed.fnl
(defn reset-env [filename]
  (let [filename (or filename (fs.localise-path (extract.file-path)))]
    (tset repls filename nil)
    (log.append [(.. "-- Reset environment for " filename)] {:break? true})))

(defn reset-all-envs []
  (a.run!
    (fn [filename]
      (tset repls filename nil))
    (a.keys repls))
  (log.append [(.. "-- Reset all environments")] {:break? true}))

(defn- display [out ret err]
  (let [outs (->> (str.split (or out "") "\n")
              (a.filter #(~= "" $1))
              (a.map #(.. comment-prefix "(out) " $1)))
        errs (->> (str.split (or err "") "\n")
              (a.filter #(~= "" $1))
              (a.map #(.. comment-prefix "(err) " $1)))]
    (log.append outs)
    (log.append errs)
    (log.append ["return"]) ;; add this new line so that syntax-highlighting and other plugins maybe happier
    (log.append (str.split (vim.inspect ret) "\n"))))

(def- print_original _G.print)
(def- io_write_original _G.io.write)
(global CONJURE_NVIM_REDIRECTED "")

(defn- redirect []
  (set _G.print
   (fn [...]
    (global CONJURE_NVIM_REDIRECTED
      (.. CONJURE_NVIM_REDIRECTED (str.join "\t" [...]) "\n"))))
  (set _G.io.write
   (fn [...]
    (global CONJURE_NVIM_REDIRECTED
      (.. CONJURE_NVIM_REDIRECTED (str.join [...]))))))

(defn- end-redirect []
  (set _G.print print_original)
  (set _G.io.write io_write_original)
  (let [result CONJURE_NVIM_REDIRECTED]
    (global CONJURE_NVIM_REDIRECTED "")
    result))

(defn- lua-try-compile [codes]
  (let [(f e) (load (.. "return (" codes "\n)"))]
    (if f (values f e) (load codes))))

;; this function is ugly due to the imperative interface of debug.getlocal
(defn pcall-persistent-debug [file f]
  (tset repls file (or (. repls file) {}))
  (tset (. repls file) :env (or (. repls file :env) (setmetatable {} {:__index _G})))
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
    (pcall f)));; If there's only one pcall instance, we could 
    
(defn- lua-eval [opts]
  (let [(f e) (lua-try-compile opts.code)]
   (if f
    (do
     (redirect)
     (let [pcall-custom (match (cfg [:persistent])
                          :debug (partial pcall-persistent-debug opts.file-path)
                          _ pcall)
           (status ret) (pcall-custom f)]
      (if status
       (values (end-redirect) ret "")
       (values (end-redirect) nil (.. "Execution error: " ret)))))
    (values "" nil (.. "Compilation error: " e)))))

(defn eval-str [opts]
  (let [(out ret err) (lua-eval opts)]
   (display out ret err)
   (when (. opts :on-result)
    (let [on-result (. opts :on-result)]
     ((. opts :on-result) (vim.inspect ret))))))

(defn eval-file [opts]
  (reset-env)
  (redirect)
  (let [f (loadfile opts.file-path)
        pcall-custom (match (cfg [:persistent])
                          :debug (partial pcall-persistent-debug opts.file-path)
                          _ pcall)

        (status ret) (pcall-custom f)]
   (display (end-redirect) ret err)
   (when (. opts :on-result)
    (let [on-result (. opts :on-result)]
     ((. opts :on-result) (vim.inspect ret))))))
