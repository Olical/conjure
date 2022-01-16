# Using common lisp with conjure

Connecting common lisp to conjure is an easy process if you have used swank, emacs, or quicklisp before. 

Firstly, set up common lisp and quick lisp as normal.

Open up the CL REPL in another terminal, then type the following code:

```lisp
(ql:quickload :swank)
(swank:create-server :dont-close t)
```

You should now have a swank server started, listening on port `4005`. This is the default port that conjure will use.

Now simply open up any `.lisp` file in conjure, and it will automatically connect to swank.

