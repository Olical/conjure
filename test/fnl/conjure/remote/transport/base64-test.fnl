(module conjure.remote.transport.base64-test
  {require {b64 conjure.remote.transport.base64}})

(deftest basic
  (t.= "" (b64.encode "") "empty to empty")
  (t.= "SGVsbG8sIFdvcmxkIQ==" (b64.encode "Hello, World!") "simple text to base64")
  (t.= "Hello, World!" (b64.decode "SGVsbG8sIFdvcmxkIQ==") "base64 back to text"))

