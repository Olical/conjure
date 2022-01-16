(module conjure.log
  {autoload {a conjure.aniseed.core
             nvim conjure.aniseed.nvim
             str conjure.aniseed.string
             buffer conjure.buffer
             client conjure.client
             config conjure.config
             view conjure.aniseed.view
             text conjure.text
             editor conjure.editor
             timer conjure.timer}
   require {sponsors conjure.sponsors}})

(defonce- state
  {:hud {:id nil
         :timer nil
         :created-at-ms 0}
   :jump_to_latest {:mark nil
                    :ns (nvim.create_namespace "conjure_log_jump_to_latest")}})

(defn- break []
  (.. (client.get :comment-prefix)
      (string.rep "-" (config.get-in [:log :break_length]))))

(defn- state-key-header []
  (.. (client.get :comment-prefix) "State: " (client.state-key)))

(defn- log-buf-name []
  (.. "conjure-log-" (nvim.fn.getpid) (client.get :buf-suffix)))

(defn log-buf? [name]
  (text.ends-with name (log-buf-name)))

(defn- on-new-log-buf [buf]
  (set state.jump_to_latest.mark
       (nvim.buf_set_extmark buf state.jump_to_latest.ns 0 0 {}))

  (nvim.buf_set_lines
    buf 0 -1 false
    [(.. (client.get :comment-prefix)
         "Sponsored by @"
         (a.get sponsors (a.inc (math.floor (a.rand (a.dec (a.count sponsors))))))
         " ❤")]))

(defn- upsert-buf []
  (buffer.upsert-hidden
    (log-buf-name)
    on-new-log-buf))

(defn clear-close-hud-passive-timer []
  (a.update-in state [:hud :timer] timer.destroy))

(defn close-hud []
  (clear-close-hud-passive-timer)
  (when state.hud.id
    (pcall nvim.win_close state.hud.id true)
    (set state.hud.id nil)))

(defn hud-lifetime-ms []
  (- (vim.loop.now) state.hud.created-at-ms))

(defn close-hud-passive []
  (when (and state.hud.id
             (> (hud-lifetime-ms)
                (config.get-in [:log :hud :minimum_lifetime_ms])))
    (let [original-timer-id state.hud.timer-id
          delay (config.get-in [:log :hud :passive_close_delay])]
      (if (= 0 delay)
        (close-hud)
        (when (not (a.get-in state [:hud :timer]))
          (a.assoc-in
            state [:hud :timer]
            (timer.defer close-hud delay)))))))

(defn- break-lines [buf]
  (let [break-str (break)]
    (->> (nvim.buf_get_lines buf 0 -1 false)
         (a.kv-pairs)
         (a.filter
           (fn [[n s]]
             (= s break-str)))
         (a.map a.first))))

(defn- set-win-opts! [win]
  (nvim.win_set_option
    win :wrap
    (if (config.get-in [:log :wrap])
      true
      false))
  (nvim.win_set_option win :foldmethod :marker)
  (nvim.win_set_option win :foldmarker (.. (config.get-in [:log :fold :marker :start])
                                           ","
                                           (config.get-in [:log :fold :marker :end])))
  (nvim.win_set_option win :foldlevel 0))

(defn- in-box? [box pos]
  (and (>= pos.x box.x1) (<= pos.x box.x2)
       (>= pos.y box.y1) (<= pos.y box.y2)))

