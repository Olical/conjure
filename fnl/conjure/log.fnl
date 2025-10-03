(local {: autoload : define} (require :conjure.nfnl.module))
(local core (autoload :conjure.nfnl.core))
(local str (autoload :conjure.nfnl.string))
(local buffer (autoload :conjure.buffer))
(local client (autoload :conjure.client))
(local hook (autoload :conjure.hook))
(local config (autoload :conjure.config))
(local text (autoload :conjure.text))
(local editor (autoload :conjure.editor))
(local timer (autoload :conjure.timer))
(local sponsors (require :conjure.sponsors))
(local vim _G.vim)

(local M (define :conjure.log))

(local state
  {:last-open-cmd :vsplit
   :hud {:id nil
         :timer nil
         :created-at-ms 0
         :low-priority-spam {:streak 0
                             :help-displayed? false}}
   :jump-to-latest {:mark nil
                    :ns (vim.api.nvim_create_namespace "conjure_log_jump_to_latest")}})

(fn break []
  (str.join
    [(client.get :comment-prefix)
     (string.rep "-" (config.get-in [:log :break_length]))]))

(fn state-key-header []
  (str.join [(client.get :comment-prefix) "State: " (client.state-key)]))

(fn log-buf-name []
  (str.join ["conjure-log-" (vim.fn.getpid) (client.get :buf-suffix)]))

(fn M.log-buf? [name]
  (vim.endswith name (log-buf-name)))

(fn on-new-log-buf [buf]
  (set state.jump-to-latest.mark
       (vim.api.nvim_buf_set_extmark buf state.jump-to-latest.ns 0 0 {}))

  (when (and vim.diagnostic (= false (config.get-in [:log :diagnostics])))
    (if (= 1 (vim.fn.has "nvim-0.10"))
      (vim.diagnostic.enable false {:bufnr buf})
      (vim.diagnostic.disable buf)))

  (when (and vim.treesitter (= false (config.get-in [:log :treesitter])))
    (vim.treesitter.stop buf)
    (tset vim.bo buf :syntax "on"))

  (vim.api.nvim_buf_set_lines
    buf 0 -1 false
    [(str.join [(client.get :comment-prefix)
                "Sponsored by @"
                (core.get sponsors (core.inc (math.floor (core.rand (core.dec (core.count sponsors))))))
                " ❤"])]))

(fn upsert-buf []
  (buffer.upsert-hidden
    (log-buf-name)
    (client.wrap on-new-log-buf)))

(fn M.clear-close-hud-passive-timer []
  (core.update-in state [:hud :timer] timer.destroy))

(hook.define
  :close-hud
  (fn []
    (when state.hud.id
      (pcall vim.api.nvim_win_close state.hud.id true)
      (set state.hud.id nil))))

(fn M.close-hud []
  (M.clear-close-hud-passive-timer)
  (hook.exec :close-hud))

(fn M.hud-lifetime-ms []
  (- (vim.uv.now) state.hud.created-at-ms))

(fn M.close-hud-passive []
  (when (and state.hud.id
             (> (M.hud-lifetime-ms)
                (config.get-in [:log :hud :minimum_lifetime_ms])))
    (let [delay (config.get-in [:log :hud :passive_close_delay])]
      (if (= 0 delay)
        (M.close-hud)
        (when (not (core.get-in state [:hud :timer]))
          (core.assoc-in
            state [:hud :timer]
            (timer.defer M.close-hud delay)))))))

(fn break-lines [buf]
  (let [break-str (break)]
    (->> (vim.api.nvim_buf_get_lines buf 0 -1 false)
         (core.kv-pairs)
         (core.filter
           (fn [[_n s]]
             (= s break-str)))
         (core.map core.first))))

(fn set-win-opts! [win]
  (tset vim.wo win :wrap (if (config.get-in [:log :wrap]) true false))
  (tset vim.wo win :foldmethod :marker)
  (tset vim.wo win :foldmarker (.. (config.get-in [:log :fold :marker :start])
                                  ","
                                  (config.get-in [:log :fold :marker :end])))
  (tset vim.wo win :foldlevel 0))

(fn in-box? [box pos]
  (and (>= pos.x box.x1) (<= pos.x box.x2)
       (>= pos.y box.y1) (<= pos.y box.y2)))

