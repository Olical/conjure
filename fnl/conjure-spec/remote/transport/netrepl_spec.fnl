(local {: describe : it : before-each } (require :plenary.busted))
(local assert (require :luassert.assert))
(local trn (require :conjure.remote.transport.netrepl))

(describe "conjure.remote.transport.netrepl"
  (fn []

    (describe "encode"
      (fn []
        (it "no partial messages"
          (fn []
            (assert.are.equals "\3\0\0\0foo" (trn.encode "foo"))
            (assert.are.equals "\6\0\0\0foobar" (trn.encode "foobar"))))))

    (describe "decoder-simple"
      (fn []
        (it "When full message, only that message arrives"
          (fn []
            (let [decode (trn.decoder)]
              (assert.same ["foo"] (decode (trn.encode "foo")))
              (assert.same ["foo bar baz"] (decode (trn.encode "foo bar baz"))))))))

    (describe "decoder-multi"
      (fn []
        (it "Full message, but multiple packed into the same chunk"
          (fn []
            (let [decode (trn.decoder)]
              (assert.same ["foo"] (decode (trn.encode "foo")))
              (assert.same ["foo" "bar" "baz"]
                           (decode (.. (trn.encode "foo")
                                       (trn.encode "bar")
                                       (trn.encode "baz")))))))))

    (describe "decoder-partial"
      (fn []
        (it "Partial messages cut across multiple chunks 1/3"
          (fn []
            (let [decode (trn.decoder)
                  msg (trn.encode "Hello, World!")
                  a (string.sub msg 1 7)
                  b (string.sub msg 8)]
              (assert.same [] (decode a))
              (assert.same ["Hello, World!"] (decode b)))))

        (it "Partial messages cut across multiple chunks 2/3"
            (fn []
              (let [decode (trn.decoder)
                    msg (trn.encode "Hello, World!")
                    a (string.sub msg 1 7)
                    b (string.sub msg 8)]
                (assert.same ["Hey!"] (decode (.. (trn.encode "Hey!") a)))
                (assert.same ["Hello, World!" "Yo!"] (decode (.. b (trn.encode "Yo!")))))))

        (it "Partial messages cut across multiple chunks 3/3"
            (fn []
              (let [decode (trn.decoder)
                    msg (trn.encode "Hello, World!")
                    a (string.sub msg 1 4)
                    b (string.sub msg 5)]
                (assert.same [] (decode a))
                (assert.same ["Hello, World!" "foo"] (decode (.. b (trn.encode "foo") a)))
                (assert.same ["Hello, World!" "bar"] (decode (.. b (trn.encode "bar")))))))))

    (describe "decoder-long"
      (fn []
        (it "Problematic message"
          (fn []
            (let [decode (trn.decoder)
                  msg "error: could not find module ./dev/janet/oter:\n    dev/janet/oter.jimage\n    dev/janet/oter.janet\n    dev/janet/oter/init.janet\n    dev/janet/oter.so\n  in require [boot.janet] on line 2272, column 20\n  in import* [boot.janet] on line 2292, column 15\n  in _thunk [repl] (tailcall) on line 4, column 37\n"]
              (assert.same [msg] (decode (trn.encode msg))))))))))
