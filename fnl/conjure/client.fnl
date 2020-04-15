(module conjure.client
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            fennel conjure.aniseed.fennel
            config conjure.config}})

;; TODO Clients: Janet, Racket, MIT Scheme.
;; https://gitlab.com/technomancy/ogion

(defonce- loaded {})

(defn- load-module [name]
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

(defn- current-filetype []
  (or overrides.filetype nvim.bo.filetype))

(defn- current-client-module-name []
  (config.filetype->module-name (current-filetype)))

(defn current []
  (let [ft (current-filetype)
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