(fn flip-anchor [anchor n]
  (let [chars [(anchor:sub 1 1)
               (anchor:sub 2)]
        flip {:N :S
              :S :N
              :E :W
              :W :E}]
    (str.join (core.update chars n #(core.get flip $1)))))

(fn pad-box [box padding]
  (-> box
      (core.update :x1 #(- $1 padding.x))
      (core.update :y1 #(- $1 padding.y))
      (core.update :x2 #(+ $1 padding.x))
      (core.update :y2 #(+ $1 padding.y))))

(fn hud-window-pos [anchor size rec?]
  (let [north 0 west 0
        south (- (editor.height) 2)
        east (editor.width)
        padding-percent (config.get-in [:log :hud :overlap_padding])
        pos (-> (if
                  (= :NE anchor) {:row north :col east
                                  :box {:y1 north :x1 (- east size.width)
                                        :y2 (+ north size.height) :x2 east}}
                  (= :SE anchor) {:row south :col east
                                  :box {:y1 (- south size.height) :x1 (- east size.width)
                                        :y2 south :x2 east}}
                  (= :SW anchor) {:row south :col west
                                  :box {:y1 (- south size.height) :x1 west
                                        :y2 south :x2 (+ west size.width)}}
                  (= :NW anchor) {:row north :col west
                                  :box {:y1 north :x1 west
                                        :y2 (+ north size.height) :x2 (+ west size.width)}}
                  (do
                    (vim.notify "g:conjure#log#hud#anchor must be one of: NE, SE, SW, NW" 
                                vim.log.levels.ERROR)
                    (hud-window-pos :NE size)))
                (core.assoc :anchor anchor))]

    (if (and (not rec?)
             (in-box?
               (pad-box
                 pos.box
                 {:x (editor.percent-width padding-percent)
                  :y (editor.percent-height padding-percent)})
               {:x (editor.cursor-left)
                :y (editor.cursor-top)}))
      (hud-window-pos
        (flip-anchor anchor (if (> size.width size.height) 1 2))
        size true)
      pos)))

(fn current-window-floating? []
  (= :number (type (core.get (vim.api.nvim_win_get_config 0) :zindex))))

(local low-priority-streak-threshold 5)

(fn handle-low-priority-spam! [low-priority?]
  ;; When we see a bunch of low-priority? messages opening the HUD repeatedly
  ;; we display a bit of help _once_ that can prevent this spam in the future
  ;; for the user.
  (when (not (core.get-in state [:hud :low-priority-spam :help-displayed?]))
    (if low-priority?
      (core.update-in state [:hud :low-priority-spam :streak] core.inc)
      (core.assoc-in state [:hud :low-priority-spam :streak] 0))

    (when (> (core.get-in state [:hud :low-priority-spam :streak]) low-priority-streak-threshold)
      (let [pref (client.get :comment-prefix)]
        (client.schedule
          (. (require :conjure.log) :append)
          [(.. pref "Is the HUD popping up too much and annoying you in this project?")
           (.. pref "Set this option to suppress this kind of output for this session.")
           (.. pref "  :let g:conjure#log#hud#ignore_low_priority = v:true")]
          {:break? true}))
      (core.assoc-in state [:hud :low-priority-spam :help-displayed?] true))))

(hook.define
  :display-hud
  (fn [opts]
    (let [buf (upsert-buf)
          last-break (core.last (break-lines buf))
          line-count (vim.api.nvim_buf_line_count buf)
          size {:width (editor.percent-width (config.get-in [:log :hud :width]))
                :height (editor.percent-height (config.get-in [:log :hud :height]))}
          pos (hud-window-pos (config.get-in [:log :hud :anchor]) size)
          border (config.get-in [:log :hud :border])
          win-opts
          (core.merge
            {:relative :editor
             :row pos.row
             :col pos.col
             :anchor pos.anchor

             :width size.width
             :height size.height
             :focusable false
             :style :minimal
             :zindex (config.get-in [:log :hud :zindex])
             :border border})]

      (when (and state.hud.id (not (vim.api.nvim_win_is_valid state.hud.id)))
        (M.close-hud))

      (if state.hud.id
        (vim.api.nvim_win_set_buf state.hud.id buf)
        (do
          (handle-low-priority-spam! (core.get opts :low-priority?))
          (set state.hud.id (vim.api.nvim_open_win buf false win-opts))
          (set-win-opts! state.hud.id)))

      (set state.hud.created-at-ms (vim.uv.now))

      (if last-break
        (do
          (vim.api.nvim_win_set_cursor state.hud.id [1 0])
          (vim.api.nvim_win_set_cursor state.hud.id
            [(math.min
               (+ last-break
                  (core.inc (math.floor (/ win-opts.height 2))))
               line-count)
             0]))
        (vim.api.nvim_win_set_cursor state.hud.id [line-count 0])))))

(fn display-hud [opts]
  (when (and (config.get-in [:log :hud :enabled])

             ;; Don't display when the user is already doing something in a floating window.
             (not (current-window-floating?))

             ;; Don't display low priority messages if configured.
             (or (not (config.get-in [:log :hud :ignore_low_priority]))
                 (and (config.get-in [:log :hud :ignore_low_priority])
                      (not (core.get opts :low-priority?)))))
    (M.clear-close-hud-passive-timer)
    (hook.exec :display-hud opts)))

(fn win-visible? [win]
  (= (vim.fn.tabpagenr)
     (core.first (vim.fn.win_id2tabwin win))))

(fn with-buf-wins [buf f]
  (core.run!
    (fn [win]
      (when (= buf (vim.api.nvim_win_get_buf win))
        (f win)))
    (vim.api.nvim_list_wins)))

(fn win-botline [win]
  (-> win
      (vim.fn.getwininfo)
      (core.first)
      (core.get :botline)))

(fn trim [buf]
  (let [line-count (vim.api.nvim_buf_line_count buf)]
    (when (> line-count (config.get-in [:log :trim :at]))
      (let [target-line-count (- line-count (config.get-in [:log :trim :to]))
            break-line
            (core.some
              (fn [line]
                (when (>= line target-line-count)
                  line))
              (break-lines buf))]

        (when break-line
          (vim.api.nvim_buf_set_lines buf 0 break-line false [])

          ;; This hack keeps all log window view ports correct after trim.
          ;; Without it the text moves off screen in the HUD.
          (with-buf-wins
            buf
            (fn [win]
              (let [[row col] (vim.api.nvim_win_get_cursor win)]
                (vim.api.nvim_win_set_cursor win [1 0])
                (vim.api.nvim_win_set_cursor win [row col])))))))))

(fn M.last-line [buf extra-offset]
  (core.first
    (vim.api.nvim_buf_get_lines
      (or buf (upsert-buf))
      (+ -2 (or extra-offset 0)) -1 false)))

(set M.cursor-scroll-position->command
  {:top "normal zt"
   :center "normal zz"
   :bottom "normal zb"
   :none nil})

(fn M.jump-to-latest []
  (M.close-hud)
  (let [buf (upsert-buf)
        last-eval-start (vim.api.nvim_buf_get_extmark_by_id
                          buf state.jump-to-latest.ns
                          state.jump-to-latest.mark {})]
    (with-buf-wins
      buf
      (fn [win]
        (pcall #(vim.api.nvim_win_set_cursor win last-eval-start))

        (let [cmd (core.get
                    M.cursor-scroll-position->command
                    (config.get-in [:log :jump_to_latest :cursor_scroll_position]))]
          (when cmd
            (vim.api.nvim_win_call win (fn [] (vim.cmd cmd)))))))))

(fn M.append [lines opts]
  (let [line-count (core.count lines)]
    (when (> line-count 0)
      (var visible-scrolling-log? false)
      (var visible-log? false)

      (let [buf (upsert-buf)
            join-first? (core.get opts :join-first?)

            ;; A failsafe for newlines in lines. They _should_ be split up by
            ;; the calling code but this means we at least print the line
            ;; rather than throwing an error.
            ;; We also ensure every value _is_ a string. If we have a nil in
            ;; here it will at least be the right type for the gsub.
            lines (core.map
                    (fn [line]
                      (string.gsub (tostring line) "\n" "↵"))
                    lines)

            lines (if (<= line-count
                          (config.get-in [:log :strip_ansi_escape_sequences_line_limit]))
                    (core.map text.strip-ansi-escape-sequences lines)
                    lines)
            comment-prefix (client.get :comment-prefix)

            ;; Optionally insert fold markers.
            ;; When we're not doing a "break" (seperator).
            ;; Not joining with the previous line.
            ;; Folding is enabled and we crossed the line count threshold.
            fold-marker-end (str.join [comment-prefix (config.get-in [:log :fold :marker :end])])
            lines (if (and (not (core.get opts :break?))
                           (not join-first?)
                           (config.get-in [:log :fold :enabled])
                           (>= (core.count lines) (config.get-in [:log :fold :lines])))
                    (core.concat
                      [(str.join [comment-prefix
                                  (config.get-in [:log :fold :marker :start])
                                  " "
                                  (text.left-sample
                                    (str.join "\n" lines)
                                    (editor.percent-width
                                      (config.get-in [:preview :sample_limit])))])]
                      lines
                      [fold-marker-end])
                    lines)

            ;; When the last line in the buffer is a closing fold marker...
            ;; It means join-first? should account for it so it joins _inside_
            ;; the fold block by including the fold end line in the replacement.
            last-fold? (= fold-marker-end (M.last-line buf))

            ;; Insert break comments or join continuing lines if required.
            lines (if
                    (core.get opts :break?)
                    (core.concat
                      [(break)]
                      (when (client.multiple-states?)
                        [(state-key-header)])
                      lines)

                    join-first?
                    (core.concat
                      (if last-fold?
                        [(.. (M.last-line buf -1)
                             (core.first lines))
                         fold-marker-end]
                        [(.. (M.last-line buf) (core.first lines))])
                      (core.rest lines))

                    lines)

            old-lines (vim.api.nvim_buf_line_count buf)]

        (let [(ok? err)
              (pcall
                (fn []
                  (vim.api.nvim_buf_set_lines
                    buf
                    (if
                      (buffer.empty? buf) 0

                      ;; Replace one extra line if joining across fold markers.
                      join-first? (if last-fold? -3 -2)

                      -1)
                    -1 false lines)))]
          (when (not ok?)
            (error (.. "Conjure failed to append to log: " err "\n"
                       "Offending lines: " (core.pr-str lines)))))

        (let [new-lines (vim.api.nvim_buf_line_count buf)
              jump-to-latest? (config.get-in [:log :jump_to_latest :enabled])]

          ;; This mark is used when jumping to the latest log entry.
          (vim.api.nvim_buf_set_extmark
            buf state.jump-to-latest.ns
            (if join-first?
              old-lines
              (core.inc old-lines)) 0
            {:id state.jump-to-latest.mark})

          (with-buf-wins
            buf
            (fn [win]
              (set visible-scrolling-log?
                   (and (not= win state.hud.id)
                        (win-visible? win)
                        (or jump-to-latest?
                            (>= (win-botline win) old-lines))))

              (set visible-log?
                   (and (not= win state.hud.id)
                        (win-visible? win)))

              (let [[row _] (vim.api.nvim_win_get_cursor win)]
                (if jump-to-latest?
                  (M.jump-to-latest)

                  (= row old-lines)
                  (vim.api.nvim_win_set_cursor win [new-lines 0]))))))

        (let [open-when (config.get-in [:log :hud :open_when])]
          (if (and (not (core.get opts :suppress-hud?))

                   (or (and (= :last-log-line-not-visible open-when)
                            (not visible-scrolling-log?))

                       (and (= :log-win-not-visible open-when)
                            (not visible-log?))))
            (display-hud opts)
            (trim buf)))))))

(fn create-win [cmd]
  (set state.last-open-cmd cmd)
  (let [buf (upsert-buf)]
    (vim.cmd (string.format "keepalt %s %s %s" 
                            (if (config.get-in [:log :botright]) "botright" "")
                            cmd
                            (buffer.resolve (log-buf-name))))
    (vim.api.nvim_win_set_cursor 0 [(vim.api.nvim_buf_line_count buf) 0])
    (set-win-opts! 0)
    (buffer.unlist buf)))

(fn M.split []
  (create-win :split)
  (let [height (config.get-in [:log :split :height])]
    (when height
      (vim.api.nvim_win_set_height 0 (editor.percent-height height)))))

(fn M.vsplit []
  (create-win :vsplit)
  (let [width (config.get-in [:log :split :width])]
    (when width
      (vim.api.nvim_win_set_width 0 (editor.percent-width width)))))

(fn M.tab []
  (create-win :tabnew))

(fn M.buf []
  (create-win :buf))

(fn find-windows []
  (let [buf (upsert-buf)]
    (core.filter (fn [win] (and (not= state.hud.id win)
                             (= buf (vim.api.nvim_win_get_buf win))))
              (vim.api.nvim_tabpage_list_wins 0))))

(fn close [windows]
  (core.run! #(vim.api.nvim_win_close $1 true) windows))

(fn M.close-visible []
  (M.close-hud)
  (close (find-windows)))

(fn M.toggle []
  (let [windows (find-windows)]
    (if (core.empty? windows)
      (when (or (= state.last-open-cmd :split)
                (= state.last-open-cmd :vsplit))
        (create-win state.last-open-cmd))
      (M.close-visible windows))))

(fn M.dbg [desc ...]
  (when (config.get-in [:debug])
    (M.append
      (core.concat
        [(.. (client.get :comment-prefix) "debug: " desc)]
        (text.split-lines (core.pr-str ...)))))
  ...)

(fn M.reset-soft []
  (on-new-log-buf (upsert-buf)))

(fn M.reset-hard []
  (vim.api.nvim_buf_delete (upsert-buf) {:force true}))

M
