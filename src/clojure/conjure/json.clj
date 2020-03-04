(ns conjure.json
  (:require [jsonista.core :as json])
  (:import (com.fasterxml.jackson.core JsonParser$Feature)))

;; Used to read and write JSON values.
;; Need to do some weird Java stuff to prevent the JSON parser closing the socket.
(def json-mapper
  (doto (json/object-mapper)
    (-> (.getFactory) (.disable JsonParser$Feature/AUTO_CLOSE_SOURCE))))

(defn decode [o]
  (json/read-value o json-mapper))

(defn encode [o]
  (json/write-value-as-string o json-mapper))
