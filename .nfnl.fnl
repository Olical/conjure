(local core (require :nfnl.core))
(local config (require :nfnl.config))
(local defaults (config.default))

{:compiler-options (core.merge
                     defaults.compiler-options
                     {:compilerEnv _G})

 ;; TODO Recompile with the deps / bencode cloned, this should put it on the include path?
 ;; Or write my own script to embed it with cp.
 ; :fennel-path (.. defaults.fennel-path ";deps/?.fnl")
 :source-file-patterns [".nvim.fnl" "fnl/**/*.fnl"]}
