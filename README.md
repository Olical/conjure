# Conjure [![CircleCI](https://circleci.com/gh/Olical/conjure.svg?style=svg)](https://circleci.com/gh/Olical/conjure) [![codecov](https://codecov.io/gh/Olical/conjure/branch/master/graph/badge.svg)](https://codecov.io/gh/Olical/conjure)

> This software is still in early development, expect some breaking changes before [v1.0.0](https://github.com/Olical/conjure/milestone/1) is released. Keep up with changes by watching the repository for releases and depending on specific tags instead of master.

[Clojure][] (and [ClojureScript][]) tooling for [Neovim][] over a socket prepl connection.

You can find out more about socket prepls in my blog post, [Clojure socket prepl cookbook][prepl-post], which has also been [translated into Russian][ru-prepl-post].

### Features

 * Connect to multiple Clojure or ClojureScript prepls at the same time.
 * Evaluate in `.clj`, `.cljc` and `.cljs` buffers seamlessly.
 * Custom log buffer that appears and vanishes where required.
 * [Completion](#completion) through [Compliment][] (injected for you automatically).
 * Running tests in the current namespace or the `-test` equivalent.
 * Friendly error output by default with optional expansion.
 * Go to definition.
 * Documentation lookup on a key press and when your cursor is idle.

### Upcoming for v1.0.0

 * Declarative prepl connections. ([#15](https://github.com/Olical/conjure/issues/15))
 * Code formatting. ([#11](https://github.com/Olical/conjure/issues/11))
 * Changed namespace reloading via `tools.namespace`. ([#10](https://github.com/Olical/conjure/issues/10))
 * Polished documentation and README. ([#6](https://github.com/Olical/conjure/issues/6))

[![asciicast](https://asciinema.org/a/RjojeOrKcF5zczweI7q3qiMgw.svg)](https://asciinema.org/a/RjojeOrKcF5zczweI7q3qiMgw)

## Installation

Here's an example with [vim-plug][], my plugin manager of choice.

```viml
Plug 'Olical/conjure', { 'tag': 'v0.17.1', 'do': 'bin/compile', 'for': 'clojure', 'on': 'ConjureAdd'  }
```

You should rely on a tag so that breaking changes don't end up disrupting your workflow, please don't depend on `master` (and especially not `develop`!). Make sure you watch the repository for releases using the menu in the top right, that way you can upgrade when it's convenient for you.

The `'for'` and `'on'` keys are optional but you might prefer Conjure to only start up once you've entered a Clojure file.

## Usage

### Mappings

 * `InsertEnter` in a Clojure buffer (that is _not_ the log) closes the log.
 * `CursorMoved(I)` in a Clojure buffer looks up the docs for the head of the form under your cursor and displays it with virtual text.
 * `<localleader>ee` - `ConjureEvalCurrentForm`
 * `<localleader>er` - `ConjureEvalRootForm`
 * `<localleader>ee` - `ConjureEvalSelection` (visual mode)
 * `<localleader>eb` - `ConjureEvalBuffer`
 * `<localleader>ef` - `ConjureLoadFile`
 * `<localleader>cs` - `ConjureStatus`
 * `<localleader>cl` - `ConjureOpenLog`
 * `<localleader>cq` - `ConjureCloseLog`
 * `<localleader>tt` - `ConjureRunTests`
 * `<localleader>ta` - `ConjureRunAllTests`
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

### Options

You may set these globals with `let` before Conjure loads to configure it's behaviour slightly. Their default values are displayed after the `=`, with a `1` indicating true and `0` indicating false.

 * `g:conjure_default_mappings = 1` - Enable default key mappings.
 * `g:conjure_log_direction = "vertical"` - How to split the log window. Either `"vertical"` or `"horizontal"`.
 * `g:conjure_log_size_small = 25` (%) - Regular size of the log window when it opens automatically.
 * `g:conjure_log_size_large = 50` (%) - Size of the log window when explicitly opened by  `ConjureOpenLog`.
 * `g:conjure_log_auto_close = 1` - Enable closing the log window as you enter insert mode in a Clojure buffer.
 * `g:conjure_log_auto_open = "multiline"` - Open the log window after eval, it can be set to `"multiline"`, `"always"` or `"never"`. The default will open it when the eval returns a multiple line result since it doesn't fit into the virtual text display as well.
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

## Example

> Note: Hopefully all of the stateful `ConjureAdd` / `ConjureRemove` commands will vanish with #15!

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
