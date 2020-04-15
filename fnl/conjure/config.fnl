(module conjure.config
  {require {a conjure.aniseed.core}})

(def clients
  {:fennel :conjure.client.fennel.aniseed
   :clojure :conjure.client.clojure.nrepl})

(def mappings
  {:prefix "<localleader>"
   :log-split "ls"
   :log-vsplit "lv"
   :log-tab "lt"
   :eval-current-form "ee"
   :eval-root-form "er"
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

;; TODO Try to require conjure.client.* then try global.
(defn get [{: client : path}]
  (a.get-in
    (if client
      (a.get (require (.. "conjure.client." client)) :config)
      (require :conjure.config))
    path))

(defn assoc [{: client : path : val}]
  (a.assoc-in
    (if client
      (a.get (require (.. "conjure.client." client)) :config)
      (require :conjure.config))
    path
    val))
