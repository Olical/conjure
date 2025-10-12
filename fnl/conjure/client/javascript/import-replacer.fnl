(local {: autoload : define } (require :conjure.nfnl.module))
(local tsc (autoload :conjure.client.javascript.ts-common))
(local text (autoload :conjure.text))

(local M (define :conjure.client.javascript.import-replacer))

(fn parse-import-source [node code]
  (let [source-node (tsc.get-child node "source")
        source-text (and source-node (tsc.get-text source-node code))
        source-path (and source-text
                         (string.match source-text "^['\"`](.+)['\"`]$"))
        resolved-path (and source-path (tsc.resolve-path source-path))]

    {:text source-text
     :path source-path
     :resolved-path resolved-path}))

(fn is-type-import? [node code]
  (let [first-child (node:child 0)
        second-child (node:child 1)
        contains-type (string.find (tsc.get-text second-child code) "type")]
    (or (and first-child
         (= (tsc.get-text first-child code) "import")
         second-child
         (= (tsc.get-text second-child code) "type"))
        contains-type)))

(fn clean-named-imports [node code]
  (let [text (tsc.get-text node code)]
    (-> text
        (string.gsub "^{%s*" "")
        (string.gsub "%s*}$" "")
        tsc.transform-as-syntax)))

(fn transform-type-import [node code source]
  (if (and source.resolved-path source.text)
      (-> (tsc.get-text node code)
          (string.gsub (vim.pesc source.text)
                       (string.format "\"%s\"" source.resolved-path))
          (.. ";"))
      (tsc.get-text node code)))

(fn transform-plain-import [source]
  (when source.resolved-path
      (string.format "require(\"%s\");" source.resolved-path)))

;; Namespace import: import * as name from "module"
(fn transform-namespace-import [namespace-import code source]
  (when source.resolved-path
    (let [ident (tsc.find-child-by-type namespace-import "identifier")
          alias (tsc.get-text ident code)]
      (string.format "const %s = require(\"%s\");" alias source.resolved-path))))

;; Default import only: import name from "module"
(fn transform-default-import [default-import code source]
  (when source.resolved-path
    (let [name (tsc.get-text default-import code)]
      (string.format "const %s = require(\"%s\");" name source.resolved-path))))

;; Named imports only: import { a, b } from "module"
(fn transform-named-import [named-imports code source]
  (when source.resolved-path
    (string.format "const {%s} = require(\"%s\");"
                   (clean-named-imports named-imports code)
                   source.resolved-path)))

;; Mixed import: import defaultName, { a, b } from "module"
(fn transform-mixed-import [default-import named-imports code source]
  (let [default-name (tsc.get-text default-import code)
        clean-imports (clean-named-imports named-imports code)]
    (when source.resolved-path
        (.. (string.format "const %s = require(\"%s\");" default-name source.resolved-path)
            " "
            (string.format "const {%s} = require(\"%s\");" clean-imports source.resolved-path)))))

(fn M.import-statement [handle-statement]
     (fn [node code]
       (let [source (parse-import-source node code)
             import-clause (tsc.find-child-by-type node "import_clause")
             fallback (fn [] (handle-statement node code))]

         (if (is-type-import? node code)
             (transform-type-import node code source)

             (not import-clause)
             (or (transform-plain-import source)
                 (fallback))

             (let [default-import (tsc.find-child-by-type import-clause "identifier")
                   namespace-import (tsc.find-child-by-type import-clause "namespace_import")
                   named-imports (tsc.find-child-by-type import-clause "named_imports")]

               (if namespace-import
                   (or (transform-namespace-import namespace-import code source)
                       (fallback))

                   (and default-import (not named-imports))
                   (or (transform-default-import default-import code source)
                       (fallback))

                   (and named-imports (not default-import))
                   (or (transform-named-import named-imports code source)
                       (fallback))

                   (and default-import named-imports)
                   (or (transform-mixed-import default-import named-imports code source)
                       (fallback))

                   (fallback)))))))

(fn M.call-expression [default]
  (fn [node code]
    (let [function-node (tsc.get-child node "function")
          function-text (and function-node (tsc.get-text function-node code))
          arguments-node (tsc.get-child node "arguments")]
      (if (and (= function-text "require") arguments-node)
          (let [first-arg (and arguments-node (arguments-node:child 1))
                arg-text (and first-arg (tsc.get-text first-arg code))
                arg-path (and arg-text (string.match arg-text "^['\"`](.+)['\"`]$"))]
            (if (and arg-path (text.starts-with arg-path "."))
                (let [resolved-path (tsc.resolve-path arg-path)
                      quote-char (string.match arg-text "^(['\"`])")
                      new-arg (string.format "%s%s%s" quote-char resolved-path quote-char)]
                  (-> (tsc.get-text node code)
                      (string.gsub (vim.pesc arg-text) new-arg)))
                (default node code)))
          (default node code)))))

M
