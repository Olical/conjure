# Conjure [![Slack](https://img.shields.io/badge/chat-%23conjure-green.svg?style=flat)](http://clojurians.net) [![CircleCI](https://circleci.com/gh/Olical/conjure.svg?style=svg)](https://circleci.com/gh/Olical/conjure) [![codecov](https://codecov.io/gh/Olical/conjure/branch/master/graph/badge.svg)](https://codecov.io/gh/Olical/conjure)

[Clojure][] (and [ClojureScript][]) tooling for [Neovim][] over a socket prepl connection.

## Overview

 * Connect to multiple Clojure or ClojureScript prepls at once.
 * Declarative connection configuration through `.conjure.edn`.
 * Log buffer, like a REPL you can edit.
 * Liberal use of virtual text to display help and results.
 * Omnicompletion (`<C-x><C-o>`) through [Complement][] (ClojureScript support _soon_).
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

No dependencies are required in your project, anything required for things like autocomplete will be injected upon first connection. The initial connection to a prepl will take a few seconds because of this.

## Hello, World!

Here's a minimal example of using Conjure after successfully installing it. In an empty directory we'll create this simple `.conjure.edn`.

```edn
{:conns {:dev {:port 5678}}}
```

Conjure is now configured to connect to a local prepl on port `5678`, let's start that with this command in another terminal.

```sh
clojure -J-Dclojure.server.jvm="{:port 5678 :accept clojure.core.server/io-prepl}"
```

> Read more about starting prepls in my [Clojure socket prepl cookbook][cookbook] post. Also check out [Propel][], my tool that helps you start prepls in various ways.

And now all we need to do is open a Clojure file, write some code and evaluate it. Here's a clip of what you should see with autocompletion, documentation lookup and evaluation.

[![asciicast](https://asciinema.org/a/mIH4x3ma71Mha4L7oPhrTiSEA.svg?t=13)](https://asciinema.org/a/mIH4x3ma71Mha4L7oPhrTiSEA)

> Neovim lost all theming in the asciinema video for some reason, it usually looks a lot better.

## Autocompletion

[Deoplete][] will work out of the box to provide fully asynchronous completion as you type. You will probably want to configure it to pop up more often using a snippet I first saw in the [async-clj-omni][] repository.

```viml
call deoplete#custom#option('keyword_patterns', {'clojure': '[\w!$%&+/:<=>?@^_~-.#]'})
```

If you prefer [CoC][] you can add [coc-conjure][] to get the same asynchronous completion experience.

The Python to hook up Deoplete and the JavaScript to connect CoC should be good enough of an example for how you can write your own plugin for another completion framework. There's a JSON RPC server inside Conjure you can connect to that allows you to execute anything within Conjure, including fetching completions or evaluating code.

## Mappings

| Command | Mapping | Description |
| --- | --- | --- |
| ConjureUp | `<localleader>cu` | Synchronise connections with your `.conjure.edn` config files, takes flags like `-foo +bar` which will set the `:enabled?` flags of matching connections. |

## Config

## Issues

## Contributing

## Rationale and history

I've always been a Vim user, historically to edit things like JavaScript and Python, and probably always will be. There's great emulations out there but they never quite cut it for me.

Once I got into Clojure and eventually got a job writing it I started to consider alternatives that would help me learn and grow as a Clojure developer. Spacemacs did a pretty good job but I still felt weird after about a year of usage, Emacs never sat well with me.

So since I couldn't leave Vim I had to use nREPL + vim-fireplace which is pretty damn great but I hit quite a few issues around CIDER + nREPL + vim-fireplace versions bumping or changing from under me. I don't think these problems are wide spread but it was enough to kick me into building my own tooling.

I was fascinated by the idea of "a REPL is all you need", no middleware, no plugins for the server, just a REPL you can send code to. The socket prepl is perfect for this since it's built into Clojure but it's undocumented, so I've been researching how it works and how to use it for over a year now. I've submitted multiple patches to Clojure and ClojureScript to fix and improve it various ways.

Conjure was always going to be a remote plugin for Neovim, I was never going to write it in Vim Script. I started out with Rust since it would have a tiny footprint while remaining expressive. I eventually gave up on that approach since I'm not an experienced Rust programmer, I then tried ClojureScript but gave up on that because I couldn't stand working with nodejs again.

The third and final approach you see here is almost entirely Clojure with a little Lua and Vim Script glue code thrown in. I have always mandated no dependencies required in your project and I'm still sticking to that. All Conjure needs to run is a socket prepl.

It works near enough exactly the same in Clojure and ClojureScript which is another core tenant of the project. There's no piggieback or sidecar dance, you just connect to either kind of connection and start editing.

So, Conjure is born from my frustrations of slightly brittle or complex tooling (maybe only in my experience!) and ClojureScript being a special case as opposed to another first class citizen. I wanted a tool that would just connect and work with very little configuration with a "Vim first" way of thinking.

I hope Conjure is a joy to use, that's what I'm trying to achieve.

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
[cookbook]: https://oli.me.uk/2019-03-22-clojure-socket-prepl-cookbook/
[propel]: https://github.com/Olical/propel
[deoplete]: https://github.com/Shougo/deoplete.nvim
[async-clj-omni]: https://github.com/clojure-vim/async-clj-omni
[coc]: https://github.com/neoclide/coc.nvim
[coc-conjure]: https://github.com/jlesquembre/coc-conjure
