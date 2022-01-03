(module conjure.client.lua.neovim
  {autoload {a conjure.aniseed.core
             str conjure.aniseed.string
             nvim conjure.aniseed.nvim
             stdio conjure.remote.stdio
             config conjure.config
             text conjure.text
             mapping conjure.mapping
             client conjure.client
             log conjure.log}
   require-macros [conjure.macros]})

(def- cfg (config.get-in-fn [:client :lua :neovim]))

(def buf-suffix ".lua")
(def comment-prefix "-- ")

(defn- with-repl-or-warn [f opts]
  (let [repl (state :repl)]
    (if repl
      (f repl)
      (log.append [(.. comment-prefix "No REPL running")]))))

(defn- display [out ret err]
  (let [outs (->> (str.split (or out "") "\n")
              (a.filter #(~= "" $1))
              (a.map #(.. comment-prefix "(out) " $1)))
        errs (->> (str.split (or err "") "\n")
              (a.filter #(~= "" $1))
              (a.map #(.. comment-prefix "(err) " $1)))]
    (log.append outs)
    (log.append errs)
    (log.append (str.split (vim.inspect ret) "\n"))))

(def- print_original _G.print)
(def- io_write_original _G.io.write)
(global CONJURE_NVIM_REDIRECTED "")

(defn- redirect []
  (set _G.print
   (fn [...]
    (global CONJURE_NVIM_REDIRECTED
      (.. CONJURE_NVIM_REDIRECTED (str.join "\t" [...]) "\n"))))
  (set _G.io.write
   (fn [...]
    (global CONJURE_NVIM_REDIRECTED
      (.. CONJURE_NVIM_REDIRECTED (str.join [...]))))))

(defn- end-redirect []
  (set _G.print print_original)
  (set _G.io.write io_write_original)
  (let [result CONJURE_NVIM_REDIRECTED]
    (global CONJURE_NVIM_REDIRECTED "")
    result))

(defn- lua-try-compile [codes]
 (let [(f e) (load (.. "return (" codes "\n)"))]
  (if f (values f e) (load codes))))

(defn- lua-eval [codes]
  (let [(f e) (lua-try-compile codes)]
   (if f
    (do
     (redirect)
     (let [(status ret) (pcall f)]
      (if status
       (values (end-redirect) ret "")
       (values (end-redirect) nil (.. "Execution error: " ret)))))
    (values "" nil (.. "Compilation error: " e)))))

(defn eval-str [opts]
  (let [(out ret err) (lua-eval opts.code)]
   (do
     (display out ret err)
     (when (. opts :on-result)
      (let [on-result (. opts :on-result)]
       ((. opts :on-result) (vim.inspect ret)))))))

(defn eval-file [opts]
  (redirect)
  (let [(ret err) ((loadfile (. opts :file-path)))]
   (display (end-redirect) ret err)
   (when (. opts :on-result)
    (let [on-result (. opts :on-result)]
     ((. opts :on-result) (vim.inspect ret))))))
