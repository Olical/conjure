(ns conjure.pool
  "Connection management and selection."
  (:require [clojure.spec.alpha :as s]
            [conjure.util :as util]))

(s/def ::expr util/regexp?)
(s/def ::tag keyword?)
(s/def ::port number?)
(s/def ::lang #{:clj :cljs})
(s/def ::host string?)
(s/def ::conn (s/keys :req-un [::tag ::port ::expr ::lang ::host]))
(s/def ::new-conn (s/keys :req-un [::tag ::port] :opt-un [::expr ::lang ::host]))

(defonce conns! (atom {}))
