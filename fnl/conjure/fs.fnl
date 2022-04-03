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

(defn split-path [path]
  (->> (str.split path afs.path-sep)
       (a.filter #(not (a.empty? $)))))

(defn join-path [parts]
  (str.join afs.path-sep (a.concat parts)))

(defn parent-dir [path]
  (let [res (-> path
                (split-path)
                (a.butlast)
                (join-path))]
    (if (= "" res)
      nil
      (.. afs.path-sep res))))

(defn upwards-file-search [file-names from-dir]
  "Given a list of relative filenames and an absolute path to a directory,
  return the absolute path of the first file that matches a relative path,
  starting at the directory and then upwards towards the root directory. If no
  match is found, return nil."

  (when (and from-dir (not (a.empty? file-names)))
    (let [result (a.some
                   (fn [file-name]
                     (findfile file-name from-dir))
                   file-names)]
      (if result
        result
        (upwards-file-search file-names (parent-dir from-dir))))))

(defn resolve-above [names]
  "Resolve a pathless list of file names to an absolute path by looking in the
  containing and parent directories of the current file, current working
  directory and finally $XDG_CONFIG_HOME/conjure.

  The file names are considered in priority order, if a match is found for the
  first file name in the first directory, everything will short circuit and
  return that full path."
  (or
    (upwards-file-search names (nvim.fn.expand "%:p:h"))
    (upwards-file-search names (nvim.fn.getcwd))
    (upwards-file-search names (config-dir))))

(defn file-readable? [path]
  (= 1 (nvim.fn.filereadable path)))

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
