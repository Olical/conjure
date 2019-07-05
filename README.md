# Conjure [![CircleCI](https://circleci.com/gh/Olical/conjure.svg?style=svg)](https://circleci.com/gh/Olical/conjure) [![codecov](https://codecov.io/gh/Olical/conjure/branch/master/graph/badge.svg)](https://codecov.io/gh/Olical/conjure) [![Slack](https://img.shields.io/badge/chat-%23conjure-green.svg?style=flat)](http://clojurians.net)

[Clojure][] (and [ClojureScript][]) tooling for [Neovim][] over a socket prepl connection.

You can find out more about socket prepls in my blog post, [Clojure socket prepl cookbook][prepl-post], which has also been [translated into Russian][ru-prepl-post].

> This software is still in early development, expect some breaking changes before [v1.0.0](https://github.com/Olical/conjure/milestone/1) is released. Keep up with changes by watching the repository for releases and depending on specific tags instead of master.

### Features

 * Connect to multiple Clojure or ClojureScript prepls at the same time.
 * Evaluate in `.clj`, `.cljc` and `.cljs` buffers seamlessly.
 * Custom log buffer that appears and vanishes where required.
 * [Completion](#completion) through [Compliment][] (injected for you automatically).
 * Running tests in the current namespace or the `-test` equivalent.
 * Friendly error output by default with optional expansion.
 * Go to definition.
 * Documentation lookup on a key press and when your cursor is idle.
 * Declarative prepl connections with `.conjure.edn`.

### Upcoming for v1.0.0

 * Code formatting. ([#11](https://github.com/Olical/conjure/issues/11))
 * Changed namespace reloading via `tools.namespace`. ([#10](https://github.com/Olical/conjure/issues/10))
 * Polished documentation and README. ([#6](https://github.com/Olical/conjure/issues/6))

[![asciicast](https://asciinema.org/a/9WzntRGRXsR7PNivHRgRQzdqA.svg)](https://asciinema.org/a/9WzntRGRXsR7PNivHRgRQzdqA)

## Installation

Here's an example with [vim-plug][], my plugin manager of choice.

```viml
Plug 'Olical/conjure', { 'tag': 'v0.21.0', 'do': 'bin/compile'  }
```

You should rely on a tag so that breaking changes don't end up disrupting your workflow, please don't depend on `master` (and especially not `develop`!). Make sure you watch the repository for releases using the menu in the top right, that way you can upgrade when it's convenient for you.

## Usage

### Configuration

Connections are configured through the `.conjure.edn` file in your current directory (the dot prefix is optional), which is deeply merged with all other `.conjure.edn` files in all parent directories. This allows you to store common settings for your workflow in your home directory, for example. `$XDG_CONFIG_HOME` is taken into account, by default this means you can configure Conjure globally with `~/.config/conjure/conjure.edn` if you so wish.

Once you're set up you can execute `ConjureUp` (`<localleader>cu` by default) to read, merge and validate all of your files. `ConjureUp` is also executed when Conjure starts, so you can just open any Clojure file and start hacking. The files in your local directory will overwrite those in parent directories allowing you to override things in your home directory.

Here's an exhaustive example of what you can configure with these files. If you get something wrong you'll get an explanation from [expound][].

```clojure
{:conns
 {:api {:port 5885}
  :frontend {:port 5556

             ;; You need to explicitly tell Conjure if it's a ClojureScript connection.
             :lang :cljs}

  :staging {:host "foo.com"
            :port 424242

            ;; This is EDN so you need to specify that you want a regex.
            ;; Clojure(Script)'s #"..." syntax won't work here.
            :expr #regex "\\.(cljc?|edn|another.extension)$"}

  ;; You can slurp in valid EDN which allows you to use random port files from other tools (such as boot).
  ;; If the file doesn't exist yet the connection will simply be ignored because of the nil :port value.
  :boot {:port #slurp-edn ".socket-port"

         ;; Disabled conns will be ignored on ConjureUp.
         ;; They can be enabled and disabled with `:ConjureUp -staging +boot`
         ;; This allows you to toggle parts of your config with different custom mappings.
         :enabled? false}}}
```

If you open Conjure without any connections configured it'll self prepl into it's _own_ JVM. This allows you to have autocompletion and evaluation in any directory or Clojure file. This can be really useful for quickly trying something out in a temporary file where a regular REPL won't quite cut it.

### Commands

 * `ConjureUp` - synchronise connections with your `.conjure.edn` config files, takes flags like `-foo +bar` which will set the `:enabled?` flags of matching connections.
 * `ConjureStatus` - display the current connections in the log buffer.
 * `ConjureEval` - evaluate the argument as Clojure code.
 * `ConjureEvalSelection` - evaluates the current (or previous) visual selection.
 * `ConjureEvalCurrentForm` - evaluates the form under the cursor.
 * `ConjureEvalRootForm` - evaluates the outermost form under the cursor.
 * `ConjureEvalBuffer` - evaluate the entire buffer (not from the disk).
 * `ConjureLoadFile` - load and evaluate the file from the disk.
 * `ConjureDoc` - display the documentation for the given symbol in the log buffer.
 * `ConjureDefinition` - go to the source of the given symbol, providing we can find it - falls back to vanilla `gd`.
 * `ConjureOpenLog` - open and focus the log buffer in a wide window.
 * `ConjureCloseLog` - close the log window if it's open in this tab.
 * `ConjureToggleLog` - open or close the log depending on it's current state.
 * `ConjureRunTests` - run tests in the current namespace and it's `-test` equivalent (as well as the other way around) or with the provided namespace names separated by spaces.
 * `ConjureRunAllTests` - run all tests with an optional namespace filter regex.

### Mappings

 * `InsertEnter` in a Clojure buffer (that is _not_ the log) closes the log.
 * `CursorMoved(I)` in a Clojure buffer looks up the docs for the head of the form under your cursor and displays it with virtual text.
 * `<localleader>ee` - `ConjureEvalCurrentForm`
 * `<localleader>er` - `ConjureEvalRootForm`
 * `<localleader>ee` - `ConjureEvalSelection` (visual mode)
 * `<localleader>ew` - `ConjureEval <word under cursor>`
 * `<localleader>eb` - `ConjureEvalBuffer`
 * `<localleader>ef` - `ConjureLoadFile`
 * `<localleader>cu` - `ConjureUp`
 * `<localleader>cs` - `ConjureStatus`
 * `<localleader>cl` - `ConjureOpenLog`
 * `<localleader>cq` - `ConjureCloseLog`
 * `<localleader>cL` - `ConjureToggleLog`
 * `<localleader>tt` - `ConjureRunTests`
 * `<localleader>ta` - `ConjureRunAllTests`
 * `K` - `ConjureDoc`
 * `gd` - `ConjureDefinition`

### Options

You may set these globals with `let` before Conjure loads to configure it's behaviour slightly. Their default values are displayed after the `=`, with a `1` indicating true and `0` indicating false.

 * `g:conjure_default_mappings = 1` - Enable default key mappings.
 * `g:conjure_log_direction = "vertical"` - How to split the log window. Either `"vertical"` or `"horizontal"`.
 * `g:conjure_log_size_small = 25` (%) - Regular size of the log window when it opens automatically.
 * `g:conjure_log_size_large = 50` (%) - Size of the log window when explicitly opened by  `ConjureOpenLog`.
 * `g:conjure_log_auto_close = 1` - Enable closing the log window as you enter insert mode in a Clojure buffer.
 * `g:conjure_log_auto_open = ["eval", "ret", "ret-multiline", "out", "err", "tap", "doc", "load-file", "test"]` - Open the log window for different kinds of log entries, remove unwanted kinds.
   * `eval` - Code you just evaluated and which connection it went to.
   * `ret` - Returned value from an evaluation (single line).
   * `ret-multiline` - Returned value from an evaluation (multiple lines).
   * `out` - `stdout` from an evaluation.
   * `err` - `stderr` from an evaluation.
   * `tap` - Results from `(tap> ...)` calls within an evaluation.
   * `doc` - Documentation output.
   * `load-file` - Path to the file you just loaded from disk.
   * `test` - Test results.
 * `g:conjure_fold_multiline_results = 0` - Fold multiline results in the log window.
 * `g:conjure_quick_doc_normal_mode = 1` - Enable small doc strings appearing as virtual text in normal mode.
 * `g:conjure_quick_doc_insert_mode = 1` - Enable small doc strings appearing as virtual text in insert mode as you type.
 * `g:conjure_quick_doc_time = 250` (ms) - How long your cursor has to hold before the quick doc will be queried, if enabled.
 * `g:conjure_omnifunc = 1` - Enable Conjure's built in omnifunc.

## Completion

Completion is provided through the wonderful [Compliment][] and is injected for you without conflicting with existing versions. `<c-x><c-o>` omnicompletion should work as soon as you're connected.

### Autocomplete

Async autocompletion is provided by various plugins in Neovim, here's how you integrate Conjure with some of the most popular tools. If you wish to help grow this list you can check out `rplugin/python3/deoplete/sources/conjure.py` for an example of how to connect to, and use, the Conjure JSON RPC port.

#### [Deoplete][]

Deoplete is supported by default since the source is contained within this repository. All you need to do is install Conjure and Deoplete then connect to a prepl. Completion should work right away.

I also recommend configuring Deoplete using settings that I first found in the [async-clj-omni][] repository.

```vim
let g:deoplete#keyword_patterns = {}
let g:deoplete#keyword_patterns.clojure = '[\w!$%&*+/:<=>?@\^_~\-\.#]*'
```

#### [Coc][]

You can install [coc-conjure][] to hook these two tools together easily, all thanks to [@jlesquembre][]. Documentation for that process can be found inside the repository.

## Unlicenced

Find the full [unlicense][] in the `UNLICENSE` file, but here's a snippet.

>This is free and unencumbered software released into the public domain.
>
>Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

[unlicense]: http://unlicense.org/
[clojure]: https://clojure.org/
[clojurescript]: https://clojurescript.org/
[neovim]: https://neovim.io/
[ru-prepl-post]: http://softdroid.net/povarennaya-kniga-clojure-socket-prepl
[prepl-post]: https://oli.me.uk/2019-03-22-clojure-socket-prepl-cookbook/
[compliment]: https://github.com/alexander-yakushev/compliment
[vim-plug]: https://github.com/junegunn/vim-plug
[expound]: https://github.com/bhb/expound
[edn]: https://github.com/edn-format/edn
[twitter]: https://twitter.com/OliverCaldwell
[coc-conjure]: https://github.com/jlesquembre/coc-conjure
[coc]: https://github.com/neoclide/coc.nvim
[@jlesquembre]: https://github.com/jlesquembre
[deoplete]: https://github.com/Shougo/deoplete.nvim
[async-clj-omni]: https://github.com/clojure-vim/async-clj-omni
[clojurians]: http://clojurians.net/
