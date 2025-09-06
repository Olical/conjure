(local core (require :conjure.nfnl.core))
(local config (require :conjure.nfnl.config))
(local defaults (config.default))

{:compiler-options (core.merge
                     defaults.compiler-options
                     {:compilerEnv _G})
 :source-file-patterns [".nvim.fnl" "plugin/*.fnl" "fnl/**/*.fnl"]
 :orphan-detection {:ignore-patterns ["lua/conjure/nfnl/"]}}
