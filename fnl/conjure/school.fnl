(module conjure.school
  {require {nvim conjure.aniseed.nvim
            buffer conjure.buffer
            config conjure.config
            editor conjure.editor
            a conjure.aniseed.core}})

(def- buf-name "conjure-school.fnl")

(defn- upsert-buf []
  (buffer.upsert-hidden buf-name))

(defn- append [lines]
  (let [buf (upsert-buf)]
    (nvim.buf_set_lines
      buf
      (if (buffer.empty? buf) 0 -1)
      -1 false lines)))

(defn- map-str [m]
  (.. config.mappings.prefix (a.get-in config [:mappings m])))

(defn- progress [n]
  (.. "Lesson ["n "/?] complete!"))

(defn start []
  (when (not (editor.has-filetype? :fennel))
    (a.println
      (.. "Warning: No Fennel filetype found, falling back to Clojure syntax.\n"
          "Install https://github.com/bakpakin/fennel.vim for better Fennel support.\n"))
    (nvim.ex.augroup :conjure_school_filetype)
    (nvim.ex.autocmd_)
    (nvim.ex.autocmd "BufNewFile,BufRead *.fnl set filetype=fennel | set syntax=clojure")
    (nvim.ex.augroup :END))

  (let [buf (upsert-buf)]
    (nvim.ex.edit buf-name)
    (nvim.buf_set_lines buf 0 -1 false [])
    (append
      (a.concat
        [";; Warning: This is under active development and isn't finished."
         ""
         "(module user.conjure-school"
         "  {require {school conjure.school}})"
         ""
         ";; Welcome to Conjure school, I hope you enjoy your time here!"
         ";; This language is Fennel, it's quite similar to Clojure."
         ";; Let's learn how to evaluate it using Conjure's assortment of mappings."
         ";; You can learn how to change these mappings with :help conjure-mappings"
         ""
         (.. ";; Let's begin by evaluating the whole buffer using " (map-str :eval-buf))]
        (when (= "<localleader>" config.mappings.prefix)
          [(.. ";; Your <localleader> is currently mapped to " nvim.g.maplocalleader)])
        ["(school.lesson-1)"]))))

(defn lesson-1 []
  (append
    [""
     ";; Good job!"
     ";; You'll notice the heads up display (HUD) appeared showing the result of the evaluation."
     ";; All results are appended to the log buffer, when you don't have the log open the HUD will appear."
     ";; The HUD closes automatically when you move your cursor."
     ""
     (.. ";; You can open the log buffer horizontally (" (map-str :log-split) "), vertically (" (map-str :log-vsplit) ") or in a tab (" (map-str :log-tab) ").")
     (.. ";; All visible log windows (including the HUD) can be closed with " (map-str :log-close-visible))
     ";; Try opening and closing the log window to get the hang of it now."
     ";; It's a regular window and buffer, so you can edit and close it however you want!"
     ";; Feel free to leave it open in a split for the next lesson to see how it behaves."
     ""
     ";; Next, we have a form inside a comment. We want to evaluate that inner form, not the comment."
     (.. ";; Place your cursor on the inner form (the one inside the comment) and use " (map-str :eval-current-form) " to evaluate it.")
     "(comment"
     "  (school.lesson-2))"])
  (progress 1))

(defn lesson-2 []
  (append
    [""
     ";; Awesome! You evaluated the form under your cursor."
     (.. ";; If we want to evaluate the outermost form under our cursor, we can use " (map-str :eval-root-form) " instead.")
     ";; Try that below to print some output and advance to the next lesson."
     ";; You can place your cursor anywhere inside the (do ...) form."
     "(do"
     "  (print \"Hello, World!\")"
     "  (school.lesson-3))"])
  (progress 2))

(defn lesson-3 []
  (append
    [])
  (progress 3))
