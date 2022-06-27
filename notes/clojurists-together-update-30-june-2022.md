Since my last update on [Conjure](https://github.com/Olical/conjure) I've managed to get a few more key fixes and features in as well as learned enough to realise I need to take on yet another open source project (you'll be interested in this even if you don't use Neovim!). I've completed the main feature I wanted to finish as part of this funding round (debugging) and started a longer journey to supersede it eventually (even better editor agnostic debugging).

Here's a quick overview of [the changes since the my last project update](https://github.com/Olical/conjure/compare/v4.34.0...v4.36.0):

 * Added CIDER debugger support! You can now initialise the CIDER debugger then step through break points, inspecting and modifying values as you go. See the wiki page on the [Clojure nREPL CIDER debugger](https://github.com/Olical/conjure/wiki/Clojure-nREPL-CIDER-debugger) for more information.
 * Guarded against various subtle type errors such as `nil` REPL ports and attempts to concatenate strings with `nil` values.
 * Refactored the non-tree-sitter based evaluation code into a lazy loaded module that isn't executed at all if you rely on tree-sitter for your Conjure evaluations.
 * Improved `:ConjureSchool` so it only appends the next lesson once, so you can perform a lesson many times without it filling the school file with repeated instructions.
 * Support evaluating Clojure sets, inline functions, reader conditionals and some quoted forms as long as you're using tree-sitter. No more evaluating `#{:foo :bar}` as `{:foo :bar}`! It now correctly includes the `#` prefix!
 * Fixed nREPL session operations, such as creating, cycling and listing, when you have a long running process blocking the current session's thread. So now you can start a long running process and then cycle to a new session to keep evaluating things in another, unblocked, thread. This was a subtle bug introduced quite a long time ago by another fix. My apologies!

The debugger support is the star of the show, I hope you enjoy this new support and help me improve it into the future with issue reports and pull requests. It's fairly minimal but that's where the new open source project I mentioned comes into play.

Introducing the [Clojure CIDER DAP server](https://github.com/Olical/clojure-cider-dap-server) (which is an empty repository at the time of writing)! This project fell out of all of my Clojure debugging research, it will bridge the gap between DAP compatible tools (such as [nvim-dap](https://github.com/mfussenegger/nvim-dap)) in any editor and the CIDER debugger tooling.

This new, editor agnostic, standalone, CLI tool will allow you to plug your editor's debugger support into a running nREPL server. You will be able to perform interactive debugging with powerful tools, in or outside of Neovim, in a shared nREPL connection with Conjure.

The goal will be to make this the primary way of debugging your Clojure applications with Conjure's built in support being a simpler fallback for when you don't have a choice or when you don't need a rich GUI.

So, I hope you've enjoyed the features, fixes, improvements and optimisations I've brought to Conjure over my Clojurists Together funding period. And I really hope you enjoy my upcoming further work in the debugger tooling space, regardless of your editor or REPL tooling choices.

I'd love to hear your thoughts, opinions, feelings and feedback on Twitter [@OliverCaldwell](https://twitter.com/OliverCaldwell). Bye for now!
