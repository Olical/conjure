# Conjure [![Slack](https://img.shields.io/badge/chat-%23conjure-green.svg?style=flat)](http://clojurians.net) [![CircleCI](https://circleci.com/gh/Olical/conjure.svg?style=svg)](https://circleci.com/gh/Olical/conjure) [![codecov](https://codecov.io/gh/Olical/conjure/branch/master/graph/badge.svg)](https://codecov.io/gh/Olical/conjure)

[Clojure][] (and [ClojureScript][]) tooling for [Neovim][] over a socket prepl connection.

## Overview

 * Declarative connection configuration through `.conjure.edn`.
 * Connect to multiple Clojure or ClojureScript prepls at once.
 * Output buffer, like a REPL you can edit!
 * Liberal use of virtual text to display help and results.
 * Omnicompletion (`<C-x><C-o>`) through [Complement][] (ClojureScript support _soon_).
 * Documentation displayed as you type (or with `K`).
 * Refreshing of changed namespaces (Clojure only).
 * Go to definition (limited ClojureScript support).
 * Test running.

## Install

Use your favourite plugin manager, I recommend [vim-plug][], to fetch and AOT compile Conjure.

I strongly suggest you pin it to a tag and then subscribe to releases through the GitHub repository. This will allow you to keep up to date without having your workflow disrupted by an unexpected breaking change, not that I _intend_ to release any.

```viml
Plug 'Olical/conjure', { 'tag': 'v1.0.0', 'do': 'bin/compile'  }
```

No dependencies are required in your project, tools for features such as autocomplete will be injected upon connection. The initial connection to a prepl will take a few seconds because of this, I think it's worth it.

## Hello, World!

Here's a minimal example of using Conjure after successfully installing it. In an empty directory we'll create this simple `.conjure.edn`.

```edn
{:conns {:dev {:port 5678}}}
```

Conjure is now configured to connect to a local prepl on port `5678`, let's start the prepl with this command in another terminal.

```sh
clojure -J-Dclojure.server.jvm="{:port 5678 :accept clojure.core.server/io-prepl}"
```

> You can read more about starting prepls in my [Clojure socket prepl cookbook][cookbook] post. Also check out [Propel][], my tool that helps you start prepls in various ways.

And now all we need to do is open a Clojure file, write some code and evaluate it. Here's a clip of what you should see with autocompletion, documentation lookup and evaluation.

