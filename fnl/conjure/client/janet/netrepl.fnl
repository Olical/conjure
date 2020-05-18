(module conjure.client.janet.netrepl
  {require {bit bit
            a conjure.aniseed.core
            str conjure.aniseed.string
            nvim conjure.aniseed.nvim
            view conjure.aniseed.view
            bridge conjure.bridge
            mapping conjure.mapping
            client conjure.client
            net conjure.net
            text conjure.text
            log conjure.log}})

;; TODO DRY out by sharing code with conjure.client.clojure.nrepl.
;; TODO Better parsing, what if there's multiple results!
;; TODO Some compiler errors seem to kill the stateful decoding.

(def buf-suffix ".janet")
(def comment-prefix "# ")

(def config
  {:debug? false
   :connection {:default-host "127.0.0.1"
                :default-port "9365"}
   :mappings {:connect "cc"
              :disconnect "cd"}})

(defonce- state
  {:conn nil})

(defn- display [lines opts]
  (client.with-filetype :janet log.append lines opts))

(defn- dbg [desc data]
  (when config.debug?
    (display
      (a.concat
        [(.. "# debug: " desc)]
        (text.split-lines (view.serialise data)))))
  data)

(defn- encode [msg]
  (let [n (a.count msg)]
    (..  (string.char
           (bit.band n 0xFF)
           (bit.band (bit.rshift n 8) 0xFF)
           (bit.band (bit.rshift n 16) 0xFF)
           (bit.band (bit.rshift n 24) 0xFF))
        msg)))

(defn- decode-one [chunk]
  (let [expecting (a.get-in state [:conn :expecting])]
    (if expecting
      (let [part (.. (a.get-in state [:conn :part]) chunk)
            part-n (a.count part)]
        (if (>= part-n expecting)
          (do
            (a.assoc-in state [:conn :expecting] nil)
            (a.assoc-in state [:conn :part] nil)
            [(string.sub part 1 expecting)
             (when (> part-n expecting)
               (string.sub part (a.inc expecting)))])
          (do
            (a.assoc-in state [:conn :part] part)
            nil)))
      (let [n (->> (a.map
                     (fn [c]
                       (string.byte (string.sub chunk c c)))
                     [1 2 3 4])
                   (a.reduce #(+ $1 $2) 0))
            part (string.sub chunk 5)
            part-n (a.count part)]
        (if
          (>= part-n n)
          [(string.sub part 1 n)
           (when (> part-n n)
             (string.sub part (a.inc n)))]
          (do
            (a.assoc-in state [:conn :expecting] n)
            (a.assoc-in state [:conn :part] part)
            nil))))))

(defn- decode-all [chunk acc]
  (let [acc (or acc [])
        res (decode-one chunk)]
    (if res
      (let [[msg rem] res]
        (table.insert acc msg)
        (if rem
          (decode-all rem acc)
          acc))
      acc)))

(defn- with-conn-or-warn [f opts]
  (let [conn (a.get state :conn)]
    (if conn
      (f conn)
      (do
        (when (not (a.get opts :silent?))
          (display ["# No connection"]))
        (when (a.get opts :else)
          (opts.else))))))

(defn display-conn-status [status]
  (with-conn-or-warn
    (fn [conn]
      (display
        [(.. "# " conn.raw-host ":" conn.port " (" status ")")]
        {:break? true}))))

(defn disconnect []
  (with-conn-or-warn
    (fn [conn]
      (when (not (conn.sock:is_closing))
        (conn.sock:read_stop)
        (conn.sock:shutdown)
        (conn.sock:close))
      (display-conn-status :disconnected)
      (a.assoc state :conn nil))))

(defn- handle-message [err chunk]
  (let [conn (a.get state :conn)]
    (if
      err (display-conn-status err)
      (not chunk) (disconnect)
      (->> (decode-all chunk)
           (a.run!
             (fn [msg]
               (dbg "receive" msg)
               (let [cb (table.remove (a.get-in state [:conn :queue]))]
                 (when cb
                   (cb msg)))))))))

(defn- send [msg cb]
  (dbg "send" msg)
  (with-conn-or-warn
    (fn [conn]
      (table.insert (a.get-in state [:conn :queue]) 1 (or cb false))
      (conn.sock:write (encode msg)))))

(defn- handle-connect-fn [cb]
  (vim.schedule_wrap
    (fn [err]
      (let [conn (a.get state :conn)]
        (if err
          (do
            (display-conn-status err)
            (disconnect))

          (do
            (conn.sock:read_start (vim.schedule_wrap handle-message))
            (send "Conjure")
            (display-conn-status :connected)))))))

(defn connect [host port]
  (let [host (or host config.connection.default-host)
        port (or port config.connection.default-port)
        resolved-host (net.resolve host)
        conn {:sock (vim.loop.new_tcp)
              :host resolved-host
              :raw-host host
              :port port
              :queue []}]

    (when (a.get state :conn)
      (disconnect))

    (a.assoc state :conn conn)
    (conn.sock:connect resolved-host port (handle-connect-fn))))

(defn- parse-result [msg]
  (let [lines (-> msg
                  (text.strip-ansi-codes)
                  (text.trim-last-newline)
                  (text.split-lines)
                  (a.kv-pairs))
        total (a.count lines)
        head (a.second (a.first lines))]
    (table.sort lines #(> (a.first $1) (a.first $2)))
    (var text-lines [])
    (var data-lines [])
    (var data?
      (not (or (text.starts-with head "error:")
               (text.starts-with head "compile error:"))))

    (a.run!
      (fn [[n line]]
        (if
          (and data? (text.starts-with line "("))
          (do
            (table.insert
              data-lines 1
              (string.sub line 2
                          (when (a.empty? data-lines)
                            -2)))
            (set data? false))

          data?
          (table.insert
            data-lines 1
            (string.sub line 3
                        (when (= n total)
                          -2)))

          (table.insert
            text-lines 1
            (.. "# " line))))
      lines)
    {:text-lines text-lines
     :data-lines data-lines
     :data (str.join "\n" data-lines)}))

(defn- display-result [{: text-lines : data-lines}]
  (when text-lines
    (display text-lines))
  (display data-lines))

(defn eval-str [opts]
  (send
    (.. "[" opts.code "\n]\n")
    (fn [msg]
      (let [res (parse-result msg)]
        (opts.on-result res.data)
        (display-result res)))))

(defn doc-str [opts]
  (display ["# Not implemented yet."]))

(defn eval-file [opts]
  (display ["# Not implemented yet."]))

(defn on-filetype []
  (mapping.buf :n config.mappings.disconnect
               :conjure.client.janet.netrepl :disconnect)
  (mapping.buf :n config.mappings.connect
               :conjure.client.janet.netrepl :connect)

  (nvim.ex.command_
    "-nargs=+ -buffer ConjureConnect"
    (bridge.viml->lua
      :conjure.client.janet.netrepl :connect
      {:args "<f-args>"})))

(defn on-load []
  (nvim.ex.augroup :conjure_janet_netrepl_cleanup)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    "VimLeavePre *"
    (bridge.viml->lua :conjure.client.janet.netrepl :disconnect {}))
  (nvim.ex.augroup :END)

  (connect))
