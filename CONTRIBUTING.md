# Contributing to Conjure

Conjure is a [Neovim](https://neovim.io) specific Lua plugin written in [Fennel](https://fennel-lang.org/) and compiled to Lua by [nfnl](https://github.com/Olical/nfnl). You will need the nfnl plugin installed to work on Conjure. Don't fear, nfnl is designed to only load and operate on projects already configured to rely on it. So if there's no configuration file it's completely inert, it will only activate when you work on Conjure or other projects built with nfnl.

It's developed using itself which leads to an extremely tight feedback loop. This makes it easier to move fast without breaking things.

Now you can open up Conjure's source files (ending in `.fnl`) and evaluate them as you would any other language with Conjure, see `:help conjure`.

Your changes and evaluations through Conjure only apply to the in memory copy of Conjure. When you write a `.fnl` file with nfnl installed however your Fennel will be compiled to a static `.lua` file automatically. Make sure you commit both your Fennel _and_ Lua file changes!

Once you're happy with your changes, you can (maybe) write some tests and execute them with `make test`. CircleCI will also run them for you.

You can run `scripts/docker.sh` to drop into a fresh Ubuntu based Neovim environment with Conjure pre-installed from your working directory. This can be used to verify your changes in a clean room environment.

## Branches

Contrary to old versions of Conjure, we now simply work on branches that target the `main` branch, I no longer use the `develop` staging branch and we can consider that obsolete just like the `master` branch.

## Still unsure?

If you'd like to contribute or are having issues please don't hesitate to get in touch with me through GitHub discussions and issues. You can also find some ways to contact me privately on my personal site, [oli.me.uk](https://oli.me.uk).
