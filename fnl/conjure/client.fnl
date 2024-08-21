(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local nvim (autoload :conjure.aniseed.nvim))
(local fennel (autoload :conjure.aniseed.fennel))
(local str (autoload :conjure.aniseed.string))
(local config (autoload :conjure.config))
(local dyn (autoload :conjure.dynamic))

(local state-key (dyn.new #(do :default)))

(local state
  {:state-key-set? false})

(fn set-state-key! [new-key]
  (set state.state-key-set? true)
  (dyn.set-root! state-key #(do new-key)))

(fn multiple-states? []
  state.state-key-set?)

(fn new-state [init-fn]
  (let [key->state {}]
    (fn [...]
      (let [key (state-key)
            state (a.get key->state key)]
        (-> (if (= nil state)
              (let [new-state (init-fn)]
                (a.assoc key->state key new-state)
                new-state)
              state)
            (a.get-in [...]))))))

(local loaded {})

(fn load-module [ft name]
  (let [fnl (fennel.impl)
        (ok? result) (xpcall
                       (fn []
                         (require name))
                       fnl.traceback)]

    (when (and ok? (a.nil? (a.get loaded name)))
      (a.assoc loaded name
               {:filetype ft
                :module-name name
                :module result})
      (when (and result.on-load
                 (not nvim.wo.diff)
                 (config.get-in [:client_on_load]))
        (vim.schedule result.on-load)))

    (if ok?
      result
      (error result))))

(local filetype (dyn.new #(do nvim.bo.filetype)))
(local extension (dyn.new #(nvim.fn.expand "%:e")))

(fn with-filetype [ft f ...]
  (dyn.bind
    {filetype #(do ft)
     extension #(do)}
    f ...))

(fn wrap [f ...]
  (let [opts {filetype (a.constantly (filetype))
              state-key (a.constantly (state-key))}
        args [...]]
    (fn [...]
      (if (not= 0 (a.count args))
        (dyn.bind opts f (unpack args) ...)
        (dyn.bind opts f ...)))))

(fn schedule-wrap [f ...]
  (wrap (vim.schedule_wrap f) ...))

(fn schedule [f ...]
  (vim.schedule (wrap f ...)))

(fn current-client-module-name []
  (var result {:filetype (filetype)
               :extension (extension)
               :module-name nil})
  (let [fts (when result.filetype
              (str.split result.filetype "%."))]
    (when fts
      (for [i (a.count fts) 1 -1]
        (let [ft-part (. fts i)
              module-name (config.get-in [:filetype ft-part])
              suffixes (config.get-in [:filetype_suffixes ft-part])]
          (when (and (not result.module-name) module-name
                     (or (not suffixes)
                         (not result.extension)
                         (a.some #(= result.extension $) suffixes)))
            (set result.module-name module-name))))))
  result)

(fn current []
  (let [{: module-name : filetype : extension}
        (current-client-module-name)]
    (when module-name
      (load-module filetype module-name))))

(fn get [...]
  (a.get-in (current) [...]))

(fn call [fn-name ...]
  (let [f (get fn-name)]
    (if f
      (f ...)
      (error (str.join
               ["Conjure client '"
                (a.get (current-client-module-name) :module-name)
                "' doesn't support function: "
                fn-name])))))

(fn optional-call [fn-name ...]
  (let [f (get fn-name)]
    (when f
      (f ...))))

(fn each-loaded-client [f]
  (a.run!
    (fn [{: filetype}]
      (with-filetype filetype f))
    (a.vals loaded)))

{: state-key
 : set-state-key!
 : multiple-states?
 : new-state
 : with-filetype
 : wrap
 : schedule-wrap
 : schedule
 : current-client-module-name
 : current
 : get
 : call
 : optional-call
 : each-loaded-client}
