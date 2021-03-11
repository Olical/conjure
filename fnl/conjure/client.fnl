(module conjure.client
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            fennel conjure.aniseed.fennel
            str conjure.aniseed.string
            config conjure.config
            dyn conjure.dynamic}})

(defonce state-key (dyn.new #(do :default)))

(defonce- state
  {:state-key-set? false})

(defn set-state-key! [new-key]
  (set state.state-key-set? true)
  (dyn.set-root! state-key #(do new-key)))

(defn multiple-states? []
  state.state-key-set?)

(defn new-state [init-fn]
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

(defonce- loaded {})

(defn- load-module [ft name]
  (let [(ok? result) (xpcall
                       (fn []
                         (require name))
                       fennel.traceback)]

    (when (and ok? (a.nil? (a.get loaded name)))
      (a.assoc loaded name
               {:filetype ft
                :module-name name
                :module result})
      (when (and result.on-load (not nvim.wo.diff))
        (vim.schedule result.on-load)))

    (if ok?
      result
      (error result))))

(def- filetype (dyn.new #(do nvim.bo.filetype)))

(defn with-filetype [ft f ...]
  (dyn.bind {filetype #(do ft)} f ...))

(defn wrap [f ...]
  (let [opts {filetype (a.constantly (filetype))
              state-key (a.constantly (state-key))}
        args [...]]
    (fn [...]
      (if (not= 0 (a.count args))
        (dyn.bind opts f (unpack args) ...)
        (dyn.bind opts f ...)))))

(defn schedule-wrap [f ...]
  (wrap (vim.schedule_wrap f) ...))

(defn schedule [f ...]
  (vim.schedule (wrap f ...)))

(defn- current-client-module-name []
  (var result nil)
  (let [ft (filetype)
        ext (nvim.fn.expand "%:e")
        fts (when ft
              (str.split ft "%."))]
    (when fts
      (for [i (a.count fts) 1 -1]
        (let [ft-part (. fts i)
              mod-name (config.get-in [:filetype ft-part])
              suffixes (config.get-in [:filetype_suffixes ft-part])]
          (when (and (not result) mod-name
                     (or (not suffixes)
                         (a.some #(= ext $) suffixes)))
            (set result mod-name))))))
  result)

(defn current []
  (let [ft (filetype)
        mod-name (current-client-module-name)]
    (if mod-name
      (load-module ft mod-name)
      (error (.. "No Conjure client for filetype: '" (or ft "nil") "'")))))

(defn get [...]
  (a.get-in (current) [...]))

(defn call [fn-name ...]
  (let [f (get fn-name)]
    (if f
      (f ...)
      (error (.. "Conjure client '"
                 (current-client-module-name)
                 "' doesn't support function: "
                 fn-name)))))

(defn optional-call [fn-name ...]
  (let [f (get fn-name)]
    (when f
      (f ...))))

(defn each-loaded-client [f]
  (a.run!
    (fn [{: filetype}]
      (with-filetype filetype f))
    (a.vals loaded)))
