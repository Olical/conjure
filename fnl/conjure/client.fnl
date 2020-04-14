(module conjure.client
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            fennel conjure.aniseed.fennel
            config conjure.config}})

(defonce- loaded {})

(defn- smart-require [name]
  (let [(ok? result) (xpcall
                       (fn []
                         (require name))
                       fennel.traceback)]

    (when (a.nil? (a.get loaded name))
      (a.assoc loaded name true)
      (when result.on-load
        (result.on-load)))

    (if ok?
      result
      (error result))))

(defonce- overrides {})

(defn with-filetype [ft f ...]
  (set overrides.filetype ft)
  (let [(ok? result) (pcall f ...)]
    (set overrides.filetype nil)
    (if ok?
      result
      (error result))))

(defn current []
  (let [ft (or overrides.filetype nvim.bo.filetype)
        mod-name (config.filetype->module-name ft)]
    (if mod-name
      (smart-require mod-name)
      (error (.. "No Conjure client for filetype: '" ft "'")))))

(defn get [k]
  (-?> (current)
       (. k)))

(defn call [fn-name ...]
  (let [f (get fn-name)]
    (when f
      (f ...))))