[![asciicast](https://asciinema.org/a/mIH4x3ma71Mha4L7oPhrTiSEA.svg?t=13)](https://asciinema.org/a/mIH4x3ma71Mha4L7oPhrTiSEA)

> Neovim lost all theming in the asciinema video for some reason, it usually looks a lot prettier.

## Autocompletion

[Deoplete][], once installed, will work out of the box to provide fully asynchronous completion as you type. You will probably want to configure it to pop up more often using a snippet I found in the [async-clj-omni][] repository.

```viml
call deoplete#custom#option('keyword_patterns', {'clojure': '[\w!$%&+/:<=>?@^_~-.#]'})
```

If you prefer to use [CoC][] you can add [coc-conjure][] to get the same asynchronous completion experience.

The Python to hook up Deoplete and the JavaScript to connect CoC should be good enough of an example for how you can write your own plugin for another completion framework. There's a JSON RPC server inside Conjure you can connect to that allows you to execute anything within Conjure, including fetching completions or evaluating code.

## Configuration

Conjure is configured through a mixture of Vim Script variables and the `.conjure.edn` file (the dot prefix is optional). The `.conjure.edn` file in your local directory will be deeply merged with every other one found in parent directories.

This means you can store global things in `~/.conjure.edn` or `~/.config/conjure/.conjure.edn` and override specific values with your project local configuration file. `~/.config` should be the default value of your `XDG_CONFIG_HOME` environment variable which Conjure respects.

Once configured you'll simply need to open up a Clojure or ClojureScript file and the connections will be made automatically. To synchronise the configuration and connections when Neovim is already open simply execute `ConjureUp` (`<localleader>cu` by default) after making your changes.

If you get anything wrong in your `.conjure.edn` you'll see a spec validation error formatted by [expound][] which should help you work it out.

### `.conjure.edn`

This is an exhaustive `.conjure.edn`, mine usually end up being between 1-5 lines long. Hopefully you'll be able to find anything you might need in here though!

```edn
{:conns
 {;; Minimal example.
  :api {:port 5885}

  ;; ClojureScript.
  :frontend {:port 5556

             ;; You need to explicitly tell Conjure if it's a ClojureScript connection.
             :lang :cljs}

  :staging {:host "foo.com"
            :port 424242

            ;; This is EDN so you need to specify that you want a regex.
            ;; Clojure(Script)'s #"..." syntax won't work here.
            :expr #regex "\\.(cljc?|edn|another.extension)$"}

  ;; You can slurp in valid EDN which allows you to use random port files from other tools (such as Propel!).
  ;; If the file doesn't exist yet the connection will simply be ignored because of the nil :port value.

  ;; For example, this will start a JVM prepl and write the random port to .prepl-port.
  ;; clj -Sdeps '{:deps {olical/propel {:mvn/version "1.0.0"}}}' -m propel.main -w
  :propel {:port #slurp-edn ".prepl-port"

           ;; Disabled conns will be ignored on ConjureUp.
           ;; They can be enabled and disabled with `:ConjureUp -staging +boot`
           ;; This allows you to toggle parts of your config with different custom mappings.
           :enabled? false}}

 ;; Optional configuration for tools.namespace refreshing.
 ;; Set what you need and ignore the rest.
 :refresh
 {;; Function to run before refreshing.
  :before my.ns/stop

  ;; Function to run after refreshing successfully.
  :after my.ns/start

  ;; Directories to search for changed namespaces in.
  ;; Defaults to all directories on the Java classpath.
  :dirs #{"src"}}}
```

### Options

You may set these globals with `let` _before_ Conjure is loaded to configure it's behaviour.

| Variable | Default value | Description |
| --- | --- | --- |
| `g:conjure_default_mappings` | `v:true` | Enable default key mappings. |
| `g:conjure_map_prefix` | `"<localleader>"` | Prefix to most of the default mappings. |
| `g:conjure_log_direction` | `"vertical"` | How to split the log window. Either `"vertical"` or `"horizontal"`. |
| `g:conjure_log_size_small` | `25` (%) | Regular size of the log window when it opens automatically. |
| `g:conjure_log_size_large` | `50` (%) | Size of the log window when explicitly opened by  `ConjureOpenLog`. |
| `g:conjure_log_auto_close` | `v:true` | Enable closing the log window as you enter insert mode in a Clojure buffer. |
| `g:conjure_log_blacklist` | `[]` | Don't open the log window for specific kinds of messages. To suppress `conjure/up` you'd use `["up"]`. |
| `g:conjure_fold_multiline_results` | `v:false` | Fold multiline results in the log window. |
| `g:conjure_quick_doc_normal_mode` | `v:true` | Enable small doc strings appearing as virtual text in normal mode. |
| `g:conjure_quick_doc_insert_mode` | `v:true` | Enable small doc strings appearing as virtual text in insert mode as you type. |
| `g:conjure_quick_doc_time` | `250` (ms) | How long your cursor has to hold before the quick doc will be queried, if enabled. |
| `g:conjure_omnifunc` | `v:true` | Enable Conjure's built in omnifunc. |

Here's all of the possible values that you could add to `g:conjure_log_blacklist`.

 * `up` - Output from `ConjureUp` and other connection related information.
 * `status` - Output from `ConjureStatus`.
 * `eval` - Code you just evaluated, not the result, and which connection it went to.
 * `ret` - Returned value from an evaluation (when it's a single line).
 * `ret-multiline` - Returned value from an evaluation (when it's multiple lines).
 * `out` - From `stdout`.
 * `err` - From `stderr`.
 * `tap` - Results from `(tap> ...)` calls within an evaluation, great for debugging.
 * `doc` - Documentation output.
 * `load-file` - Path to the file you just loaded from disk and which connection it went to.
 * `test` - Test results.
 * `refresh` - Namespace refreshing, you'll also get some `out` and a `ret`.

Here's my current configuration as a real world example. My log buffer opens across the bottom of my screen and will only open for things that I can't see through the virtual text display.

```viml
let g:conjure_log_direction = "horizontal"
let g:conjure_log_blacklist = ["up", "ret", "ret-multiline", "load-file", "eval"]
```

### Mappings

| Command | Mapping | Configuration | Description |
| --- | --- | --- | --- |
| `ConjureUp` | `<localleader>cu` | `g:conjure_nmap_up` | Synchronise connections with your `.conjure.edn` config files, takes flags like `-foo +bar` which will set the `:enabled?` flags of matching connections. |
| `ConjureStatus` | `<localleader>cs` | `g:conjure_nmap_status` | Display the current connections in the log buffer. |
| `ConjureEval` | `<localleader>ew` (word under cursor) | `g:conjure_nmap_eval_word` | Evaluate the argument in the appropriate prepl. |
| `ConjureEvalSelection` | `<localleader>ee` (visual mode) | `g:conjure_vmap_eval_selection` | Evaluates the current (or previous) visual selection. |
| `ConjureEvalCurrentForm` | `<localleader>ee` | `g:conjure_nmap_eval_current_form` | Evaluates the form under the cursor. |
| `ConjureEvalRootForm` | `<localleader>er` | `g:conjure_nmap_eval_root_form` | Evaluates the outermost form under the cursor. |
| `ConjureEvalBuffer` | `<localleader>eb` | `g:conjure_nmap_eval_buffer` | Evaluate the entire buffer (not from the disk). |
| `ConjureLoadFile` | `<localleader>ef` | `g:conjure_nmap_eval_file` | Load and evaluate the file from the disk. |
| `ConjureDoc` | `K` | `g:conjure_nmap_doc` | Display the documentation for the given symbol in the log buffer. |
| `ConjureDefinition` | `gd` | `g:conjure_nmap_definition` | Go to the source of the given symbol, providing we can find it - falls back to vanilla `gd`. |
| `ConjureOpenLog` | `<localleader>cl` | `g:conjure_nmap_open_log` | Open and focus the log buffer in a large window. |
| `ConjureCloseLog` | `<localleader>cq` | `g:conjure_nmap_close_log` | Close the log window if it's open in this tab. |
| `ConjureToggleLog` | `<localleader>cL` | `g:conjure_nmap_toggle_log` | Open or close the log depending on it's current state. |
| `ConjureRunTests` | `<localleader>tt` | `g:conjure_nmap_run_tests` | Run tests in the current namespace and it's `-test` equivalent (as well as the other way around) or with the provided namespace names separated by spaces. |
| `ConjureRunAllTests` | `<localleader>ta` | `g:conjure_nmap_run_all_tests` | Run all tests with an optional namespace filter regex. |
| `ConjureRefresh` | `<localleader>rr` `<localleader>rR` `<localleader>rc` | `g:conjure_nmap_refresh_changed` `g:conjure_nmap_refresh_all` `g:conjure_nmap_refresh_clear` | Clojure only, refresh namespaces, takes `changed`, `all` or `clear` as an argument. |

To override a mapping such as for evaluating the outermost form while respecting the prefix option you'd use the following.

```viml
let g:conjure_nmap_eval_root_form = g:conjure_map_prefix . "eE"
```

## Issues

When you encounter an issue, please reproduce it with logging enabled like so.

```bash
CONJURE_LOG_PATH=conjure.log nvim
```

Then open a new issue with as much context as possible with the logging output pasted below or in a GitHub gist.

If you're worried about sensitive material entering the logs, feel free to redact anything you can find, send it to me privately or [encrypted][keybase].

## Contributions

 * Adhere to [`.github/CODE_OF_CONDUCT.md`][code-of-conduct].
 * Search to see if what you're thinking about has been discussed before.
 * Raise an issue and talk about what you want to do.
 * Develop your change on a branch in the style of the rest of the project.

Please see [`.github/CONTRIBUTING.md`][contributing] for more details.

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
[expound]: https://github.com/bhb/expound
[contributing]: ./.github/CODE_OF_CONDUCT.md
[code-of-conduct]: ./.github/CONTRIBUTING.md
[keybase]: https://keybase.io/olical
