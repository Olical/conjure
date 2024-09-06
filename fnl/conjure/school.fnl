(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local buffer (autoload :conjure.buffer))
(local config (autoload :conjure.config))
(local editor (autoload :conjure.editor))
(local nvim (autoload :conjure.aniseed.nvim))
(local str (autoload :conjure.aniseed.string))

(local buf-name "conjure-school.fnl")

(fn upsert-buf []
  (buffer.upsert-hidden buf-name))

(fn append [lines]
  (let [buf (upsert-buf)
        current-buf-str (str.join "\n" (nvim.buf_get_lines 0 0 -1 true))
        to-insert-str (str.join "\n" lines)]
    (when (not (string.find current-buf-str to-insert-str 0 true))
      (nvim.buf_set_lines
        buf
        (if (buffer.empty? buf) 0 -1)
        -1 false lines)
      true)))

(fn map-str [m]
  (.. (config.get-in [:mapping :prefix])
      (config.get-in [:mapping m])))

(fn progress [n]
  (.. "Lesson [" n "/7] complete!"))

(fn append-or-warn [current-progress lines]
  (if (append lines)
    (progress current-progress)
    "You've already completed this lesson! You can (u)ndo and run it again though if you'd like."))

(fn start []
  (when (not (editor.has-filetype? :fennel))
    (nvim.echo
      "Warning: No Fennel filetype found, falling back to Clojure syntax."
      "Install https://github.com/Olical/aniseed for better Fennel support.")
    (set nvim.g.conjure#filetype#clojure nvim.g.conjure#filetype#fennel)
    (nvim.ex.augroup :conjure_school_filetype)
    (nvim.ex.autocmd_)
    (nvim.ex.autocmd "BufNewFile,BufRead *.fnl setlocal filetype=clojure")
    (nvim.ex.augroup :END))

  (let [maplocalleader-was-unset?
        (when (and (= "<localleader>" (config.get-in [:mapping :prefix]))
                   (a.empty? nvim.g.maplocalleader))
          (set nvim.g.maplocalleader ",")
          true)

        buf (upsert-buf)]
    (nvim.ex.edit buf-name)
    (nvim.buf_set_lines buf 0 -1 false [])
    (append
      (a.concat
        [
         "(local {: autoload} (require :nfnl.module))"
         "(local school (require :conjure.school))"
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
        (if maplocalleader-was-unset?
          [";; Your <localleader> wasn't configured so I've defaulted it to comma (,) for now."
           ";; See :help localleader for more information. (let maplocalleader=\",\")"]
          [(.. ";; Your <localleader> is currently mapped to \"" nvim.g.maplocalleader "\"")])
        ["(school.lesson-1)"]))))

(fn lesson-1 []
  (append-or-warn
    1
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
        "  (school.lesson-2))"]))

(fn lesson-2 []
  (append-or-warn
    2
    [""
     ";; Awesome! You evaluated the inner form under your cursor."
     (.. ";; If we want to evaluate the outermost form under our cursor, we can use " (map-str :eval_root_form) " instead.")
     ";; Try that below to print some output and advance to the next lesson."
     ";; You can place your cursor anywhere inside the (do ...) form or it's children."
     "(do"
        "  (print \"Hello, World!\")"
        "  (school.lesson-3))"]))

(fn lesson-3 []
  (append-or-warn
    3
    [""
     ";; You evaluated the outermost form! Nice!"
     ";; Notice that the print output was captured and displayed in the log too."
     ";; The result of every evaluation is stored in a Neovim register as well as the log."
     (.. ";; Try pressing \"" (config.get-in [:eval :result_register]) "p to paste the contents of the register into your buffer.")
     (.. ";; We can also evaluate a form and replace it with the result of the evaluation with " (map-str :eval_replace_form))
     (.. ";; We'll try that in the next lesson, place your cursor inside the form below and press " (map-str :eval_replace_form))
     "(school.lesson-4)"]))

(fn lesson-4 []
  (append-or-warn
    4
    [""
     ";; Well done! Notice how the resulting string in the log also replaced the form in the buffer!"
     ";; Next let's try evaluating a form at a mark."
     ";; Place your cursor on the next lesson form below and use mf to set the f mark at that location."
     (.. ";; Now move your cursor elsewhere in the buffer and use " (map-str :eval_marked_form) "f to evaluate it.")
     ";; If you use a capital letter like mF you can even open a different file and evaluate that marked form without changing buffers!"
     "(school.lesson-5)"]))

(local lesson-5-message
  "This is the contents of school.lesson-5-message!")

(fn lesson-5 []
  (append-or-warn
    5
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
     "(school.lesson-6)"]))

(local lesson-6-message
  "This is the contents of school.lesson-6-message!")

(fn lesson-6 []
  (append-or-warn
    6
    [""
     ";; Wonderful!"
     ";; Visual evaluation is great for specific sections of a form."
     (.. ";; You can also evaluate a given motion with " (map-str :eval_motion))
     (.. ";; Try " (map-str :eval_motion) "iw below to evaluate the word.")
     "school.lesson-6-message"
     ""
     (.. ";; Use " (map-str :eval_motion) "a( to evaluate the lesson form.")
         "(school.lesson-7)"]))

(fn lesson-7 []
  (append-or-warn
    7
    [""
     ";; Excellent job, you made it to the end!"
     ";; To learn more about configuring Conjure, install the plugin and check out :help conjure"
     ";; You can learn about specific languages with :help conjure-client- and then tab completion."
     ";; For example, conjure-client-fennel-aniseed or conjure-client-clojure-nrepl."
     ""
     ";; I hope you have a wonderful time in Conjure!"]))

{
 : start
 : lesson-1
 : lesson-2
 : lesson-3
 : lesson-4
 : lesson-5
 : lesson-6
 : lesson-7
 : lesson-5-message
 : lesson-6-message
 }
