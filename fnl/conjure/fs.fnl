(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local config (autoload :conjure.config))
(local nfs (autoload :conjure.nfnl.fs))
(local vim _G.vim)

(local M (define :conjure.fs))

(local path-sep (nfs.path-sep))

(fn M.env [k]
  (let [v (vim.fn.getenv k)]
    (when (and (core.string? v) (not (core.empty? v)))
      v)))

(fn M.config-dir []
  "Return $XDG_CONFIG_HOME/conjure.
  Defaulting the config directory to $HOME/.config."
  (vim.fs.normalize (if (M.env "XDG_CONFIG_HOME")
                        "$XDG_CONFIG_HOME/conjure"
                        "~/.config/conjure")))

(fn M.absolute-path [path]
  (vim.fs.normalize (vim.fn.fnamemodify path ":p")))

(fn M.findfile [name path]
  "Wrapper around Neovim's findfile() that returns nil
  instead of an empty string."
  (let [res (vim.fn.findfile name path)]
    (when (not (core.empty? res))
      (M.absolute-path res))))

(fn M.split-path [path]
  (vim.split path path-sep {:trimempty true}))

(fn M.join-path [parts]
  (str.join path-sep (core.concat parts)))

(fn M.parent-dir [path]
  (let [res (-> path
                (M.split-path)
                (core.butlast)
                (M.join-path))]
    (if (= "" res)
      nil
      (.. path-sep res))))

(fn M.upwards-file-search [file-names from-dir]
  "Given a list of relative filenames and an absolute path to a directory,
  return the absolute path of the first file that matches a relative path,
  starting at the directory and then upwards towards the root directory. If no
  match is found, return nil."

  (when (and from-dir (not (core.empty? file-names)))
    (let [result (core.some
                   (fn [file-name]
                     (M.findfile file-name from-dir))
                   file-names)]
      (if result
        result
        (M.upwards-file-search file-names (M.parent-dir from-dir))))))

(fn M.resolve-above [names]
  "Resolve a pathless list of file names to an absolute path by looking in the
  containing and parent directories of the current file, current working
  directory and finally $XDG_CONFIG_HOME/conjure.

  The file names are considered in priority order, if a match is found for the
  first file name in the first directory, everything will short circuit and
  return that full path."
  (or
    (M.upwards-file-search names (vim.fn.expand "%:p:h"))
    (M.upwards-file-search names (vim.fn.getcwd))
    (M.upwards-file-search names (M.config-dir))))

(fn M.file-readable? [path]
  (= 1 (vim.fn.filereadable path)))

(fn M.resolve-relative-to [path root]
  "Successively remove parts of the path until we get to a relative path that
  points to a file we can read from the root. If we run out of parts default to
  the original path."
  (fn loop [parts]
    (if (core.empty? parts)
      path
      (if (M.file-readable? (M.join-path (core.concat [root] parts)))
        (M.join-path parts)
        (loop (core.rest parts)))))

  (loop (M.split-path path)))

(fn M.resolve-relative [path]
  "If g:conjure#relative_file_root is set, will resolve the path relative to
  that. Will return the original path immediately if not."
  (let [relative-file-root (config.get-in [:relative_file_root])]
    (if relative-file-root
      (M.resolve-relative-to path relative-file-root)
      path)))

(fn M.apply-path-subs [path path-subs]
  (core.reduce
    (fn [path [pat rep]]
      (path:gsub pat rep))
    path
    (core.kv-pairs path-subs)))

(fn M.localise-path [path]
  "Apply the g:conjure#relative_file_root and g:conjure#path_subs configuration
  to the given path."
  (-> path
      (M.apply-path-subs (config.get-in [:path_subs]))
      (M.resolve-relative)))

(fn M.current-source []
  (let [info (debug.getinfo 2 "S")]
    (when (vim.startswith (core.get info :source) "@")
      (string.sub info.source 2))))

(set M.conjure-source-directory
  (let [src (M.current-source)]
    (when src
      ;; Go three levels up!
      (vim.fs.dirname (vim.fs.dirname (vim.fs.dirname src))))))

(fn M.file-path->module-name [file-path]
  "Tries to match a file path up to an existing loaded Lua module."
  (when file-path
    (core.some
      (fn [mod-name]
        (let [mod-path (string.gsub mod-name "%." path-sep)]
          (when (or
                  (vim.endswith file-path (.. mod-path ".fnl"))
                  (vim.endswith file-path (.. mod-path "/init.fnl")))
            mod-name)))
      (core.keys package.loaded))))

M
