;; All of Aniseed's macros in one place.
;; Can't be compiled to Lua directly.

;; Automatically loaded through require-macros for all Aniseed based evaluations.

(local module-sym (gensym))

(fn sorted-each [f x]
  (let [acc []]
    (each [k v (pairs x)]
      (table.insert acc [k v]))
    (table.sort
      acc
      (fn [a b]
        (< (. a 1) (. b 1))))
    (each [_ [k v] (ipairs acc)]
      (f k v))))

(fn module [name new-local-fns initial-mod]
  `(-> [(local ,module-sym
          (let [name# ,(tostring name)
                module# (let [x# (. _G.package.loaded name#)]
                          (if (= :table (type x#))
                            x#
                            ,(or initial-mod {})))]
            (tset module# :aniseed/module name#)
            (tset module# :aniseed/locals (or (. module# :aniseed/locals) {}))
            (tset module# :aniseed/local-fns (or (. module# :aniseed/local-fns) {}))
            (tset _G.package.loaded name# module#)
            module#))

        ,module-sym

        ;; Meta! Autoload the autoload function, so it's only loaded when used.
        (local ,(sym :autoload)
          (fn [...] ((. (require :aniseed.autoload) :autoload) ...)))

        ,(let [aliases []
               vals []
               effects []
               pkg (let [x (. _G.package.loaded (tostring name))]
                     (when (= :table (type x))
                       x))
               locals (-?> pkg (. :aniseed/locals))
               local-fns (or (and (not new-local-fns)
                                  (?. pkg :aniseed/local-fns))
                             {})]

           (when new-local-fns
             (each [action binds (pairs new-local-fns)]
               (let [action-str (tostring action)
                     current (or (. local-fns action-str) {})]
                 (tset local-fns action-str current)
                 (each [alias module (pairs binds)]
                   (if (= :number (type alias))
                     (tset current (tostring module) true)
                     (tset current (tostring alias) (tostring module)))))))

           (sorted-each
             (fn [action binds]
               (sorted-each
                 (fn [alias-or-val val]
                   (if (= true val)

                     ;; {require-macros [bar]}
                     (table.insert effects `(,(sym action) ,alias-or-val))

                     ;; {require {foo bar}}
                     (do
                       (table.insert aliases (sym alias-or-val))
                       (table.insert vals `(,(sym action) ,val)))))

                 binds))
             local-fns)

           (when locals
             (sorted-each
               (fn [alias val]
                 (table.insert aliases (sym alias))
                 (table.insert vals `(. ,module-sym :aniseed/locals ,alias)))
               locals))

           `[,effects
             (local ,aliases
               (let [(ok?# val#)
                     (pcall
                       (fn [] ,vals))]
                 (if ok?#
                   (do
                     (tset ,module-sym :aniseed/local-fns ,local-fns)
                     val#)
                   (print val#))))
             (local ,(sym "*module*") ,module-sym)
             (local ,(sym "*module-name*") ,(tostring name))])]
       (. 2)))

(fn def- [name value]
  `(local ,name
     (let [v# ,value
           t# (. ,module-sym :aniseed/locals)]
       (tset t# ,(tostring name) v#)
       v#)))

(fn def [name value]
  `(def- ,name
     (do
       (let [v# ,value]
         (tset ,module-sym ,(tostring name) v#)
         v#))))

(fn defn- [name ...]
  `(def- ,name (fn ,name ,...)))

(fn defn [name ...]
  `(def ,name (fn ,name ,...)))

(fn defonce- [name value]
  `(def- ,name
     (or (. ,module-sym :aniseed/locals ,(tostring name))
         ,value)))

(fn defonce [name value]
  `(def ,name
     (or (. ,module-sym ,(tostring name))
         ,value)))

(fn deftest [name ...]
  `(let [tests# (or (. ,module-sym :aniseed/tests) {})]
     (tset tests# ,(tostring name) (fn [,(sym :t)] ,...))
     (tset ,module-sym :aniseed/tests tests#)))

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
