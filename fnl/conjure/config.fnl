(module conjure.config
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string}})

(def clients
  {:fennel :conjure.client.fennel.aniseed
   :clojure :conjure.client.clojure.nrepl})

(def eval
  {:result-register "c"})

(def mappings
  {:prefix "<localleader>"
   :log-split "ls"
   :log-vsplit "lv"
   :log-tab "lt"
   :log-close-visible "lq"
   :eval-current-form "ee"
   :eval-root-form "er"
   :eval-replace-form "e!"
   :eval-marked-form "em"
   :eval-word "ew"
   :eval-file "ef"
   :eval-buf "eb"
   :eval-visual "E"
   :eval-motion "E"
   :doc-word ["K"]
   :def-word ["gd"]})

(def log
  {:hud {:width 0.42
         :height 0.3
         :enabled? true}
   :break-length 80
   :trim {:at 10000
          :to 6000}})

(def extract
  {:context-header-lines 24})

(def preview
  {:sample-limit 0.3})

(defn filetypes []
  (a.keys clients))

(defn filetype->module-name [filetype]
  (. clients filetype))

(defn- require-client [suffix]
  "Requires a client module, will try with a 'conjure.client.' prefix first
  then unprefixed. This allows internal and external modules to work."
  (let [attempts [(.. "conjure.client." suffix) suffix]]
    (or (a.some
          (fn [name]
            (let [(ok? mod-or-err) (pcall #(require name))]
              (when ok?
                mod-or-err)))
          attempts)
        (error (.. "No Conjure client found, attempted: " (str.join ", " attempts))))))

(defn get [{: client : path}]
  (a.get-in
    (if client
      (a.get (require-client client) :config)
      (require :conjure.config))
    path))

(defn assoc [{: client : path : val}]
  (a.assoc-in
    (if client
      (a.get (require-client client) :config)
      (require :conjure.config))
    path
    val))

(defn env [k]
  (let [v (nvim.fn.getenv k)]
    (when (and (a.string? v) (not (a.empty? v)))
      v)))
