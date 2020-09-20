(module conjure.remote.transport.netrepl-test
  {require {trn conjure.remote.transport.netrepl}})

;; Encoding is always 1-1, no partial messages.
(deftest encode
  (t.= "\3\0\0\0foo" (trn.encode "foo"))
  (t.= "\6\0\0\0foobar" (trn.encode "foobar")))

;; When the full message and only that message arrives.
(deftest decoder-simple
  (let [decode (trn.decoder)]
    (t.pr= ["foo"] (decode (trn.encode "foo")))
    (t.pr= ["foo bar baz"] (decode (trn.encode "foo bar baz")))))

;; Full message, but multiple packed into the same chunk.
(deftest decoder-multi
  (let [decode (trn.decoder)]
    (t.pr= ["foo"] (decode (trn.encode "foo")))
    (t.pr= ["foo" "bar" "baz"]
           (decode (.. (trn.encode "foo")
                       (trn.encode "bar")
                       (trn.encode "baz"))))))

;; Partial messages cut across multiple chunks.
(deftest decoder-partial
  (let [decode (trn.decoder)
        msg (trn.encode "Hello, World!")
        a (string.sub msg 1 7)
        b (string.sub msg 8)]
    (t.pr= [] (decode a))
    (t.pr= ["Hello, World!"] (decode b)))

  (let [decode (trn.decoder)
        msg (trn.encode "Hello, World!")
        a (string.sub msg 1 7)
        b (string.sub msg 8)]
    (t.pr= ["Hey!"] (decode (.. (trn.encode "Hey!") a)))
    (t.pr= ["Hello, World!" "Yo!"] (decode (.. b (trn.encode "Yo!")))))

  (let [decode (trn.decoder)
        msg (trn.encode "Hello, World!")
        a (string.sub msg 1 4)
        b (string.sub msg 5)]
    (t.pr= [] (decode a))
    (t.pr= ["Hello, World!" "foo"] (decode (.. b (trn.encode "foo") a)))
    (t.pr= ["Hello, World!" "bar"] (decode (.. b (trn.encode "bar"))))))

;; Problematic message I found during development.
(deftest decoder-long
  (let [decode (trn.decoder)
        msg "error: could not find module ./dev/janet/oter:\n    dev/janet/oter.jimage\n    dev/janet/oter.janet\n    dev/janet/oter/init.janet\n    dev/janet/oter.so\n  in require [boot.janet] on line 2272, column 20\n  in import* [boot.janet] on line 2292, column 15\n  in _thunk [repl] (tailcall) on line 4, column 37\n"]
    (t.pr= [msg] (decode (trn.encode msg)))))


