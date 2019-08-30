# Conjure [![Slack](https://img.shields.io/badge/chat-%23conjure-green.svg?style=flat)](http://clojurians.net) [![CircleCI](https://circleci.com/gh/Olical/conjure.svg?style=svg)](https://circleci.com/gh/Olical/conjure) [![codecov](https://codecov.io/gh/Olical/conjure/branch/master/graph/badge.svg)](https://codecov.io/gh/Olical/conjure)

[Clojure][] (and [ClojureScript][]) tooling for [Neovim][] over a socket prepl connection.

## Overview

 * Connect to multiple Clojure or ClojureScript prepls at once.
 * Declarative connection configuration through `.conjure.edn`.
 * No dependencies required in your project.
 * Log buffer, like a REPL you can edit.
 * Liberal use of virtual text to display help and results.
 * Completion through [Complement][] (ClojureScript support _soon_).
 * Documentation lookup as you type (or with `K`).
 * Refreshing of changed namespaces (Clojure only).
 * Go to definition (limited ClojureScript support).
 * Running tests.

## Install

Use your favourite plugin manager (I use [vim-plug][]) to fetch and AOT compile Conjure.

I highly recommend you pin it to a tag and then subscribe to releases through the GitHub repository. This will allow you to keep up to date without having your workflow interrupted by an unexpected breaking change, not that I intend to ever release many of those.

```viml
Plug 'Olical/conjure', { 'tag': 'v1.0.0', 'do': 'bin/compile'  }
```

## Hello, World!

Here's a minimal example of using Conjure after successfully installing it. In an empty directory we'll create this simple `.conjure.edn`.

```edn
{:conns {:dev {:port 5678}}}
```

Conjure is now configured to connect to a local prepl on port `5678`, let's start that with this command in another terminal.

```sh
clojure -J-Dclojure.server.jvm="{:port 5678 :accept clojure.core.server/io-prepl}"
```

And now all we need to do is open a Clojure file, here's a clip of what you should see with autocompletion and evaluation. It takes a few seconds upon first connection because the required dependencies for a few fancier features are being injected.

[![asciicast](https://asciinema.org/a/mIH4x3ma71Mha4L7oPhrTiSEA.svg?t=12)](https://asciinema.org/a/mIH4x3ma71Mha4L7oPhrTiSEA)

> Neovim lost all theming in the asciinema video for some reason, it usually looks a lot better.

## Unlicenced

Find the full [unlicense][] in the `UNLICENSE` file, but here's a snippet.

>This is free and unencumbered software released into the public domain.
>
>Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

[unlicense]: http://unlicense.org/
[clojure]: https://clojure.org/
[clojurescript]: https://clojurescript.org/
[neovim]: https://neovim.io/
[complement]: https://github.com/alexander-yakushev/compliment
[vim-plug]: https://github.com/junegunn/vim-plug
