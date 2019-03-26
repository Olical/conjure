# Contributing to Conjure

 1. Check out `CODE_OF_CONDUCT.md`, I will not tolerate behavior that violates the document. Let's all be wonderful humans to each other.
 2. Have a look around the issues to see if something similar to your feature or change has been discussed before.
 3. Speak to someone about it, raise an issue and start a discussion. Of course if you're just fixing a typo then go ahead, but if it's not an entirely trivial change let's work out what to do together. Perhaps someone has already solved your problem and just needs a poke to share their work or findings.
 4. Develop your change on a branch keeping in line with how the project is currently structured, try to keep your change minimal and focussed.

When working on Conjure you can start the development version through `make dev`. You'll ideally need [localvimrc][] to evaluate the `.lvimrc` file for you on startup. When working on Conjure you'll have the following extras by default:

 * Your global version of Conjure will be disabled.
 * Logs are sent to `logs/conjure.log` (I `tail -f` this file in another terminal while working)
 * A prepl into Conjure itself is opened on port `5885`. `,rc` will connect Conjure to itself so you can develop in a strangely magical cycle.
 * The AOT compiled classes are ignored so startup time is quite a bit longer but you get the full development version to REPL into.

You can start a few prepls to test against with `make prepls`:

 * `jvm` on `5555`
 * `node` on `5556`
 * `browser` on `5557`

These are useful for testing Clojure and ClojureScript discrepancies, of which there are many.

Above all, have fun with it. Help build and improve something you love to use.

[localvimrc]: https://github.com/embear/vim-localvimrc
