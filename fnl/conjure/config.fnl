(module conjure.config
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             str conjure.aniseed.string}})

(defn- ks->var [ks]
  (.. "conjure#" (str.join "#" ks)))

(defn get-in [ks]
  (let [key (ks->var ks)
        v (or (a.get nvim.b key) (a.get nvim.g key))]
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
   :client_on_load true

   :filetypes [:clojure :fennel :janet :hy :julia :racket :scheme :lua :lisp :python :rust]
   :filetype {:clojure :conjure.client.clojure.nrepl
              :fennel :conjure.client.fennel.aniseed
              :janet :conjure.client.janet.netrepl
              :hy :conjure.client.hy.stdio
              :julia :conjure.client.julia.stdio
              :racket :conjure.client.racket.stdio
              :scheme :conjure.client.scheme.stdio
              :lua :conjure.client.lua.neovim
              :lisp :conjure.client.common-lisp.swank
              :python :conjure.client.python.stdio
              :rust :conjure.client.rust.evcxr}
   :filetype_suffixes {:racket [:rkt]
                       :scheme [:scm :ss]}

   :eval
   {:result_register "c"
    :inline_results true
    :inline {:highlight :comment
             :prefix "=> "}
    :comment_prefix nil
    :gsubs {}}

   :mapping
   {:prefix "<localleader>"

    :log_split "ls"
    :log_vsplit "lv"
    :log_tab "lt"
    :log_buf "le"
    :log_toggle "lg"
    :log_close_visible "lq"
    :log_reset_soft "lr"
    :log_reset_hard "lR"
    :log_jump_to_latest "ll"

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

   :highlight
   {:enabled false
    :group "IncSearch"
    :timeout 500}

   :log
   {:wrap false
    :hud {:width 0.42
          :height 0.3
          :enabled true
          :passive_close_delay 0
          :minimum_lifetime_ms 20
          :overlap_padding 0.1
          :border :single
          :anchor :NE
          :ignore_low_priority false}
    :botright false
    :jump_to_latest {:enabled false
                     :cursor_scroll_position "top"}
    :break_length 80
    :trim {:at 10000
           :to 6000}
    :strip_ansi_escape_sequences_line_limit 1000
    :fold {:enabled false
           :lines 10
           :marker {:start "~~~%{"
                    :end "}%~~~"}}}

   :extract
   {:context_header_lines 24
    :form_pairs [["(" ")"]
                 ["{" "}"]
                 ["[" "]" true]]
    :tree_sitter {:enabled true}}

   :preview
   {:sample_limit 0.3}})
