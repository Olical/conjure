(list 
  . (symbol) @_d
  . (list
      . (symbol) @local.define
      [
       ((symbol) @local.bind)
       (list . (symbol) @local.bind)
       (keyword)
       ]*)
  (#any-of? @_d "define" "define*" "define-syntax-rule"))
@local.scope

(list
  . (symbol) @_l
  . (list
      [
       ((symbol) @local.bind)
       (list . (symbol) @local.bind)
       (keyword)
       ]*) 
  (#any-of? @_l "lambda" "lambda*"))
@local.scope

(list
  . (symbol) @_d
  . (symbol) @local.define
  (#any-of? @_d "define" "define-syntax" "define-syntax-rule"))
@local.scope

(list
  . (symbol) @_l
  . (list
      (list . (symbol) @local.bind))
  (#any-of? @_l "let" "let*" "let-syntax" "letrec" "letrec-syntax" "with-syntax"))
@local.scope

(list
  . (symbol) @_sr
  . (list)
  . (list ; square bracket
      (list
        . (_) (symbol)* @local.bind))*
  (#eq? @_sr "syntax-rules"))
@local.scope

(list
  . (symbol) @_sr
  . (list)
  . (list ; square bracket
      (list
        . (_) (list (list . (symbol) @local.bind)))*)*
  (#eq? @_sr "syntax-rules"))
@local.scope


(list
  . (symbol) @_l
  . (list
      (list . (list (symbol) @local.bind)))
  (#any-of? @_l "let-values" "let*-values"))
@local.scope

;; named let
(list
  . (symbol) @_l
  . (symbol) @local.bind
  . (list
      (list . (symbol) @local.bind))
  (#any-of? @_l "let" "let*" "letrec"))
@local.scope

(list
  . (symbol) @_do
  . (list
      (list . (symbol) @local.bind))
  (#any-of? @_do "do"))
@local.scope

(list
  . (symbol) @_dm
  . (list (symbol) @local.define)
  (#any-of? @_dm "define-module"))
@local.scope

(list
  . (symbol) @_cl
  . (list
      (list (symbol) @local.bind)
      @local.scope)*
  (#eq? @_cl "case-lambda"))

(list
  . (symbol) @_r
  . (list
      (symbol) @local.bind)*
  (#eq? @_r "receive"))
  @local.scope

(list
  . (symbol) @_dv
  . [(list
      ((symbol) @local.define
      (#not-lua-match? @local.define "^%.$")))
     (symbol) @local.define ]
  (#eq? @_dv "define-values"))
  @local.scope

