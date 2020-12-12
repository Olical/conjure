(module conjure.school
  {require {nvim conjure.aniseed.nvim
            buffer conjure.buffer
            config conjure.config
            editor conjure.editor
            str conjure.aniseed.string
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
  (.. (config.get-in [:mapping :prefix])
      (config.get-in [:mapping m])))

(defn- progress [n]
  (.. "Lesson ["n "/7] complete!"))

(defn start []
  (when (not (editor.has-filetype? :fennel))
    (a.println
      (.. "Warning: No Fennel filetype found, falling back to Clojure syntax.\n"
          "Install https://github.com/bakpakin/fennel.vim for better Fennel support.\n"))
    (set nvim.g.conjure#filetype_client
         (a.assoc nvim.g.conjure#filetype_client :clojure
                  nvim.g.conjure#filetype_client.fennel))
    (nvim.ex.augroup :conjure_school_filetype)
    (nvim.ex.autocmd_)
    (nvim.ex.autocmd "BufNewFile,BufRead *.fnl setlocal filetype=clojure")
    (nvim.ex.augroup :END))

  (let [buf (upsert-buf)]
    (nvim.ex.edit buf-name)
    (nvim.buf_set_lines buf 0 -1 false [])
    (append
      (a.concat
        ["(module user.conjure-school"
         "  {require {school conjure.school"
         "            nvim conjure.aniseed.nvim}})"
         ""
         ";; Welcome to Conjure school!"
         ";; Grab yourself a nice beverage and let's get evaluating. I hope you enjoy!"
         ""
         ";; This language is Fennel, it's quite similar to Clojure."
         ";; Conjure is written in Fennel, it's compiled to Lua and executed inside Neovim itself."
         ";; This means we can work with a Lisp without installing or running anything else."
         ""
         ";; Note: Some colorschemes will make the HUD unreadable, see here for more: https://git.io/JJ1Hl"
         ""
         ";; Let's learn how to evaluate it using Conjure's assortment of mappings."
         ";; You can learn how to change these mappings with :help conjure-mappings"
         ""
         (.. ";; Let's begin by evaluating the whole buffer using " (map-str :eval_buf))]
        (when (= "<localleader>" (config.get-in [:mapping :prefix]))
          (if (a.empty? nvim.g.maplocalleader)
            (do
              (set nvim.g.maplocalleader ",")
              (nvim.ex.edit)
              [";; Your <localleader> wasn't configured so I've defaulted it to comma (,) for now."
               ";; See :help localleader for more information. (let maplocalleader=\",\")"])
            [(.. ";; Your <localleader> is currently mapped to \"" nvim.g.maplocalleader "\"")]))
        ["(school.lesson-1)"]))))

(defn lesson-1 []
  (append
    [""
     ";; Good job!"
     ";; You'll notice the heads up display (HUD) appeared showing the result of the evaluation."
     ";; All results are appended to a log buffer. If that log is not open, the HUD will appear."
     ";; The HUD closes automatically when you move your cursor."
     ""
     ";; You can open the log buffer in a few ways:"
     (.. ";;  * Horizontally - " (map-str :log_split))
     (.. ";;  * Vertically - " (map-str :log_vsplit))
     (.. ";;  * New tab - " (map-str :log_tab))
     ""
     (.. ";; All visible log windows (including the HUD) can be closed with " (map-str :log_close_visible))
     ";; Try opening and closing the log window to get the hang of those key mappings."
     ";; It's a regular window and buffer, so you can edit and close it however you want."
     ";; Feel free to leave the log open in a split for the next lesson to see how it behaves."
     ""
     ";; If you ever need to clear your log you can use the reset mappings:"
     (.. ";; * Soft reset (leaves windows open) - " (map-str :log_reset_soft))
     (.. ";; * Hard reset (closes windows, deletes the buffer) - " (map-str :log_reset_hard))
     ""
     ";; Next, we have a form inside a comment. We want to evaluate that inner form, not the comment."
     (.. ";; Place your cursor on the inner form (the one inside the comment) and use " (map-str :eval_current_form) " to evaluate it.")
     "(comment"
     "  (school.lesson-2))"])
  (progress 1))

(defn lesson-2 []
  (append
    [""
     ";; Awesome! You evaluated the inner form under your cursor."
     (.. ";; If we want to evaluate the outermost form under our cursor, we can use " (map-str :eval_root_form) " instead.")
     ";; Try that below to print some output and advance to the next lesson."
     ";; You can place your cursor anywhere inside the (do ...) form or it's children."
     "(do"
     "  (print \"Hello, World!\")"
     "  (school.lesson-3))"])
  (progress 2))

(defn lesson-3 []
  (append
    [""
     ";; You evaluated the outermost form! Nice!"
     ";; Notice that the print output was captured and displayed in the log too."
     ";; The result of every evaluation is stored in a Neovim register as well as the log."
     (.. ";; Try pressing \"" (config.get-in [:eval :result_register]) "p to paste the contents of the register into your buffer.")
     (.. ";; We can also evaluate a form and replace it with the result of the evaluation with " (map-str :eval_replace_form))
     (.. ";; We'll try that in the next lesson, place your cursor inside the form below and press " (map-str :eval_replace_form))
     "(school.lesson-4)"])
  (progress 3))

(defn lesson-4 []
  (append
    [""
     ";; Well done! Notice how the resulting string in the log also replaced the form in the buffer!"
     ";; Next let's try evaluating a form at a mark."
     ";; Place your cursor on the next lesson form below and use mf to set the f mark at that location."
     (.. ";; Now move your cursor elsewhere in the buffer and use " (map-str :eval_marked_form) "f to evaluate it.")
     ";; If you use a capital letter like mF you can even open a different file and evaluate that marked form without changing buffers!"
     "(school.lesson-5)"])
  (progress 4))

(def lesson-5-message
  "This is the contents of school.lesson-5-message!")

(defn lesson-5 []
  (append
    [""
     ";; Excellent!"
     ";; This is extremely useful when you want to evaluate a specific form repeatedly as you change code elsewhere in the file or project."
     (.. ";; Try inspecting the contents of the variable below by placing your cursor on it and pressing " (map-str :eval_word))
     "school.lesson-5-message"
     ""
     ";; You should see the contents in the HUD or log."
     ""
     (.. ";; You can evaluate visual selections with " (map-str :eval_visual))
     ";; Try evaluating the form below using a visual selection."
     "(school.lesson-6)"])
  (progress 5))

(def lesson-6-message
  "This is the contents of school.lesson-6-message!")

(defn lesson-6 []
  (append
    [""
     ";; Wonderful!"
     ";; Visual evaluation is great for specific sections of a form."
     (.. ";; You can also evaluate a given motion with " (map-str :eval_motion))
     (.. ";; Try " (map-str :eval_motion) "iw below to evaluate the word.")
     "school.lesson-6-message"
     ""
     (.. ";; Use " (map-str :eval_motion) "a( to evaluate the lesson form.")
     "(school.lesson-7)"])
  (progress 6))

(defn lesson-7 []
  (append
    [""
     ";; Excellent job, you made it to the end!"
     ";; To learn more about configuring Conjure check out :help conjure"
     ";; You can learn about specific languages with :help conjure-client- and then tab completion."
     ";; For example, conjure-client-fennel-aniseed or conjure-client-clojure-nrepl."
     (.. ";; Evaluate the form below to open Conjure's help with " (map-str :eval_current_form))
     "(nvim.ex.help :conjure)"
     ""
     ";; I hope you have a wonderful time in Conjure!"])
  (progress 7))
