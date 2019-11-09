(ns conjure.meta
  (:require [clojure.string :as str]
            [clojure.java.shell :as shell]))

(def version (str/trimr (:out (shell/sh "bin/conjure-version"))))
(def ns-version (str/replace version #"\." "v"))
