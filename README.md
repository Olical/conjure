# Conjure

[Clojure][] (and [ClojureScript][]) tooling for [Neovim][] over a [socket prepl][prepl-post] connection.

### Features

 * Connect to multiple Clojure or ClojureScript prepls at the same time.
 * Evaluate in `.clj`, `.cljc` and `.cljs` buffers without having to reconnect.
 * Documentation lookup.
 * Custom log buffer that tries to stay out of the way but is there when you need it.

### Upcoming

 * Autocomplete via [Compliment][].
 * Go to definition.
 * Friendly error output by default with optional expansion.
 * Code formatting via [zprint][].
 * Changed namespace reloading via `tools.namespace`.

## Installation

Here's how you would install and compile using [vim-plug][], it's easy enough to translate this to your favourite plugin manager.

```viml
Plug 'Olical/conjure', { 'tag': 'v0.4.0', 'do': 'make compile', 'for': 'clojure', 'on': 'ConjureAdd'  }
```

You should rely on a tag so that breaking changes don't end up disrupting your workflow. Make sure you watch the repository for releases using the menu in the top right, that way you can decide when you want to upgrade.

The compile step (`make compile`) is technically optional but I highly doubt you want to be waiting 10+ seconds for Conjure to start in the background before you can use any of the commands.

The `'for'` and `'on'` keys are entirely optional but you might prefer Conjure to only start up once you've entered a Clojure file.

## Configuration

Conjure doesn't come with any key bindings by default, it leaves that up to you. This template will act as a good starting point for your configuration, feel free to change it as you see fit.

```viml
nnoremap <localleader>re :ConjureEvalCurrentForm<cr>
nnoremap <localleader>rr :ConjureEvalRootForm<cr>
vnoremap <localleader>re :ConjureEvalSelection<cr>
nnoremap <localleader>rf :ConjureEvalBuffer<cr>
nnoremap <localleader>rd :ConjureLoadFile <c-r>%<cr>
nnoremap <localleader>rs :ConjureStatus<cr>
nnoremap <localleader>rl :ConjureOpenLog<cr>
nnoremap <localleader>rq :ConjureCloseLog<cr>
nnoremap K :ConjureDoc <c-r><c-w><cr>

function! s:close_log()
  if expand("%:p") !~# "/tmp/conjure-log-\\d\\+.cljc"
    ConjureCloseLog
  endif
endfunction

augroup conjure
  autocmd!
  autocmd! InsertEnter *.clj\(c\|s\) :call <sid>close_log()
augroup END
```

## Usage

Conjure exposes the following commands, most are pretty self explanatory.

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
 * `ConjureOpenLog` - open and focus the log buffer in a wide window.
 * `ConjureCloseLog` - close the log window if it's open in this tab.

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

If you get something wrong it'll explain using [Expound][] in the log buffer. Essentially you must provide a `:tag` and a `:port`, other than that the rest is optional.

Here's some sample interactions.

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

If you wish to change the regular expression used to match buffers to connections, you can set the `:expr`. You have to prefix it with `#regex` because [edn][] is slightly different to regular Clojure.

```viml
:ConjureAdd {:tag :frontend, :port 8888, :expr #regex "frontend/.+\\.cljs"}
```

## Issues

If you find any issues please do let me know, provide as much as much information and context as you can.

It would help a lot if you could run Neovim with the `CONJURE_LOG_PATH` environment variable set while you reproduce the issue. Any issue will be a lot easier to diagnose and fix with the log attached.

## Contributing

Contributions are encouraged, of course! Before submitting pull requests and making serious changes to the code however, I'd love it if you could open an issue to discuss your idea or get in touch via twitter ([@OliverCaldwell][twitter]).

Giving myself and any passers by a chance to discuss ideas first will hopefully mean no rejected pull requests at all.

## Unlicenced

Find the full [unlicense][] in the `UNLICENSE` file, but here's a snippet.

>This is free and unencumbered software released into the public domain.
>
>Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

Do what you want. Learn as much as you can. Unlicense more software.

[unlicense]: http://unlicense.org/
[clojure]: https://clojure.org/
[clojurescript]: https://clojurescript.org/
[neovim]: https://neovim.io/
[prepl-post]: https://oli.me.uk/2019-03-22-clojure-socket-prepl-cookbook/
[compliment]: https://github.com/alexander-yakushev/compliment
[zprint]: https://github.com/kkinnear/zprint
[vim-plug]: https://github.com/junegunn/vim-plug
[expound]: https://github.com/bhb/expound
[edn]: https://github.com/edn-format/edn
[twitter]: https://twitter.com/OliverCaldwell
