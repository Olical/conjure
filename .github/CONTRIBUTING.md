# Contributing to Conjure

> Note: All development should take place on the develop branch and all pull requests should target it. Merges to master are performed at release time.

 1. Check out [`.github/CODE_OF_CONDUCT.md`][code-of-conduct], I will not tolerate behavior that violates that document in any way. Let's all be wonderful humans to each other.
 2. Have a look around the issues to see if something similar to your feature or change has been discussed before.
 3. Speak to someone about it, raise an issue and start a discussion. Of course if you're just fixing a typo then go ahead, but if it's not an entirely trivial change let's work out what to do together. Perhaps someone has already solved your problem and just needs a poke to share their work or findings.
 4. Develop your change on a branch keeping in line with how the project is currently structured, try to keep your change minimal and focussed.

After also cloning [conjure-deps][] into the same parent directory as Conjure you can start the development version with `make dev`. This method enables the following extras by default:

 * Your global version of Conjure will be overridden by the one in your current directory.
 * Logs are sent to `logs/conjure.log`. (I `tail -f` this file in another terminal while working)
 * A prepl is connected to Conjure itself so you can develop in a strangely magical cycle.
 * The AOT compiled classes are ignored so startup time is quite a bit longer but you get the full development version to REPL into.

## Checking your work

The test suite is run through [CircleCI][] automatically on every change and coverage reports are uploaded to [Codecov][], you can execute it all yourself with `make test`. Check out the [Kaocha documentation][kaocha] for more information.

Try to grow the coverage instead of shrinking it where possible but I'm never going to be super strict about this. Add tests where you feel like they help, don't bother where the value is negligible.

For ad-hoc interactive testing you can start a few test prepls with `make prepls`:

 * `jvm` on `5555`
 * `node` on `5556`
 * `browser` on `5557`

These are useful for testing Clojure and ClojureScript discrepancies, of which there are many.

Above all, have fun with it. Help build and improve something you love to use.

[circleci]: https://circleci.com/
[codecov]: https://codecov.io/
[kaocha]: https://github.com/lambdaisland/kaocha
[code-of-conduct]: ./CODE_OF_CONDUCT.md
[conjure-deps]: https://github.com/Olical/conjure-deps
