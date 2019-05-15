# Conjure [![CircleCI](https://circleci.com/gh/Olical/conjure.svg?style=svg)](https://circleci.com/gh/Olical/conjure) [![codecov](https://codecov.io/gh/Olical/conjure/branch/master/graph/badge.svg)](https://codecov.io/gh/Olical/conjure)

> This software is still in early development, expect some breaking changes before [v1.0.0](https://github.com/Olical/conjure/milestone/1) is released. Keep up with changes by watching the repository for releases and depending on specific tags instead of master.

[Clojure][] (and [ClojureScript][]) tooling for [Neovim][] over a socket prepl connection.

You can find out more about socket prepls in my blog post, [Clojure socket prepl cookbook][prepl-post], which has also been [translated into Russian][ru-prepl-post].

### Features

 * Connect to multiple Clojure or ClojureScript prepls at the same time.
 * Evaluate in `.clj`, `.cljc` and `.cljs` buffers seamlessly.
 * Custom log buffer that appears and vanishes where required.
 * [Completion](#completion) through [Compliment][].
 * Running tests in the current namespace or the `-test` equivalent.
 * Go to definition.
 * `(doc ...)` lookup.

### Upcoming

 * Friendly error output by default with optional expansion. ([#12](https://github.com/Olical/conjure/issues/12))
 * Code formatting. ([#11](https://github.com/Olical/conjure/issues/11))
 * Changed namespace reloading via `tools.namespace`. ([#10](https://github.com/Olical/conjure/issues/10))
 * Configuration. ([#7](https://github.com/Olical/conjure/issues/7))
 * Polished documentation and README. ([#6](https://github.com/Olical/conjure/issues/6))

[![asciicast](https://asciinema.org/a/RjojeOrKcF5zczweI7q3qiMgw.svg)](https://asciinema.org/a/RjojeOrKcF5zczweI7q3qiMgw)

## Installation

Here's an example with [vim-plug][], my plugin manager of choice.

```viml
Plug 'Olical/conjure', { 'tag': 'v0.13.1', 'do': 'make compile', 'for': 'clojure', 'on': 'ConjureAdd'  }
```

You should rely on a tag so that breaking changes don't end up disrupting your workflow, please don't depend on `master`. Make sure you watch the repository for releases using the menu in the top right, that way you can decide when you want to upgrade.

The compile step (`make compile`) is technically optional but I highly doubt you want to be waiting 10+ seconds for Conjure to start in the background before you can use any of the commands. Once compiled it takes around 1.5 seconds on my machine, again, entirely in the background. I don't even notice.

The `'for'` and `'on'` keys are optional but you might prefer Conjure to only start up once you've entered a Clojure file.

## Usage

### Mappings

You can disable these and define your own with `let g:conjure_default_mappings = 0`.

 * `InsertEnter` in a Clojure buffer (that is _not_ the log) closes the log.
 * `<localleader>re` - `ConjureEvalCurrentForm`
 * `<localleader>rr` - `ConjureEvalRootForm`
 * `<localleader>re` - `ConjureEvalSelection` (visual mode)
 * `<localleader>rf` - `ConjureEvalBuffer`
 * `<localleader>rF` - `ConjureLoadFile`
 * `<localleader>rs` - `ConjureStatus`
 * `<localleader>rl` - `ConjureOpenLog`
 * `<localleader>rq` - `ConjureCloseLog`
 * `<localleader>rt` - `ConjureRunTests`
 * `<localleader>rT` - `ConjureRunAllTests`
 * `K` - `ConjureDoc`
 * `gd` - `ConjureDefinition`

### Commands

 * `ConjureAdd` - add a new connection.
 * `ConjureRemove` - remove an existing connection by tag.
 * `ConjureRemoveAll` - remove all connections.
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
 * `ConjureRunTests` - run tests in the current namespace and it's `-test` equivalent (as well as the other way around) or with the provided namespace names separated by spaces.
 * `ConjureRunAllTests` - run all tests with an optional namespace filter regex.

`ConjureAdd` takes a map that conforms to the following spec.

```clojure
(s/def ::expr util/regexp?)
(s/def ::tag keyword?)
(s/def ::port number?)
(s/def ::lang #{:clj :cljs})
(s/def ::host string?)
(s/def ::new-conn (s/keys :req-un [::tag ::port]
                          :opt-un [::expr ::lang ::host]))
```

If you get something wrong it'll explain using [Expound][] in the log buffer. Essentially you must provide at least a `:tag` and `:port`.

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

You can install [coc-conjure][] to hook these two tools together easily, all thanks to [@jlesquembre][].

## Example

```viml
" A regular Clojure connection.
:ConjureAdd {:tag :jvm, :port 5555}

" The :lang defaults to :clj, you need to specify it as :cljs for ClojureScript.
:ConjureAdd {:tag :node, :port 5556, :lang :cljs}

" This will print the result from both REPLs
" Providing you call it from within a .cljc buffer.
:ConjureEval (+ 10 10)

" Disconnect from :node.
:ConjureRemove :node
```

If you wish to change the regular expression used to match buffers to connections, you can set `:expr`. You need to prefix it with `#regex` because [edn][] doesn't have built in support for `#"..."` syntax like Clojure does.

```viml
:ConjureAdd {:tag :frontend, :port 8888, :expr #regex "frontend/.+\\.cljs", :lang :cljs}
```

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
