(ns conjure.action
  "Things the user can do that probably trigger some sort of UI update."
  (:require [clojure.core.async :as a]
            [clojure.string :as str]
            [taoensso.timbre :as log]
            [conjure.prepl :as prepl]
            [conjure.ui :as ui]
            [conjure.nvim :as nvim]
            [conjure.code :as code]
            [conjure.util :as util]
            [conjure.config :as config]))

(defn- current-conns
  ([] (current-conns {}))
  ([{:keys [passive?] :or {passive? false}}]
   (let [conns (prepl/conns (:path nvim/ctx))]

     (when (and (not passive?) (empty? conns))
       (ui/error "No matching connections for" (:path nvim/ctx)))

     conns)))

(defn- wrapped-eval
  "Wraps up code with environment specific padding, sends it off for evaluation
  and blocks until we get a result."
  [{:keys [conn] :as opts}]
  (let [{:keys [eval-chan ret-chan]} (:chans conn)]
    (a/>!! eval-chan (code/eval-str nvim/ctx opts))

    (when (= (:lang conn) :cljs)
      ;; ClojureScript requires two evals:
      ;; * Change namespace.
      ;; * Execute the provided code.
      ;; We throw away the namespace result first.
      (a/<!! ret-chan))

    (a/<!! ret-chan)))

(defn- raw-eval
  "Unlike wrapped-eval, it will send the exact code it is given and then block
  for a response."
  [{:keys [conn code]}]
  (let [{:keys [eval-chan ret-chan]} (:chans conn)]
    (a/>!! eval-chan code)
    (a/<!! ret-chan)))

(defn- not-exception
  "If the result has :exception true then display it with a nice message and
  return nil, otherwise return the result. Useful for actions that might fail their evals.
  It works kind of like not-empty."
  [{:keys [conn resp msg]}]
  (if (:exception resp)
    (do
      (log/error "Exception from" (pr-str (:tag conn)) (str "'" msg "'") (pr-str resp))
      (when msg
        (ui/result {:conn conn, :resp resp})
        (ui/error msg)))
    resp))

;; The following functions are called by the user through commands.

(defn up [flags]
  (-> (config/fetch {:flags flags, :cwd (nvim/cwd)})
      (get :conns)
      (prepl/sync!)
      (ui/up-summary)))

(defn eval* [{:keys [code line]}]
  (when code
    (doseq [conn (current-conns)]
      (let [opts {:conn conn
                  :code code
                  :line line}]
        (ui/eval* opts)
        (ui/result {:conn conn
                    :resp (wrapped-eval opts)})))))

(defn doc [name]
  (doseq [conn (current-conns)]
    (when-let [result (some-> (not-exception
                                {:conn conn
                                 :resp (wrapped-eval {:conn conn
                                                      :code (code/doc-str
                                                              {:conn conn
                                                               :name name})})
                                 :msg (str "Failed to lookup documentation for " name)})
                              (update :val util/parse-code))]
      (ui/doc {:conn conn
               :resp (cond-> result
                       (str/blank? (:val result))
                       (assoc :val (str "No doc for " name)))}))))

(defn clear-virtual []
  (nvim/clear-virtual))

(defn quick-doc []
  (let [name (some-> (nvim/read-form {:data-pairs? false})
                     (get :form)
                     (util/parse-code)
                     (as-> x
                       (when (seq? x) (first x)))
                     (str))]
    (if-let [doc-str (and name
                          (some (fn [conn]
                                  (some-> (not-exception
                                            {:conn conn
                                             :resp (wrapped-eval
                                                     {:conn conn
                                                      :code (code/doc-str
                                                              {:conn conn
                                                               :name name})})})
                                          (get :val)
                                          (util/parse-code)
                                          (not-empty)))
                                (current-conns {:passive? true})))]
      (ui/quick-doc doc-str)
      (clear-virtual))))

(defn eval-current-form []
  (let [{:keys [form origin]} (nvim/read-form)]
    (eval* {:code form
            :line (first origin)})))

(defn eval-root-form []
  (let [{:keys [form origin]} (nvim/read-form {:root? true})]
    (eval* {:code form
            :line (first origin)})))

