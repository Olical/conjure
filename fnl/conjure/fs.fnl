(module conjure.fs
  {autoload {nvim conjure.aniseed.nvim
             a conjure.aniseed.core
             text conjure.text
             str conjure.aniseed.string
             afs conjure.aniseed.fs
             config conjure.config}})

(defn- env [k]
  (let [v (nvim.fn.getenv k)]
    (when (and (a.string? v) (not (a.empty? v)))
      v)))

(defn config-dir []
  "Return $XDG_CONFIG_HOME/conjure.
  Defaulting the config directory to $HOME/.config."
  (..  (or (env "XDG_CONFIG_HOME")
           (.. (env "HOME") afs.path-sep ".config"))
      afs.path-sep "conjure"))

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
  (->> (str.split path afs.path-sep)
       (a.filter #(not (a.empty? $)))))

(defn join-path [parts]
  (str.join afs.path-sep (a.concat parts)))

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
  that. Will return the original path immediately if not."
  (let [relative-file-root (config.get-in [:relative_file_root])]
    (if relative-file-root
      (resolve-relative-to path relative-file-root)
      path)))

(defn apply-path-subs [path path-subs]
  (a.reduce
    (fn [path [pat rep]]
      (path:gsub pat rep))
    path
    (a.kv-pairs path-subs)))

(defn localise-path [path]
  "Apply the g:conjure#relative_file_root and g:conjure#path_subs configuration
  to the given path."
  (-> path
      (apply-path-subs (config.get-in [:path_subs]))
      (resolve-relative)))

(defn file-path->module-name [file-path]
  "Tries to match a file path up to an existing loaded Lua module."
  (when file-path
    (a.some
      (fn [mod-name]
        (let [mod-path (string.gsub mod-name "%." afs.path-sep)]
          (when (or
                  (text.ends-with file-path (.. mod-path ".fnl"))
                  (text.ends-with file-path (.. mod-path "/init.fnl")))
            mod-name)))
      (a.keys package.loaded))))
