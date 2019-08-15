(ns conjure.main
  "Entry point and registration of RPC handlers."
  (:require [clojure.string :as str]
            [clojure.java.shell :as shell]
            [taoensso.timbre :as log]
            [taoensso.timbre.appenders.core :as appenders]
            [me.raynes.fs :as fs]
            [conjure.util :as util]
            [conjure.rpc :as rpc]
            [conjure.prepl :as prepl]
            [conjure.ui :as ui]
            [conjure.action :as action]
            [conjure.nvim :as nvim]))

(Thread/setDefaultUncaughtExceptionHandler
 (reify Thread$UncaughtExceptionHandler
   (uncaughtException [_ thread ex]
     (log/error "Uncaught exception on" (.getName thread) ex))))

(defn- clean-up-and-exit []
  (log/info "Shutting down")
  (shutdown-agents)
  (flush)
  (binding [*out* *err*] (flush))
  (.. Runtime (getRuntime) (halt 0)))

(defonce exit-handle! (promise))

(defn -main
  "Start up any background services and then wait until the exit promise is delivered."
  [cwd]
  (.. Runtime (getRuntime) (addShutdownHook (Thread. #(clean-up-and-exit))))

  (log/merge-config!
    {:level :trace
     :appenders {:println nil
                 :spit (when-let [path (util/env :conjure-log-path)]
                         (appenders/spit-appender {:fname (str (fs/file cwd path))}))}})
  (log/info "Logging initialised")

  (log/info (str "System versions\n" (:out (shell/sh "bin/versions"))))

  (rpc/init)
  (prepl/init)
  (nvim/set-ready!)
  (log/info "Everything's ready! Let's perform some magic.")
  @exit-handle!)

(defmacro ^:private defrpc
  "Register an RPC :notify or :request handler under the method keyword
  with parameter bindings and body. Sets nvim/ctx to (nvim/current-ctx)."
  [kind method params & body]
  `(defmethod
     ~(case kind
        :notify 'rpc/handle-notify
        :request 'rpc/handle-request)
     ~method
     [{~params :params}]
     (binding [nvim/ctx (nvim/current-ctx)]
       ~@body)))

;; Here we map RPC notifications and requests to their Clojure functions.
(defrpc :notify :up [flags]
  (action/up flags))

(defrpc :notify :status []
  (prepl/status))

(defrpc :notify :eval [code]
  (action/eval* {:code code, :line (nvim/current-line)}))

(defrpc :notify :eval-current-form []
  (action/eval-current-form))

(defrpc :notify :eval-root-form []
  (action/eval-root-form))

(defrpc :notify :eval-selection []
  (action/eval-selection))

(defrpc :notify :eval-buffer []
  (action/eval-buffer))

(defrpc :notify :load-file [file-path]
  (action/load-file* file-path))

(defrpc :notify :doc [symbol-name]
  (action/doc symbol-name))

(defrpc :notify :quick-doc []
  (action/quick-doc))

(defrpc :notify :clear-virtual []
  (action/clear-virtual))

(def ^:private log-opts
  {:focus? true
   :resize? true
   :size :large})

(defrpc :notify :open-log []
  (ui/upsert-log log-opts))

(defrpc :notify :close-log []
  (ui/close-log))

(defrpc :notify :toggle-log []
  (if (ui/log-open?)
    (ui/close-log)
    (ui/upsert-log log-opts)))

(defrpc :request :completions [base]
  (action/completions base))

(defrpc :request :get-rpc-port []
  rpc/port)

(defrpc :notify :definition [symbol-name]
  (action/definition symbol-name))

(defrpc :notify :run-tests [target-namespaces]
  (action/run-tests (->> (str/split target-namespaces #"\s+")
                         (remove str/blank?))))

(defrpc :notify :run-all-tests [target-namespaces]
  (action/run-all-tests (when-not (str/blank? target-namespaces)
                          target-namespaces)))

(defrpc :notify :refresh [flags]
  (action/refresh (some-> (not-empty flags)
                          (str/split #"\s+")
                          (->> (map keyword)
                               (set)))))

(defrpc :notify :stop []
  (deliver exit-handle! true))
