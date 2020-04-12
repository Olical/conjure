(module conjure.school
  {require {nvim conjure.aniseed.nvim
            buffer conjure.buffer
            config conjure.config
            a conjure.aniseed.core}})

(def- log-buf-name "conjure-school.fnl")

(defn- upsert-buf []
  (buffer.upsert-hidden log-buf-name))

(defn- go-to-bottom [buf]
  (nvim.win_set_cursor
    0
    [(nvim.buf_line_count buf) 0]))

(defn- append [lines]
  (let [buf (upsert-buf)]
    (nvim.buf_set_lines
      buf
      (if (buffer.empty? buf) 0 -1)
      -1 false lines)))

(defn- map-str [m]
  (.. config.mappings.prefix (a.get-in config [:mappings m])))

(defn start []
  (let [buf (upsert-buf)]
    (nvim.ex.edit log-buf-name)
    (nvim.buf_set_lines buf 0 -1 false [])
    (append
      ["(module user.conjure-school"
       "  {require {school conjure.school}})"
       ""
       ";; Welcome to Conjure school!"
       ";; Run :ConjureSchool again at any time to start fresh."
       ";; This is a Fennel buffer, we can evaluate parts of it using Conjure."
       ";; Conjure will compile the Fennel to Lua and execute it within Neovim's process."
       (.. ";; Try evaluating this buffer with " (map-str :eval-buf))
       "(school.lesson-1)"])))

(defn lesson-1 []
  (append [""
           ";; Congratulations, you just evaluated this code!"
           ";; Notice how a window appeared with a `nil` inside it? That's the log HUD."
           ";; The log will retain a list of your requests and their results."
           ";; The HUD allows us to see what's going on in the log when we're not watching."
           ";; We can open that buffer and edit it to our hearts content, it's a normal buffer!"
           ";; We can even evaluate code from inside the buffer itself, just like a REPL."
           ""
           (.. ";; The HUD will close when you move your cursor or hit " (map-str :close-hud))
           (.. ";; You can open the log vertically (" (map-str :log-vsplit) ") or horizontally (" (map-str :log-split) ").")
           (.. ";; For a full screen experience, a new tab may be better. (" (map-str :log-tab) ").")
           ";; Give some of those a go, you can just close the log window as you normally would."]))
