# Conjure

> This software is still in early development, expect some breaking changes before [v1.0.0](https://github.com/Olical/conjure/milestone/1) is released. Keep up with changes by watching the repository for releases and depending on specific tags instead of master.

[Clojure][] (and [ClojureScript][]) tooling for [Neovim][] over a [socket prepl][prepl-post] connection.

### Features

 * Connect to multiple Clojure or ClojureScript prepls at the same time.
 * Evaluate in `.clj`, `.cljc` and `.cljs` buffers seamlessly.
 * Custom log buffer that appears and vanishes where required.
 * `(doc ...)` lookup.
 * [Omnicomplete](#omnicomplete) through [Compliment][].
 * Go to definition (will work more consistently when [#18](https://github.com/Olical/conjure/issues/18) is done).
 * Running tests in the current namespace.

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
Plug 'Olical/conjure', { 'tag': 'v0.9.1', 'do': 'make compile', 'for': 'clojure', 'on': 'ConjureAdd'  }
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

## Omnicomplete

Completion is provided through the wonderful [Compliment][], simply ensure it's depended on inside your project for `<c-x><c-o>` omnicompletion to work. If you already depend on CIDER, chances are it's already inside your project since it pulls it in already for you. If you're working with a pure prepl project you'll probably need to add it to your `deps.edn`.

If you don't have complement Conjure will still work fine, omnicompletion will just return no results.

### Autocomplete

If you'd like completion automatically popping up as you type you can use [coc-conjure][] to integrate Conjure with [coc.nvim][], all thanks to [@jlesquembre][]!

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
[prepl-post]: https://oli.me.uk/2019-03-22-clojure-socket-prepl-cookbook/
[compliment]: https://github.com/alexander-yakushev/compliment
[vim-plug]: https://github.com/junegunn/vim-plug
[expound]: https://github.com/bhb/expound
[edn]: https://github.com/edn-format/edn
[twitter]: https://twitter.com/OliverCaldwell
[coc-conjure]: https://github.com/jlesquembre/coc-conjure
[coc.nvim]: https://github.com/neoclide/coc.nvim
[@jlesquembre]: https://github.com/jlesquembre