(defn- flip-anchor [anchor n]
  (let [chars [(anchor:sub 1 1)
               (anchor:sub 2)]
        flip {:N :S
              :S :N
              :E :W
              :W :E}]
    (str.join (a.update chars n #(a.get flip $1)))))

(defn- pad-box [box padding]
  (-> box
      (a.update :x1 #(- $1 padding.x))
      (a.update :y1 #(- $1 padding.y))
      (a.update :x2 #(+ $1 padding.x))
      (a.update :y2 #(+ $1 padding.y))))

(defn- hud-window-pos [anchor size rec?]
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
                    (nvim.err_writeln "g:conjure#log#hud#anchor must be one of: NE, SE, SW, NW")
                    (hud-window-pos :NE size)))
                (a.assoc :anchor anchor))]

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

(defn- display-hud []
  (when (config.get-in [:log :hud :enabled])
    (clear-close-hud-passive-timer)
    (let [buf (upsert-buf)
          last-break (a.last (break-lines buf))
          line-count (nvim.buf_line_count buf)
          size {:width (editor.percent-width (config.get-in [:log :hud :width]))
                :height (editor.percent-height (config.get-in [:log :hud :height]))}
          pos (hud-window-pos (config.get-in [:log :hud :anchor]) size)
          border (config.get-in [:log :hud :border])
          win-opts
          (a.merge
            {:relative :editor
             :row pos.row
             :col pos.col
             :anchor pos.anchor

             :width size.width
             :height size.height
             :focusable false
             :style :minimal}
            (when (= 1 (nvim.fn.has "nvim-0.5"))
              {:border border}))]

      (when (and state.hud.id
                 (not (nvim.win_is_valid state.hud.id)))
        (close-hud))

      (if state.hud.id
        (nvim.win_set_buf state.hud.id buf)
        (do
          (set state.hud.id (nvim.open_win buf false win-opts))
          (set-win-opts! state.hud.id)))

      (set state.hud.created-at-ms (vim.loop.now))

      (if last-break
        (do
          (nvim.win_set_cursor state.hud.id [1 0])
          (nvim.win_set_cursor
            state.hud.id
            [(math.min
               (+ last-break
                  (a.inc (math.floor (/ win-opts.height 2))))
               line-count)
             0]))
        (nvim.win_set_cursor state.hud.id [line-count 0])))))

(defn- win-visible? [win]
  (= (nvim.fn.tabpagenr)
     (a.first (nvim.fn.win_id2tabwin win))))

(defn- with-buf-wins [buf f]
  (a.run!
    (fn [win]
      (when (= buf (nvim.win_get_buf win))
        (f win)))
    (nvim.list_wins)))

(defn- win-botline [win]
  (-> win
      (nvim.fn.getwininfo)
      (a.first)
      (a.get :botline)))

(defn- trim [buf]
  (let [line-count (nvim.buf_line_count buf)]
    (when (> line-count (config.get-in [:log :trim :at]))
      (let [target-line-count (- line-count (config.get-in [:log :trim :to]))
            break-line
            (a.some
              (fn [line]
                (when (>= line target-line-count)
                  line))
              (break-lines buf))]

        (when break-line
          (nvim.buf_set_lines
            buf 0
            break-line
            false [])

          ;; This hack keeps all log window view ports correct after trim.
          ;; Without it the text moves off screen in the HUD.
          (let [line-count (nvim.buf_line_count buf)]
            (with-buf-wins
              buf
              (fn [win]
                (let [[row col] (nvim.win_get_cursor win)]
                  (nvim.win_set_cursor win [1 0])
                  (nvim.win_set_cursor win [row col]))))))))))

(defn last-line [buf extra-offset]
  (a.first
    (nvim.buf_get_lines
      (or buf (upsert-buf))
      (+ -2 (or extra-offset 0)) -1 false)))

(def cursor-scroll-position->command
  {:top "normal zt"
   :center "normal zz"
   :bottom "normal zb"
   :none nil})

(defn jump-to-latest []
  (let [buf (upsert-buf)
        last-eval-start (nvim.buf_get_extmark_by_id
                          buf state.jump_to_latest.ns
                          state.jump_to_latest.mark {})]
    (with-buf-wins
      buf
      (fn [win]
        (nvim.win_set_cursor win last-eval-start)

        (let [cmd (a.get
                    cursor-scroll-position->command
                    (config.get-in [:log :jump_to_latest :cursor_scroll_position]))]
          (when cmd
            (nvim.win_call win (fn [] (nvim.command cmd)))))))))

(defn append [lines opts]
  (let [line-count (a.count lines)]
    (when (> line-count 0)
      (var visible-scrolling-log? false)

      (let [buf (upsert-buf)
            join-first? (a.get opts :join-first?)

            ;; A failsafe for newlines in lines. They _should_ be split up by
            ;; the calling code but this means we at least print the line
            ;; rather than throwing an error.
            lines (a.map (fn [s] (s:gsub "\n" "↵")) lines)

            lines (if (<= line-count
                          (config.get-in [:log :strip_ansi_escape_sequences_line_limit]))
                    (a.map text.strip-ansi-escape-sequences lines)
                    lines)
            comment-prefix (client.get :comment-prefix)

            ;; Optionally insert fold markers.
            ;; When we're not doing a "break" (seperator).
            ;; Not joining with the previous line.
            ;; Folding is enabled and we crossed the line count threshold.
            fold-marker-end (str.join [comment-prefix (config.get-in [:log :fold :marker :end])])
            lines (if (and (not (a.get opts :break?))
                           (not join-first?)
                           (config.get-in [:log :fold :enabled])
                           (>= (a.count lines) (config.get-in [:log :fold :lines])))
                    (a.concat
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
            last-fold? (= fold-marker-end (last-line buf))

            ;; Insert break comments or join continuing lines if required.
            lines (if
                    (a.get opts :break?)
                    (a.concat
                      [(break)]
                      (when (client.multiple-states?)
                        [(state-key-header)])
                      lines)

                    join-first?
                    (a.concat
                      (if last-fold?
                        [(.. (last-line buf -1)
                             (a.first lines))
                         fold-marker-end]
                        [(.. (last-line buf) (a.first lines))])
                      (a.rest lines))

                    lines)

            old-lines (nvim.buf_line_count buf)]

        (let [(ok? err)
              (pcall
                (fn []
                  (nvim.buf_set_lines
                    buf
                    (if
                      (buffer.empty? buf) 0

                      ;; Replace one extra line if joining across fold markers.
                      join-first? (if last-fold? -3 -2)

                      -1)
                    -1 false lines)))]
          (when (not ok?)
            (error (.. "Conjure failed to append to log: " err "\n"
                       "Offending lines: " (a.pr-str lines)))))

        (let [new-lines (nvim.buf_line_count buf)
              jump-to-latest? (config.get-in [:log :jump_to_latest :enabled])]
          (nvim.buf_set_extmark
            buf state.jump_to_latest.ns
            (a.inc old-lines) 0
            {:id state.jump_to_latest.mark})
          (with-buf-wins
            buf
            (fn [win]
              (set visible-scrolling-log? (and (not= win state.hud.id)
                                               (win-visible? win)
                                               (or jump-to-latest?
                                                   (>= (win-botline win) old-lines))))
              (let [[row _] (nvim.win_get_cursor win)]
                (if jump-to-latest?
                  (jump-to-latest)

                  (= row old-lines)
                  (nvim.win_set_cursor win [new-lines 0]))))))

        (if (and (not (a.get opts :suppress-hud?))
                 (not visible-scrolling-log?))
          (display-hud)
          (close-hud))

        (trim buf)))))

(defn- create-win [cmd]
  (let [buf (upsert-buf)]
    (nvim.command
      (.. "keepalt "
          (if (config.get-in [:log :botright])
            "botright "
            "")
          cmd " "
          (buffer.resolve (log-buf-name))))
    (nvim.win_set_cursor 0 [(nvim.buf_line_count buf) 0])
    (set-win-opts! 0)
    (buffer.unlist buf)))

(defn split []
  (create-win :split))

(defn vsplit []
  (create-win :vsplit))

(defn tab []
  (create-win :tabnew))

(defn buf []
  (create-win :buf))

(defn close-visible []
  (let [buf (upsert-buf)]
    (close-hud)
    (->> (nvim.tabpage_list_wins 0)
         (a.filter
           (fn [win]
             (= buf (nvim.win_get_buf win))))
         (a.run! #(nvim.win_close $1 true)))))

(defn dbg [desc ...]
  (when (config.get-in [:debug])
    (append
      (a.concat
        [(.. (client.get :comment-prefix) "debug: " desc)]
        (text.split-lines (a.pr-str ...)))))
  ...)

(defn reset-soft []
  (on-new-log-buf (upsert-buf)))

(defn reset-hard []
  (nvim.ex.bwipeout_ (upsert-buf)))
