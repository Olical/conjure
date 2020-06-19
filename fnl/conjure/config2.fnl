(module conjure.config2
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string}})

;; TODO Create shim + warning for g:conjure_config and :ConjureConfig.
;; TODO Transition clients to client and mappings to mapping.

(defn ks->var [ks]
  (.. "conjure_" (str.join "_" ks)))

(defn get-in [ks]
  (let [v (a.get nvim.g (ks->var ks))]
    (if (and (a.table? v)
             (a.get v vim.type_idx)
             (a.get v vim.val_idx))
      (a.get v vim.val_idx)
      v)))

(defn assoc-in [ks v]
  (a.assoc nvim.g (ks->var ks) v)
  v)

(defn merge [tbl opts ks]
  "Merge a table into the config recursively. Won't overwrite any existing
  value by default, set opts.overwrite? to true if this is desired."
  (let [ks (or ks [])
        opts (or opts {})]
    (a.run!
      (fn [[k v]]
        (let [ks (a.concat ks [k])
              current (get-in ks)]

          ;; Is it an associative table?
          (if (and (a.table? v) (not (a.get v 1)))
            ;; Recur if so.
            (merge v opts ks)

            ;; Otherwise we're at a value and we can assoc it.
            (when (or (a.nil? current) opts.overwrite?)
              (assoc-in ks v)))))
      (a.kv-pairs tbl))
    nil))

(defn init []
  (assoc-in
    [:client]
    {:fennel :conjure.client.fennel.aniseed
     :clojure :conjure.client.clojure.nrepl
     :janet :conjure.client.janet.netrepl})

  (merge
    {:debug false

     :eval
     {:result-register "c"}

     :mapping
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
      :def-word ["gd"]}

     :log
     {:hud {:width 0.42
            :height 0.3
            :enabled true
            :passive-close-delay 0}
      :botright false
      :break-length 80
      :trim {:at 10000
             :to 6000}
      :strip-ansi-escape-sequences-line-limit 100}

     :extract
     {:context-header-lines 24
      :form-pairs [["(" ")"]
                   ["{" "}"]
                   ["[" "]" true]]}

     :preview
     {:sample-limit 0.3}}))
