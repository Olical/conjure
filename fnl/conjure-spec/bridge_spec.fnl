(local {: describe : it} (require :plenary.busted))
(local bridge (require :conjure.bridge))
(local assert (require :luassert.assert))

(describe "viml->lua"
  (fn []
    (it "converts a module and function to a Lua require call without arguments"
      (fn []
        (let [result (bridge.viml->lua "my.module" "my_function" nil)]
          (assert.equal result "lua require('my.module')['my_function']()"))))

    (it "converts a module and function to a Lua require call with arguments"
      (fn []
          (let [result (bridge.viml->lua "my.module" "my_function" {:args "arg1, arg2"})]
          (assert.equal result "lua require('my.module')['my_function'](arg1, arg2)"))))))
