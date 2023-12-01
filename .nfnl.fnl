(local core (require :nfnl.core))
(local config (require :nfnl.config))

{:compiler-options (core.merge
                     (config.default)
                     {:compilerEnv _G})
 :source-file-patterns [".nvim.fnl" "fnl/**/*.fnl"]}
