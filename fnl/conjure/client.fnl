(module conjure.client
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            fennel conjure.aniseed.fennel
            config conjure.config
            dyn conjure.dynamic}})

(def- state-key (dyn.new #(do :default)))

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

(defn- load-module [name]
  (let [(ok? result) (xpcall
                       (fn []
                         (require name))
                       fennel.traceback)]

    (when (a.nil? (a.get loaded name))
      (a.assoc loaded name true)
      (when result.on-load
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

(defn- current-client-module-name []
  (a.get (config.get-in [:filetype_client]) (filetype)))

(defn current []
  (let [ft (filetype)
        mod-name (current-client-module-name)]
    (if mod-name
      (load-module mod-name)
      (error (.. "No Conjure client for filetype: '" ft "'")))))

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
