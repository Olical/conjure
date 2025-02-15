(local core (require :nfnl.core))
(local config (require :nfnl.config))
(local defaults (config.default))

{:compiler-options (core.merge
                     defaults.compiler-options
                     {:compilerEnv _G})
 :source-file-patterns [".nvim.fnl" "plugin/*.fnl" "fnl/**/*.fnl"]}
