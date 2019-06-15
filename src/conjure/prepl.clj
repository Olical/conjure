(ns conjure.prepl
  "Remote prepl connection management and selection."
  (:require [clojure.core.async :as a]
            [clojure.core.server :as server]
            [clojure.java.io :as io]
            [clojure.edn :as edn]
            [taoensso.timbre :as log]
            [conjure.util :as util]
            [conjure.ui :as ui]
            [conjure.code :as code])
  (:import [java.io PipedInputStream PipedOutputStream]))

(defonce ^:private conns! (atom {}))

(defonce internal-port
  (or (some-> (util/env :conjure-prepl-server-port)
              (edn/read-string))
      (util/free-port)))

(defn- remove!
  "Remove the connection under the given tag. Shuts it down cleanly and blocks
  until it's done."
  [tag]
  (when-let [conn (get @conns! tag)]
    (log/info "Removing" tag)
    (ui/info "Removing" tag)
    (swap! conns! dissoc tag)

    ;; read-chan is closed when the remote-prepl exits. This
    ;; pattern of closing two here and then waiting for the
    ;; read-chan to return a nil (which it will when closed)
    ;; ensures that removal isn't complete until the remote-prepl is done.
    ;; This prevents some weird race conditions with node connections.
    (let [{:keys [eval-chan ret-chan read-chan]} (:chans conn)]
      (a/close! eval-chan)
      (a/close! ret-chan)
      (loop []
        (when-not (nil? (a/<!! read-chan))
          (recur))))))

(defn- remove-all!
  "Iterate over all connections and call remove on them all."
  []
  (doseq [tag (keys @conns!)]
    (remove! tag)))

(defn- connect
  "Connect to a prepl and return channels to interact with it. When the eval
  channel closes it cascades through the system and eventually closes the read
  channel. We can use this fact to await the read channel's closure to know
  when the closing is complete. Handy!"
  [{:keys [tag host port]}]
  (let [eval-chan (a/chan 32)
        read-chan (a/chan 32)
        input (PipedInputStream.)
        output (PipedOutputStream. input)]

    (util/thread
      "reader loop"
      (with-open [reader (io/reader input)]
        (try
          (log/info "Connecting through remote-prepl" tag)
          (server/remote-prepl
            host port reader
            (fn [out]
              (log/trace "Read from remote-prepl" tag "-" (update out :form util/sample 20))
              (a/>!! read-chan out))
            :valf identity)

          (catch Throwable e
            (log/error "Error from remote-prepl:" e)
            (ui/error "Error from" tag e))

          (finally
            (log/trace "Exited remote-prepl, cleaning up" tag)
            (a/close! read-chan)
            (remove! tag)))))

    (util/thread
      "writer loop"
      (with-open [writer (io/writer output)]
        (try
          (loop []
            (when-let [code (a/<!! eval-chan)]
              (log/trace "Writing to tag:" tag "-" code)
              (util/write writer code)
              (recur)))

          (catch Throwable e
            (log/error "Error from eval-chan writing:" e))

          (finally
            (log/trace "Exited eval-chan loop, cleaning up" tag)
            (util/write writer ":repl/quit\n")))))

    {:eval-chan eval-chan
     :read-chan read-chan}))

(defn- add!
  "Remove any existing connection under :tag then create a new connection."
  [{:keys [tag lang expr host port]}]

  (remove! tag)

  (cond
    (nil? port)
    (ui/info "Skipping" tag "- nil port")

    (not (util/socket? {:host host, :port port}))
    (ui/info "Skipping" tag "- can't connect")

    :else
    (do
      (log/info "Adding" tag host port)
      (ui/info "Adding" tag)

      (let [ret-chan (a/chan 32)
            conn {:tag tag
                  :lang lang
                  :host host
                  :port port
                  :expr expr
                  :chans (merge
                           {:ret-chan ret-chan}
                           (connect {:tag tag
                                     :host host
                                     :port port}))}
            prelude (code/prelude-str {:lang lang})]

        (swap! conns! assoc tag conn)

        (log/trace "Sending prelude:" (util/sample prelude 20))
        (a/>!! (get-in conn [:chans :eval-chan]) prelude)

        (loop []
          (if (= ":conjure/ready" (:val (a/<!! (get-in conn [:chans :read-chan]))))
            (log/trace "Prelude loaded")
            (recur)))

        (util/thread
          "read-chan handler"
          (loop []
            (when-let [out (a/<!! (get-in conn [:chans :read-chan]))]
              (log/trace "Read value from" (:tag conn) "-" (update out :form util/sample 20))
              (let [out (cond-> out
                          (contains? #{:tap :ret} (:tag out))
                          (update :val code/parse-code))]

                ;; This is when an error somehow makes it out of the prepl without being caught.
                ;; It usually means the user is having a bad time, let's at least get
                ;; something on screen that they can reference in an issue to help fix it.
                (when (:exception out)
                  (log/error "Uncaught error leaked out of prepl" (:val out))
                  (ui/error "Uncaught error from" (:tag conn) "this might be a bug in Conjure!"
                            (-> (:val out) clojure.main/ex-triage clojure.main/ex-str))
                  (ui/result {:conn conn
                              :resp (update out :val (fn [val] [:error val]))}))

                (if (= (:tag out) :ret)
                  (a/>!! ret-chan out)
                  (ui/result {:conn conn, :resp out})))
              (recur))))))))

(defn sync!
  "Disconnect from everything and attempt to connect to every new conn."
  [conns]
  (remove-all!)

  (doseq [[tag conn] conns
          :when (:enabled? conn)]
    (add! (assoc conn :tag tag))))

(defn conns
  "Without a path it'll return all current connections. With a path it finds
  any connection who's :expr matches that string."
  ([] (vals @conns!))
  ([path]
   (->> (conns)
        (filter
          (fn [{:keys [expr]}]
            (re-find expr path)))
        (seq))))

(defn status
  "Display the current status of the connections. This counts and lists with
  some connection information."
  []
  (let [conns (conns)
        intro (util/count-str conns "connection")
        conn-strs (for [{:keys [tag host port expr lang]} conns]
                    (str tag " @ " host ":" port " for " (pr-str expr) " (" lang ")"))]
    (ui/info (util/join-lines (into [intro] conn-strs)))))

(defn init
  "Initialise the internal prepl."
  []
  (server/start-server {:accept 'clojure.core.server/io-prepl
                        :address "127.0.0.1"
                        :name :dev
                        :port internal-port})
  (log/info "Started prepl server on port" internal-port))
