(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local fennel (autoload :conjure.nfnl.fennel))
(local str (autoload :conjure.nfnl.string))
(local config (autoload :conjure.config))
(local dyn (autoload :conjure.dynamic))
(local vim _G.vim)

(local M (define :conjure.client))

(set M.state-key (or M.state-key (dyn.new #(do :default))))

(set M.state (or M.state {:state-key-set? false}))

(fn M.set-state-key! [new-key]
  (set M.state.state-key-set? true)
  (dyn.set-root! M.state-key #(do new-key)))

(fn M.multiple-states? []
  M.state.state-key-set?)

(fn M.new-state [init-fn]
  (let [key->state {}]
    (fn [...]
      (let [key (M.state-key)
            state (core.get key->state key)]
        (-> (if (= nil state)
                (let [new-state (init-fn)]
                  (core.assoc key->state key new-state)
                  new-state)
                state)
            (core.get-in [...]))))))

(local loaded {})

(fn load-module [ft name]
  (let [(ok? result) (xpcall
                       (fn []
                         (require name))
                       fennel.traceback)]

    (when (and ok? (core.nil? (core.get loaded name)))
      (core.assoc loaded name
                  {:filetype ft
                   :module-name name
                   :module result})
      (when (and result.on-load
                 (not vim.wo.diff)
                 (config.get-in [:client_on_load]))
        (vim.schedule result.on-load)))

    (if ok?
        result
        (error result))))

(local filetype (dyn.new #(do vim.bo.filetype)))
(local extension (dyn.new #(vim.fn.expand "%:e")))

(fn M.with-filetype [ft f ...]
  (dyn.bind
    {filetype #(do ft)
     extension #(do)}
    f ...))

(fn M.wrap [f ...]
  (let [opts {filetype (core.constantly (filetype))
              M.state-key (core.constantly (M.state-key))}
        args [...]]
    (fn [...]
      (if (not= 0 (core.count args))
          (dyn.bind opts f (unpack (core.concat args [...])))
          (dyn.bind opts f ...)))))

(fn M.schedule-wrap [f ...]
  (M.wrap (vim.schedule_wrap f) ...))

(fn M.schedule [f ...]
  (vim.schedule (M.wrap f ...)))

(fn M.current-client-module-name []
  (local result
    {:filetype (filetype)
     :extension (extension)
     :module-name nil})
  (let [fts (when result.filetype
              (str.split result.filetype "%."))]
    (when fts
      (for [i (core.count fts) 1 -1]
        (let [ft-part (. fts i)
              module-name (config.get-in [:filetype ft-part])
              suffixes (config.get-in [:filetype_suffixes ft-part])]
          (when (and (not result.module-name) module-name
                     (or (not suffixes)
                         (not result.extension)
                         (core.some #(= result.extension $) suffixes)))
            (set result.module-name module-name))))))
  result)

(fn M.current []
  (let [{: module-name : filetype : _extension}
        (M.current-client-module-name)]
    (when module-name
      (load-module filetype module-name))))

(fn M.get [...]
  (core.get-in (M.current) [...]))

(fn M.call [fn-name ...]
  (let [f (M.get fn-name)]
    (if f
        (f ...)

        (M.current)
        (error (str.join
                 ["Conjure client '"
                  (core.get (M.current-client-module-name) :module-name)
                  "' doesn't support function: "
                  fn-name]))

        (error "No Conjure client configured for the current file type."))))

(fn M.optional-call [fn-name ...]
  (let [f (M.get fn-name)]
    (when f
      (f ...))))

(fn M.each-loaded-client [f]
  (core.run!
    (fn [{: filetype}]
      (M.with-filetype filetype f))
    (core.vals loaded)))

M
