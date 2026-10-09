(local {: describe : it : before_each} (require :plenary.busted))
(local assert (require :luassert.assert))
(local log (require :conjure.log))
(local client (require :conjure.client))
(local config (require :conjure.config))
(local vim _G.vim)

(describe "log-buf?"
  (fn []
    (before_each
      (fn []
        (config.assoc-in [:log :linked_to_client_state] false)
        (tset client.state :state-key-set? false)))

    (describe "linked_to_client_state disabled"
      (fn []
        (it "matches a buffer named with the PID"
          (fn []
            (client.with-filetype :fennel
              #(assert.is_true
                 (log.log-buf? (.. "conjure-log-" (vim.fn.getpid) ".fnl"))))))

        (it "does not match a buffer named with a state key"
          (fn []
            (client.set-state-key! :my-feature)
            (client.with-filetype :fennel
              #(assert.is_false (log.log-buf? "conjure-log-my-feature.fnl")))))))

    (describe "linked_to_client_state enabled with state key set"
      (fn []
        (before_each
          (fn []
            (config.assoc-in [:log :linked_to_client_state] true)
            (client.set-state-key! :my-feature)))

        (it "matches a buffer named with the state key"
          (fn []
            (client.with-filetype :fennel
              #(assert.is_true (log.log-buf? "conjure-log-my-feature.fnl")))))

        (it "does not match a buffer named with the PID"
          (fn []
            (client.with-filetype :fennel
              #(assert.is_false
                 (log.log-buf? (.. "conjure-log-" (vim.fn.getpid) ".fnl"))))))))

    (describe "linked_to_client_state enabled but no state key set"
      (fn []
        (before_each
          (fn []
            (config.assoc-in [:log :linked_to_client_state] true)))

        (it "falls back to matching a buffer named with the PID"
          (fn []
            (client.with-filetype :fennel
              #(assert.is_true
                 (log.log-buf? (.. "conjure-log-" (vim.fn.getpid) ".fnl"))))))))))

(describe "show-hud"
  (fn []
    (fn hud-floating? []
      (let [win log.state.hud.id]
        (and (= :number (type win))
             (vim.api.nvim_win_is_valid win)
             (not= "" (. (vim.api.nvim_win_get_config win) :relative)))))

    (before_each
      (fn []
        (log.close-hud)
        (config.assoc-in [:log :hud :enabled] true)))

    (it "opens the HUD"
      (fn []
        (client.with-filetype :fennel log.show-hud)
        (assert.is_true (hud-floating?))))

    (it "opens the HUD even when the automatic HUD is disabled"
      (fn []
        (config.assoc-in [:log :hud :enabled] false)
        (client.with-filetype :fennel log.show-hud)
        (assert.is_true (hud-floating?))))

    (it "reuses the open HUD window"
      (fn []
        (client.with-filetype :fennel log.show-hud)
        (let [first-win log.state.hud.id]
          (client.with-filetype :fennel log.show-hud)
          (assert.are.equals first-win log.state.hud.id))))))
