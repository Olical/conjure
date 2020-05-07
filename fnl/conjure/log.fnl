(module conjure.log
  {require {a conjure.aniseed.core
            nvim conjure.aniseed.nvim
            buffer conjure.buffer
            client conjure.client
            config conjure.config
            editor conjure.editor}})

(defonce- state
  {:hud {:id nil}})

(defn- break []
  (.. (client.get :comment-prefix)
      (string.rep "-" config.log.break-length)))

(defn- log-buf-name []
  (.. "conjure-log-" (nvim.fn.getpid) (client.get :buf-suffix)))

(defn- upsert-buf []
  (buffer.upsert-hidden (log-buf-name)))

(defn close-hud []
  (when state.hud.id
    (nvim.win_close state.hud.id true)
    (set state.hud.id nil)))

(defn- break-lines [buf]
  (let [break-str (break)]
    (->> (nvim.buf_get_lines buf 0 -1 false)
         (a.kv-pairs)
         (a.filter
           (fn [[n s]]
             (= s break-str)))
         (a.map a.first))))

(defn- display-hud []
  (when config.log.hud.enabled?
    (let [buf (upsert-buf)
          cursor-top-right? (and (> (editor.cursor-left) (editor.percent-width 0.5))
                                 (< (editor.cursor-top) (editor.percent-height 0.5)))
          last-break (a.last (break-lines buf))
          line-count (nvim.buf_line_count buf)
          win-opts
          {:relative :editor
           :row (if cursor-top-right?
                  (- (editor.height) 2)
                  0)
           :col (editor.width)
           :anchor :SE

           :width (editor.percent-width config.log.hud.width)
           :height (editor.percent-height config.log.hud.height)
           :focusable false
           :style :minimal}]

      (when (not state.hud.id)
        (set state.hud.id (nvim.open_win buf false win-opts))
        (nvim.win_set_option state.hud.id :wrap false))

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
    (when (> line-count config.log.trim.at)
      (let [target-line-count (- line-count config.log.trim.to)
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

(defn last-line []
  (a.first (nvim.buf_get_lines (upsert-buf) -2 -1 false)))

(defn append [lines opts]
  (when (not (a.empty? lines))
    (var visible-scrolling-log? false)

    (let [buf (upsert-buf)
          join-first? (a.get opts :join-first?)
          lines (if
                  (a.get opts :break?)
                  (a.concat [(break)] lines)

                  join-first?
                  (a.concat
                    [(.. (last-line) (a.first lines))]
                    (a.rest lines))

                  lines)
          old-lines (nvim.buf_line_count buf)]

      (nvim.buf_set_lines
        buf
        (if
          (buffer.empty? buf) 0
          join-first? -2
          -1)
        -1 false lines)

      (let [new-lines (nvim.buf_line_count buf)]
        (with-buf-wins
          buf
          (fn [win]
            (let [[row col] (nvim.win_get_cursor win)]
              (when (and (not= win state.hud.id)
                         (win-visible? win)
                         (>= (win-botline win) old-lines))
                (set visible-scrolling-log? true))

              (when (= row old-lines)
                (nvim.win_set_cursor win [new-lines 0]))))))

      (if (and (not (a.get opts :suppress-hud?))
               (not visible-scrolling-log?))
        (display-hud)
        (close-hud))

      (trim buf))))

(defn- create-win [split-fn]
  (let [buf (upsert-buf)
        win (split-fn (log-buf-name))]
    (nvim.win_set_cursor
      win
      [(nvim.buf_line_count buf) 0])
    (nvim.win_set_option win :wrap false)
    (buffer.unlist buf)))

(defn split []
  (create-win nvim.ex.split))

(defn vsplit []
  (create-win nvim.ex.vsplit))

(defn tab []
  (create-win nvim.ex.tabnew))

(defn close-visible []
  (let [buf (upsert-buf)]
    (close-hud)
    (->> (nvim.tabpage_list_wins 0)
         (a.filter
           (fn [win]
             (= buf (nvim.win_get_buf win))))
         (a.run! #(nvim.win_close $1 true)))))
