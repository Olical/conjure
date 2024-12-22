(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))
(local config (autoload :conjure.config))
(local nfs (autoload :nfnl.fs))

(local path-sep (nfs.path-sep))

(fn env [k]
  (let [v (vim.fn.getenv k)]
    (when (and (a.string? v) (not (a.empty? v)))
      v)))

(fn config-dir []
  "Return $XDG_CONFIG_HOME/conjure.
  Defaulting the config directory to $HOME/.config."
  (vim.fs.normalize (if (env "XDG_CONFIG_HOME")
                        "$XDG_CONFIG_HOME/conjure" 
                        "~/.config/conjure")))

(fn absolute-path [path]
  (vim.fs.normalize (vim.fn.fnamemodify path ":p")))

(fn findfile [name path]
  "Wrapper around Neovim's findfile() that returns nil
  instead of an empty string."
  (let [res (vim.fn.findfile name path)]
    (when (not (a.empty? res))
      (absolute-path res))))

(fn split-path [path]
  (vim.split path path-sep {:trimempty true}))

(fn join-path [parts]
  (str.join path-sep (a.concat parts)))

(fn parent-dir [path]
  (let [res (-> path
                (split-path)
                (a.butlast)
                (join-path))]
    (if (= "" res)
      nil
      (.. path-sep res))))

(fn upwards-file-search [file-names from-dir]
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

(fn resolve-above [names]
  "Resolve a pathless list of file names to an absolute path by looking in the
  containing and parent directories of the current file, current working
  directory and finally $XDG_CONFIG_HOME/conjure.

  The file names are considered in priority order, if a match is found for the
  first file name in the first directory, everything will short circuit and
  return that full path."
  (or
    (upwards-file-search names (vim.fn.expand "%:p:h"))
    (upwards-file-search names (vim.fn.getcwd))
    (upwards-file-search names (config-dir))))

(fn file-readable? [path]
  (= 1 (vim.fn.filereadable path)))

(fn resolve-relative-to [path root]
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

(fn resolve-relative [path]
  "If g:conjure#relative_file_root is set, will resolve the path relative to
  that. Will return the original path immediately if not."
  (let [relative-file-root (config.get-in [:relative_file_root])]
    (if relative-file-root
      (resolve-relative-to path relative-file-root)
      path)))

(fn apply-path-subs [path path-subs]
  (a.reduce
    (fn [path [pat rep]]
      (path:gsub pat rep))
    path
    (a.kv-pairs path-subs)))

(fn localise-path [path]
  "Apply the g:conjure#relative_file_root and g:conjure#path_subs configuration
  to the given path."
  (-> path
      (apply-path-subs (config.get-in [:path_subs]))
      (resolve-relative)))

(fn current-source []
  (let [info (debug.getinfo 2 "S")]
    (when (vim.startswith (a.get info :source) "@")
      (string.sub info.source 2))))

(local conjure-source-directory
  (let [src (current-source)]
    (when src
      (vim.fs.normalize (.. src "/../../..")))))

(fn file-path->module-name [file-path]
  "Tries to match a file path up to an existing loaded Lua module."
  (when file-path
    (a.some
      (fn [mod-name]
        (let [mod-path (string.gsub mod-name "%." path-sep)]
          (when (or
                  (vim.endswith file-path (.. mod-path ".fnl"))
                  (vim.endswith file-path (.. mod-path "/init.fnl")))
            mod-name)))
      (a.keys package.loaded))))

{: env
 : config-dir
 : absolute-path
 : findfile
 : split-path
 : join-path
 : parent-dir
 : upwards-file-search
 : resolve-above
 : file-readable?
 : resolve-relative-to
 : resolve-relative
 : apply-path-subs
 : localise-path
 : current-source
 : conjure-source-directory
 : file-path->module-name}
