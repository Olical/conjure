(module conjure.fs
  {require {nvim conjure.aniseed.nvim
            a conjure.aniseed.core
            str conjure.aniseed.string}})

(defn- env [k]
  (let [v (nvim.fn.getenv k)]
    (when (and (a.string? v) (not (a.empty? v)))
      v)))

(defn config-dir []
  "Return $XDG_CONFIG_HOME/conjure.
  Defaulting the config directory to $HOME/.config."
  (..  (or (env "XDG_CONFIG_HOME")
           (.. (env "HOME") "/.config"))
      "/conjure"))

(defn findfile [name path]
  "Wrapper around Neovim's findfile() that returns nil
  instead of an empty string."
  (let [res (nvim.fn.findfile name path)]
    (when (not (a.empty? res))
      res)))

(defn resolve [name]
  "Resolve a file name to it's full path by looking in the current
  directory upwards followed by $XDG_CONFIG_HOME/conjure"
  (or
    (findfile name ".;")
    (findfile name (.. (config-dir) ";"))))

(defn file-readable? [path]
  (= 1 (nvim.fn.filereadable path)))

(defn split-path [path]
  (->> (str.split path "/")
       (a.filter #(not (a.empty? $)))))

(defn join-path [parts]
  (str.join "/" (a.concat parts)))

(defn resolve-relative [path]
  "Successively remove parts of the path until we get to a relative path that
  points to a file we can read. If we run out of parts default to the original
  path."
  (let [root (nvim.fn.getcwd)]
    (fn loop [parts]
      (if (a.empty? parts)
        path
        (if (file-readable? (join-path (a.concat [root] parts)))
          (join-path parts)
          (loop (a.rest parts)))))

    (loop (split-path path))))