(defn eval-selection []
  (let [{:keys [selection origin]} (nvim/read-selection)]
    (eval* {:code selection
            :line (first origin)})))

(defn eval-buffer []
  (eval* {:code (nvim/read-buffer)}))

(defn load-file* [path]
  (let [code (code/load-file-str path)]
    (doseq [conn (current-conns)]
      (let [opts {:conn conn, :code code, :path path}]
        (ui/load-file* opts)
        (ui/result {:conn conn
                    :resp (raw-eval opts)})))))

(defn completions [prefix]
  (let [;; Context for Compliment to complete local bindings.
        ;; We read the surrounding top level form from the current buffer
        ;; and add the __prefix__ symbol.
        context (when-let [{:keys [form cursor]} (nvim/read-form {:root? true, :win (:win nvim/ctx)})]
                  (-> (str/split-lines form)
                      (update (dec (first cursor))
                              #(util/splice %
                                            (- (second cursor) (count prefix))
                                            (second cursor)
                                            "__prefix__"))
                      (util/join-lines)))]
    (->> (current-conns {:passive? true})
         (mapcat
           (fn [conn]
             (log/trace "Finding completions for" (str "\"" prefix "\"")
                        "in" (:path nvim/ctx))
             (some-> (not-exception
                       {:conn conn
                        :resp (wrapped-eval
                                {:conn conn
                                 :code (code/completions-str
                                         {:conn conn
                                          :prefix prefix
                                          :context context
                                          :ns (:ns nvim/ctx)})})})
                     (get :val)
                     (util/parse-code)
                     (->> (map
                            (fn [{:keys [candidate type ns package doc arglists]}]
                              (let [ns+args (when arglists
                                              (str ns " (" (str/join " " arglists) ")"))
                                    menu (or ns+args ns package)]
                                (util/kw->snake-map
                                  (cond-> {:word candidate
                                           :kind (util/safe-subs (name type) 0 1)}
                                    menu (assoc :menu menu)
                                    doc (assoc :info doc))))))))))
         (dedupe))))

(defn definition [name]
  (let [lookup (fn [conn]
                 (some-> (not-exception
                           {:conn conn
                            :resp (wrapped-eval
                                    {:conn conn
                                     :code (code/definition-str
                                             {:conn conn
                                              :name name})})
                            :msg (str "Failed to look up definition for " name)})
                         (get :val)
                         (util/parse-code)))
        coord (some lookup (current-conns))]
    (if (vector? coord)
      (nvim/edit-at coord)
      (do
        (log/warn "Non-vector definition result:" coord)
        (nvim/definition)))))

(defn run-tests [targets]
  (let [{:keys [ns]} nvim/ctx
        other-ns (if (str/ends-with? ns "-test")
                   (str/replace ns #"-test$" "")
                   (str ns "-test"))]
    (doseq [conn (current-conns)]
      (when-let [result (not-exception
                          {:conn conn
                           :resp (wrapped-eval
                                   {:conn conn
                                    :code (code/run-tests-str
                                            {:conn conn
                                             :targets (if (empty? targets)
                                                        (cond-> #{ns}
                                                          (= (:lang conn) :clj) (conj other-ns))
                                                        targets)})})
                           :msg (str "Failed to run tests for " (pr-str targets))})]
        (ui/test* {:conn conn
                   :resp (update result :val util/parse-code)})))))

(defn run-all-tests [re]
  (doseq [conn (current-conns)]
    (when-let [result (not-exception
                        {:conn conn
                         :resp (wrapped-eval
                                 {:conn conn
                                  :code (code/run-all-tests-str {:re re, :conn conn})})
                         :msg (str "Failed to run tests for " (pr-str re))})]
      (ui/test* {:conn conn
                 :resp (update result :val util/parse-code)}))))

(defn refresh [op]
  (doseq [conn (current-conns)]
    (when-let [code (code/refresh-str {:conn conn, :op op})]
      (ui/refresh {:conn conn, :op op})
      (ui/result {:conn conn
                  :resp (wrapped-eval
                          {:conn conn
                           :code code})}))))
