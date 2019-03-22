# Conjure

[Clojure][] (and [ClojureScript][]) tooling for [Neovim][] over a [socket prepl][] connection. Written in Clojure with a sprinkling of Lua and VimL where required.

## Installation

Here's how you would install and compile using [vim-plug][].

```viml
Plug 'Olical/conjure', { 'tag': 'v0.4.0', 'do': 'make compile' }
```

You should rely on a tag so that breaking changes don't end up disrupting your workflow. Make sure you watch the repository for releases using the menu in the top right, that way you can decide when you want to upgrade.

The compile step (`make compile`) is technically optional but I highly doubt you want to be waiting 10+ seconds for Conjure to start in the background before you can use any of the commands.

## Configuration

Conjure doesn't come with any key bindings by default, it leaves that up to you. This template will act as a good starting point for your configuration, feel free to change it as you see fit.

```viml
" Evaluate various things.
nnoremap <localleader>re :ConjureEvalCurrentForm<cr>
nnoremap <localleader>rE :ConjureEvalRootForm<cr>
vnoremap <localleader>re :ConjureEvalSelection<cr>
nnoremap <localleader>rf :ConjureEvalBuffer<cr>

" Essentially just (load-file "...")
nnoremap <localleader>rF :ConjureLoadFile <c-r>%<cr>

" Log out the current connections and their configuration.
nnoremap <localleader>rs :ConjureStatus<cr>

" Expand and focus the log or close it.
nnoremap <localleader>rl :ConjureOpenLog<cr>
nnoremap <localleader>rL :ConjureCloseLog<cr>

" Look up documentation for the word under the cursor.
nnoremap K :ConjureDoc <c-r><c-w><cr>
```

## Usage

...

## Issues

...

## Contributing

...

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
