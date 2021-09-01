;; All of Aniseed's macros in one place.
;; Can't be compiled to Lua directly.

;; Automatically loaded through require-macros for all Aniseed based evaluations.

(fn nil? [x]
  (= :nil (type x)))

(fn seq? [x]
  (not (nil? (. x 1))))

(fn str [x]
  (if (= :string (type x))
    x
    (tostring x)))

(fn sorted-each [f x]
  (let [acc []]
    (each [k v (pairs x)]
      (table.insert acc [k v]))
    (table.sort
      acc
      (fn [a b]
        (< (str (. a 1)) (str (. b 1)))))
    (each [_ [k v] (ipairs acc)]
      (f k v))))

(fn contains? [t target]
  (var seen? false)
  (each [k v (pairs t)]
    (when (= k target)
      (set seen? true)))
  seen?)

;; This marker can be used by a post-processor to delete a useless byproduct line.
(local delete-marker :ANISEED_DELETE_ME)

;; And this one replaces the given block with *module*!
(local replace-marker :ANISEED_REPLACE_ME)

;; We store all locals under this for later splatting.
(local locals-key :_LOCALS)

;; Various symbols we want to use multiple times.
;; Avoids the compiler complaining that we're introducing locals without gensym.
(local mod-name-sym (sym :*module-name*))
(local mod-sym (sym :*module*))
(local mod-locals-sym (sym :*module-locals*))
(local autoload-sym (sym :autoload))

;; Upserts the existence of the module for subsequent def forms and expands the
;; bound function calls into the current context.
;;
;; On subsequent interactive calls it will expand the existing module into your
;; current context. This should be used by Conjure as you enter a buffer.
;;
;; (module foo
;;   {require {nvim aniseed.nvim}}
;;   {:some-optional-base :table-of-things
;;    :to-base :the-module-off-of})
;;
;; (module foo) ;; expands foo into your current context
(fn module [mod-name mod-fns mod-base]
  (let [;; So we can check for existing values and know if we're in an interactive eval.
        ;; If the module doesn't exist we're compiling and can skip interactive tooling.
        existing-mod (. package.loaded (tostring mod-name))

        ;; The final result table that gets returned from the macro.
        ;; This is the best way I've found to introduce many (local ...) forms from one macro.
        result `[,(if existing-mod
                    replace-marker
                    delete-marker)

                 ;; We can't refer to things like (local (foo bar) (10 foo)).
                 ;; So we need to define them in an earlier local.
                 (local ,mod-name-sym ,(tostring mod-name))

                 ;; Only expose the module table if it doesn't exist yet.
                 (local ,mod-sym ,(if existing-mod
                                    `(. package.loaded ,mod-name-sym)
                                    `(do
                                       (tset package.loaded ,mod-name-sym ,(or mod-base {}))
                                       (. package.loaded ,mod-name-sym))))

                 ;; As we def values we insert them into locals.
                 ;; This table is then expanded in subsequent interactive evals.
                 (local ,mod-locals-sym ,(if existing-mod
                                           `(. ,mod-sym ,locals-key)
                                           `(do
                                              (tset ,mod-sym ,locals-key {})
                                              (. ,mod-sym ,locals-key))))]

        ;; Bindings that are returned from the macro.
        ;; (=> :some-symbol :some-value)
        keys []
        vals []
        => (fn [k v]
             (table.insert keys (sym k))
             (table.insert vals v))]

    ;; For each function / value pair...
    (when mod-fns
      (sorted-each
        (fn [mod-fn args]
          (if (seq? args)
            ;; If it's sequential, we execute the fn for side effects.
            (each [_ arg (ipairs args)]
              (=> :_ `(,mod-fn ,(tostring arg))))

            ;; Otherwise we need to bind the execution to a name.
            (sorted-each
              (fn [bind arg]
                (=> (tostring bind) `(,mod-fn ,(tostring arg))))
              args)))
         mod-fns)

      ;; Only require autoload if it's used.
      (when (contains? mod-fns autoload-sym)
        (table.insert result `(local ,autoload-sym (. (require :aniseed.autoload) :autoload)))))

    ;; When we have some keys insert the key/vals pairs locals.
    ;; If this is empty we end up generating invalid Lua.
    (when (seq? keys)
      (table.insert result `(local ,(list (unpack keys)) (values ,(unpack vals))))

      ;; We also bind these exposed locals into *module-locals* for future splatting.
      (each [_ k (ipairs keys)]
        (table.insert result `(tset ,mod-locals-sym ,(tostring k) ,k))))

    ;; Now we can expand any existing locals into the current scope.
    ;; Since this will only happen in interactive evals we can generate messy code.
    (when existing-mod
      ;; Expand exported values into the current scope, except _LOCALS.
      (sorted-each
        (fn [k v]
          (when (not= k locals-key)
            (table.insert result `(local ,(sym k) (. ,mod-sym ,k)))))
        existing-mod)

      ;; Expand locals into the current scope.
      (when existing-mod._LOCALS
        (sorted-each
          (fn [k v]
            (table.insert result `(local ,(sym k) (. ,mod-locals-sym ,k))))
          existing-mod._LOCALS)))

    result))

(fn def- [name value]
  `[,delete-marker
    (local ,name ,value)
    (tset ,mod-locals-sym ,(tostring name) ,name)])

(fn def [name value]
  `[,delete-marker
    (local ,name ,value)
    (tset ,mod-sym ,(tostring name) ,name)])

(fn defn- [name ...]
  `[,delete-marker
    (fn ,name ,...)
    (tset ,mod-locals-sym ,(tostring name) ,name)])

(fn defn [name ...]
  `[,delete-marker
    (fn ,name ,...)
    (tset ,mod-sym ,(tostring name) ,name)])

(fn defonce- [name value]
  `(def- ,name (or ,name ,value)))

(fn defonce [name value]
  `(def ,name (or ,name ,value)))

(fn deftest [name ...]
  `(let [tests# (or (. ,mod-sym :_TESTS) {})]
     (tset tests# ,(tostring name) (fn [,(sym :t)] ,...))
     (tset ,mod-sym :_TESTS tests#)))

(fn time [...]
  `(let [start# (vim.loop.hrtime)
         result# (do ,...)
         end# (vim.loop.hrtime)]
     (print (.. "Elapsed time: " (/ (- end# start#) 1000000) " msecs"))
     result#))

{:module module
 :def- def- :def def
 :defn- defn- :defn defn
 :defonce- defonce- :defonce defonce
 :deftest deftest
 :time time}
