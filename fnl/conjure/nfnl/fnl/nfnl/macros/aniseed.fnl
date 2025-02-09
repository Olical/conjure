;; [nfnl-macro]

;; Copied over from Aniseed. Contains all of the def* module macro systems.
;; https://github.com/Olical/aniseed

;; This has been heavily slimmed down from the original implementation, the
;; `(module ...) macro can now ONLY define your module, it can not be used
;; to require dependencies.

;; We had to slim things down because the Fennel compiler no longer supports
;; the weird tricks we were using.

;; In nfnl they are not automatically required, you must use import-macros to
;; require them explicitly when migrating your Aniseed based projects.

;; Avoids the compiler complaining that we're introducing locals without gensym.
(local mod-str :*module*)
(local mod-sym (sym mod-str))

;; Upserts the existence of the module for subsequent def forms.
;;
;; (module foo
;;   {:some-optional-base :table-of-things
;;    :to-base :the-module-off-of})
(fn module [mod-name mod-base]
  `(local
     ,mod-sym
     (let [pkg# (require :package)]
       (tset pkg#.loaded ,(tostring mod-name) ,(or mod-base {}))
       (. pkg#.loaded ,(tostring mod-name)))))

(fn def- [name value]
  `(local ,name ,value))

(fn def [name value]
  `(local ,name (do (tset ,mod-sym ,(tostring name) ,value) (. ,mod-sym ,(tostring name)))))

(fn defn- [name ...]
  `(fn ,name ,...))

(fn defn [name ...]
  `(def ,name (fn ,name ,...)))

(fn defonce- [name value]
  `(def- ,name (or ,name ,value)))

(fn defonce [name value]
  `(def ,name (or (. ,mod-sym ,(tostring name)) ,value)))

{:module module
 :def- def- :def def
 :defn- defn- :defn defn
 :defonce- defonce- :defonce defonce}
