(local {: describe : it} (require :plenary.busted))
(local assert (require :luassert.assert))
(local buffer (require :conjure.buffer))

(describe "buffer"
  (fn []
    (describe "upsert-hidden"
      (fn []
        (it "never touches the swap directory, parallel spec processes race to create it"
          (fn []
            (let [original-directory vim.o.directory
                  swap-dir (.. (vim.fn.tempname) "-swap")
                  buf-name (.. (vim.fn.tempname) "-conjure-log.fnl")]
              (set vim.o.directory (.. swap-dir "//"))
              (let [buf (buffer.upsert-hidden buf-name)]
                (set vim.o.directory original-directory)
                (assert.is_false (. vim.bo buf :swapfile))
                (assert.are.equals 0 (vim.fn.isdirectory swap-dir))
                (vim.api.nvim_buf_delete buf {:force true})))))))))
