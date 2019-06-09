(ns conjure.config
  "Tools to load all relevant  .conjure.edn files.
  They're used to manage connection configuration."
  (:require [clojure.edn :as edn]
            [clojure.string :as str]
            [clojure.spec.alpha :as s]
            [expound.alpha :as expound]
            [medley.core :as m]
            [me.raynes.fs :as fs]
            [traversy.lens :as tl]
            [conjure.ui :as ui]
            [conjure.util :as util]))

(s/def ::expr util/regexp?)
(s/def ::port number?)
(s/def ::lang #{:clj :cljs})
(s/def ::host string?)
(s/def ::tag keyword?)
(s/def ::enabled? boolean?)
(s/def ::conn (s/keys :req-un [::port ::host ::lang ::expr ::enabled?]))
(s/def ::conns (s/map-of ::tag ::conn))
(s/def ::config (s/nilable (s/keys :opt-un [::conns])))

(def ^:private default-exprs
  {:clj #"\.(cljc?|edn)$"
   :cljs #"\.(clj(s|c)|edn)$"})

(def ^:private edn-opts
  {:readers {'regex re-pattern
             'slurp-edn (comp edn/read-string slurp)}})

(defn- ^:dynamic gather
  "Gather all config files from disk and merge them together, deepest file wins."
  []
  (->> (conj (fs/parents fs/*cwd*) fs/*cwd*)
       (reverse)
       (transduce
         (comp (map #(fs/file % ".conjure.edn"))
               (filter (every-pred fs/file? fs/readable?))
               (map slurp)
               (map #(edn/read-string edn-opts %)))
         m/deep-merge)))

(defn- hydrate
  "Infer some more values from the existing config."
  [config]
  (-> config
      (tl/update (tl/*> (tl/in [:conns]) tl/all-values)
                 (fn [conn]
                   (merge {:lang :clj
                           :expr (get default-exprs (get conn :lang :clj))
                           :host "127.0.0.1"
                           :enabled? true}
                          conn)))))

(defn- validate
  "Ensure the config conforms to the ::config spec, throws."
  [config]
  (if (s/valid? ::config config)
    config
    (ui/error (str "Something's wrong with your .conjure.edn!\n"
                   (expound/expound-str ::config config)))))

(defn toggle [config flags]
  (if-let [flags (and (not (str/blank? flags))
                      (not-empty (str/split flags #"\s+")))]
    (transduce
      (comp
        (map (fn [flag]
               {:tag (keyword (subs flag 1))
                :enabled? (case (first flag)
                            \- false
                            \+ true
                            nil) }))
        (remove (comp nil? :enabled?)))
      (completing
        (fn [config {:keys [tag enabled?]}]
          (tl/update config (tl/in [:conns tag])
                     (fn [conn]
                       (assoc conn :enabled? enabled?)))))
      config
      flags)
    config))

(defn fetch
  "Gather, hydrate and validate the config."
  ([] (fetch {}))
  ([{:keys [flags] :as _opts}]
   (-> (gather)
       (hydrate)
       (toggle flags)
       (validate))))
