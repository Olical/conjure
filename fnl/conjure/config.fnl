(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))

(local M (define :conjure.config))

(fn ks->var [ks]
  (.. "conjure#" (str.join "#" ks)))

(fn M.get-in [ks]
  (let [key (ks->var ks)
        v (or (core.get vim.b key) (core.get vim.g key))]
    (if (and (core.table? v)
             (core.get v vim.type_idx)
             (core.get v vim.val_idx))
      (core.get v vim.val_idx)
      v)))

(fn M.filetypes []
  (M.get-in [:filetypes]))

(fn M.get-in-fn [prefix-ks]
  (fn [ks]
    (M.get-in (core.concat prefix-ks ks))))

(fn M.assoc-in [ks v]
  (core.assoc vim.g (ks->var ks) v)
  v)

(fn M.merge [tbl opts ks]
  "Merge a table into the config recursively. Won't overwrite any existing
  value by default, set opts.overwrite? to true if this is desired."
  (let [ks (or ks [])
        opts (or opts {})]
    (core.run!
      (fn [[k v]]
        (let [ks (core.concat ks [k])
              current (M.get-in ks)]

          ;; Is it an associative table?
          (if (and (core.table? v) (not (core.get v 1)))
            ;; Recur if so.
            (M.merge v opts ks)

            ;; Otherwise we're at a value and we can assoc it.
            (when (or (core.nil? current) opts.overwrite?)
              (M.assoc-in ks v)))))
      (core.kv-pairs tbl))
    nil))

(M.merge
  {:debug false
   :relative_file_root nil
   :path_subs nil
   :client_on_load true

   :filetypes [:clojure :elixir :fennel :janet :javascript :hy :julia :racket :scheme
               :lua :lisp :python :rust :sql :typescript :php :r]
   :filetype {:clojure :conjure.client.clojure.nrepl
              :elixir :conjure.client.elixir.stdio
              :fennel :conjure.client.fennel.nfnl
              :janet :conjure.client.janet.netrepl
              :hy :conjure.client.hy.stdio
              :julia :conjure.client.julia.stdio
              :javascript :conjure.client.javascript.stdio
              :racket :conjure.client.racket.stdio
              :scheme :conjure.client.scheme.stdio
              :lua :conjure.client.lua.neovim
              :lisp :conjure.client.common-lisp.swank
              :python :conjure.client.python.stdio
              :r :conjure.client.r.stdio
              :rust :conjure.client.rust.evcxr
              :sql :conjure.client.sql.stdio
              :typescript :conjure.client.javascript.stdio
              :php :conjure.client.php.psysh}
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
    :enable_ft_mappings true
    :enable_defaults true}

   :completion
   {:omnifunc :ConjureOmnifunc
    :fallback :syntaxcomplete#Complete}

   :highlight
   {:enabled false
    :group "IncSearch"
    :timeout 500}

   :log
   {:wrap false
    :diagnostics false
    :treesitter true
    :auto_flush_interval_ms 100
    :split {:width nil
            :height nil}
    :hud {:width 0.42
          :height 0.3
          :zindex 1
          :enabled true
          :passive_close_delay 0
          :minimum_lifetime_ms 250
          :overlap_padding 0.1
          :border :single
          :anchor :NE
          :ignore_low_priority false
          :open_when :last-log-line-not-visible}
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
   {:context_header_lines -1
    :form_pairs [["(" ")"]
                 ["{" "}"]
                 ["[" "]" true]]
    :tree_sitter {:enabled true}}

   :preview
   {:sample_limit 0.3}})

(when (M.get-in [:mapping :enable_defaults])
  (M.merge
    {:mapping
     {:log_split "ls"
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
      :eval_previous "ep"
      :def_word "gd"
      :doc_word ["K"]}}))

M
