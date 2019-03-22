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
" Evaluate the form under the cursor.
nnoremap <localleader>rr :ConjureEvalCurrentForm<cr>

" Evaluate the outermost form.
nnoremap <localleader>re :ConjureEvalRootForm<cr>

" Evaluate whatever is currently visually selected.
vnoremap <localleader>re :ConjureEvalSelection<cr>

" Evaluate the entire buffer.
" Taken from the buffer, not the file on disk.
nnoremap <localleader>rf :ConjureEvalBuffer<cr>

" Evaluate the file from the disk.
nnoremap <localleader>rd :ConjureLoadFile <c-r>%<cr>

" Log the current connections and their configuration.
nnoremap <localleader>rs :ConjureStatus<cr>

" Expand and focus the log.
nnoremap <localleader>rl :ConjureOpenLog<cr>

" Close the log if it's open.
nnoremap <localleader>rq :ConjureCloseLog<cr>

" Look up documentation for the word under the cursor.
nnoremap K :ConjureDoc <c-r><c-w><cr>

" Closes the log if we're not currently inside it.
function! s:close_log()
  if expand("%:p") !~# "/tmp/conjure-log-\\d\\+.cljc"
    ConjureCloseLog
  endif
endfunction

augroup conjure
  " Close the log when entering insert mode.
  autocmd! InsertEnter *.clj\(c\|s\) :call <sid>close_log()
augroup END
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
[compliment]: https://github.com/alexander-yakushev/compliment
[zprint]: https://github.com/kkinnear/zprint
[vim-plug]: https://github.com/junegunn/vim-plug
