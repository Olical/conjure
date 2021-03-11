(module conjure.config
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string}})

(defn- ks->var [ks]
  (.. "conjure#" (str.join "#" ks)))

(defn get-in [ks]
  (let [v (a.get nvim.g (ks->var ks))]
    (if (and (a.table? v)
             (a.get v vim.type_idx)
             (a.get v vim.val_idx))
      (a.get v vim.val_idx)
      v)))

(defn filetypes []
  (get-in [:filetypes]))

(defn get-in-fn [prefix-ks]
  (fn [ks]
    (get-in (a.concat prefix-ks ks))))

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

(merge
  {:debug false
   :relative_file_root nil
   :path_subs nil

   :filetypes [:clojure :fennel :janet :racket :hy :guile]
   :filetype_suffixes {:racket [:rkt]}
   :filetype {:fennel :conjure.client.fennel.aniseed
              :racket :conjure.client.racket.stdio
              :clojure :conjure.client.clojure.nrepl
              :janet :conjure.client.janet.netrepl
              :hy :conjure.client.hy.stdio
              :scheme :conjure.client.mit-scheme.stdio
              :guile :conjure.client.guile.socket}

   :eval
   {:result_register "c"
    :inline_results true
    :comment_prefix nil}

   :mapping
   {:prefix "<localleader>"

    :log_split "ls"
    :log_vsplit "lv"
    :log_tab "lt"
    :log_close_visible "lq"
    :log_reset_soft "lr"
    :log_reset_hard "lR"

    :eval_current_form "ee"
    :eval_comment_current_form "ece"

    :eval_root_form "er"
    :eval_comment_root_form "ecr"

    :eval_word "ew"
    :eval_comment_word "ecw"

    :eval_replace_form "e!"
    :eval_marked_form "em"
    :eval_file "ef"
    :eval_buf "eb"
    :eval_visual "E"
    :eval_motion "E"
    :def_word "gd"
    :doc_word ["K"]}

   :completion
   {:omnifunc :ConjureOmnifunc
    :fallback :syntaxcomplete#Complete}

   :log
   {:wrap false
    :hud {:width 0.42
          :height 0.3
          :enabled true
          :passive_close_delay 0
          :overlap_padding 0.1
          :anchor :NE}
    :botright false
    :break_length 80
    :trim {:at 10000
           :to 6000}
    :strip_ansi_escape_sequences_line_limit 100
    :fold {:enabled false
           :lines 10
           :marker {:start "~~~%{"
                    :end "}%~~~"}}}

   :extract
   {:context_header_lines 24
    :form_pairs [["(" ")"]
                 ["{" "}"]
                 ["[" "]" true]]
    :tree_sitter {:enabled false}}

   :preview
   {:sample_limit 0.3}})
