(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local b64 (require :conjure.remote.transport.base64))

(describe "conjure.remote.transport.base64"
  (fn []
    (describe "basic"
      (fn []
        (it "empty to empty"
          (fn []
            (assert.are.equals "" (b64.encode ""))))
        (it "simple text to base64"
          (fn []
            (assert.are.equals "SGVsbG8sIFdvcmxkIQ==" (b64.encode "Hello, World!"))))
        (it "base64 back to text"
          (fn []
            (assert.are.equals "Hello, World!" (b64.decode "SGVsbG8sIFdvcmxkIQ=="))))))))
