[Conjure](https://github.com/Olical/conjure) has been moving forward on many fronts over the last few months. Some of that work is related to non-Clojure language support (such as Julia and Common-Lisp), some is to do with the underlying Fennel system ([Aniseed](https://github.com/Olical/aniseed)) but the majority of the commits were improving the Clojure client is various ways.

It's also worth noting that the release I put out today for this Clojurists Together checkpoint was the 100th release! That's 100 tags, each containing many commits, since 2018 or so when I started work on my perfect Clojure interactive evaluation environment. I'm so happy with the state of Conjure today, I'm proud of what I managed to build and I'm so impressed with the community interaction and contributions. Seeing the (almost) 1000 stars on GitHub and hundreds of members in [our Discord](https://conjure.fun/discord) is wonderful.

You can read all the juicy details of every recent release on the [GitHub releases page](https://github.com/Olical/conjure/releases) but I'll highlight my favourite parts here.

 * Automatic support for nREPL 0.8+ `lookup` and `completions` operations when you don't have the CIDER middleware up and running.
 * Improvements to `:ConjureClientState` so you can swap your active REPLs around a little easier.
 * Support for `cljs.test` when executing your tests (this requires configuration to switch over).
 * Further tree-sitter fixes and support when extracting code from your buffer for evaluation.
 * Safer Shadow CLJS interactions so you can execute the Shadow select commands as many times as you want without weird errors. Essentially idempotent now.
 * Prevent weird duplicate logs on connection to an nREPL that announced the type of the REPL you were connecting to. It used to print "timeout" then "Clojure", that's fixed.
 * Handle _so many_ Neovim breaking changes in backwards compatible ways to support the ecosystem of Neovim + Conjure users as they transition to the latest stable version.
 * Default to using tree-sitter if all the conditions are met, you probably won't notice this, but things will get faster in large buffers with lots of code as autocompletions pop up and you pick code for evaluation.
 * Better checking for nREPL / shadow-cljs port files at each directory level. The logic makes more sense now, you'll just notice connecting to the "right" nREPL port file in some cases now. Thank you so much to @stelcodes for this one!
 * Created a Conjure client compatibility matrix for contributors and users to rely on https://github.com/Olical/conjure/wiki/Client-features

There's also been so much work done to Aniseed, the underlying Fennel Lisp system Conjure is built with as well as the various clients alongside the core Clojure one. I've managed to close of a bunch of bugs and clean up tickets that have been lingering for far too long.

The next batch of work under Clojurists Together will be the long awaited interactive debugger support. Hopefully everything goes well and it's possible, it's what I've wanted to do as part of this funding all along. My second and final update here in a few months should hopefully involve interactive stepping debugging of Clojure from Neovim!

Thank you so very much to each and every one of you who uses, supports, funds or contributes to Conjure and it's associated projects. I cannot express my gratitude enough here, so I will instead carry on trying to build the best conversational software development platform out there for you.
