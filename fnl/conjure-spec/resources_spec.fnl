(local {: autoload } (require :conjure.nfnl.module))
(local {: describe : it : spy : before_each} (require :plenary.busted))
(local assert (require :luassert.assert))

(local default-open (fn [] nil))
(local default-get-runtime-file (fn [] []))

(var res nil)

(describe "conjure.resources"
  (fn []
    (before_each
      (fn []
        ; this ensures resource cache is cleared for each test
        (tset package.loaded :conjure.resources nil) 

        (set res (require :conjure.resources))
        (tset vim.api :nvim_get_runtime_file default-get-runtime-file)
        (tset io :open default-open)))

    (describe "reading resources"
      (fn [] 
        (it "returns nil when no file paths"
            (fn []
              (let [open-call-paths []
                    mock-file-open (fn [path _] (table.insert open-call-paths path))]
                (tset io :open mock-file-open)

                (assert.are.equal nil (res.get-resource-contents "some-path"))
                (assert.same [] open-call-paths))))

        (it "returns nil when file open fails"
            (fn []
              (let [expected-path "some-path"
                    open-call-paths []
                    mock-file-open (fn [path _] (table.insert open-call-paths path) nil)]
                (tset vim.api :nvim_get_runtime_file (fn [] [expected-path]))
                (tset io :open mock-file-open)

                (assert.are.equal nil (res.get-resource-contents expected-path))
                (assert.same [expected-path] open-call-paths))))

        (it "prefixes res/ path to resource request"
            (fn []
              (let [requested-path "requested-path"
                    get-runtime-file-paths []]
                (tset vim.api :nvim_get_runtime_file 
                      (fn [path] 
                        (table.insert get-runtime-file-paths path)
                        ["full-path"]))

                (assert.are.equal nil (res.get-resource-contents requested-path))
                (assert.same [(.. "res/" requested-path)] get-runtime-file-paths))))

        (it "returns file contents when file open succeeds"
            (fn []
              (let [expected-content "Here is file content"
                    mock-file-open 
                    (fn [_ _] 
                      {:read (fn [_] expected-content)
                       :close (fn [] nil)}) 
                    ]
                (tset vim.api :nvim_get_runtime_file (fn [] ["full-file-path"]))
                (tset io :open mock-file-open)

                (assert.are.equal expected-content (res.get-resource-contents "some-path")))))

        (it "closes file after file open"
            (fn []
              (let [close-calls []
                    mock-file-open 
                    (fn [_ _] 
                      {:read (fn [_] "some content")
                       :close (fn [] (table.insert close-calls true) nil)}) 
                    ]
                (tset vim.api :nvim_get_runtime_file (fn [] ["full-file-path"]))
                (tset io :open mock-file-open)

                (res.get-resource-contents "some-path")

                (assert.same [true] close-calls))))


        (it "returns cached file contents when read twice"
            (fn []
              (let [open-call-paths []
                    mock-file-open 
                    (fn [path _] 
                      (table.insert open-call-paths path)
                      {:read (fn [_] "file content")
                       :close (fn [] nil)}) 
                    ]
                (tset vim.api :nvim_get_runtime_file (fn [] ["full-file-path"]))
                (tset io :open mock-file-open)

                (res.get-resource-contents "some-path")
                (res.get-resource-contents "some-path")

                (assert.are.equal 1 (length open-call-paths)))))))))

