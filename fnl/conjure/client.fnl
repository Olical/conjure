(module conjure.client
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            fennel conjure.aniseed.fennel
            config conjure.config
            dyn conjure.dynamic}})

(defonce- loaded {})
(defonce- client-states {})

(defn state [...]
  (a.get-in client-states [...]))

(defn state-fn [...]
  (let [prefix [...]]
    (fn [...]
      (let [ks (a.concat prefix [...])]
        (state (unpack ks))))))

(defn init-state [ks default]
  (when (not (a.get-in client-states ks))
    (a.assoc-in client-states ks default)))

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
