(module conjure.fs
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string
            config conjure.config}})

(defn- env [k]
  (let [v (nvim.fn.getenv k)]
    (when (and (a.string? v) (not (a.empty? v)))
      v)))

(defn exists? [p]
  "Takes a path and returns its type if its exists."
  (assert
    (= "string" (type p))
    (.. "`exists` expected string got " (type p)))
  (let [stat (vim.loop.fs_stat p)]
    (if stat stat.type false)))

(defn ensure [p]
  "Takes a path and ensure it exist."
  (assert
    (= :string (type p))
    (.. "`ensure` expected string got " (type p)))
  (when (not (exists? p))
    (if (= nil (string.match p "%.%w+"))
      (let [handle (vim.loop.fs_open p "w" 438)]
        (vim.loop.fs_close handle))
      (vim.loop.fs_mkdir p 493)))
  p)

(defn config-dir []
  "Return $XDG_CONFIG_HOME/conjure.
  Defaulting the config directory to $HOME/.config."
  (..  (or (env "XDG_CONFIG_HOME")
           (.. (env "HOME") "/.config"))
      "/conjure"))

(defn cache-dir []
  "Return $XDG_CACHE_HOME/conjure.
  Defaulting the config directory to $HOME/.cache."
  (ensure (..  (or (env "XDG_CACHE_HOME")
                   (.. (env "HOME") "/.config"))
              "/conjure")))

(defn findfile [name path]
  "Wrapper around Neovim's findfile() that returns nil
  instead of an empty string."
  (let [res (nvim.fn.findfile name path)]
    (when (not (a.empty? res))
      res)))

(defn resolve-above [name]
  "Resolve a pathless file name to an absolute path by looking in the
  containing and parent directories of the current file, current working
  direcotry and finally $XDG_CONFIG_HOME/conjure"
  (or
    (findfile name ".;")
    (findfile name (.. (nvim.fn.getcwd) ";"))
    (findfile name (.. (config-dir) ";"))))

(defn file-readable? [path]
  (= 1 (nvim.fn.filereadable path)))

(defn split-path [path]
  (->> (str.split path "/")
       (a.filter #(not (a.empty? $)))))

(defn join-path [parts]
  (str.join "/" (a.concat parts)))

(defn resolve-relative-to [path root]
  "Successively remove parts of the path until we get to a relative path that
  points to a file we can read from the root. If we run out of parts default to
  the original path."
  (fn loop [parts]
    (if (a.empty? parts)
      path
      (if (file-readable? (join-path (a.concat [root] parts)))
        (join-path parts)
        (loop (a.rest parts)))))

  (loop (split-path path)))

(defn resolve-relative [path]
  "If g:conjure#relative_file_root is set, will resolve the path relative to
  that. Will return the original path immidiately if not."
  (let [relative-file-root (config.get-in [:relative_file_root])]
    (if relative-file-root
      (resolve-relative-to path relative-file-root)
      path)))

