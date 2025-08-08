(defun_header
    function_name: ((sym_lit) @global.define)*)
@local.scope

(defun_header
  lambda_list:
  (list_lit
    (sym_lit) @local.define
    (#not-lua-match? @local.define "^&.*")))
@local.scope

(defun_header
  lambda_list:
  (list_lit
    (list_lit
      (sym_lit) @local.define
      (#not-lua-match? @local.define "^&.*"))))
@local.scope

(defun) @local.scope

(list_lit
  .
  (sym_lit) @_defvar
  .
  (sym_lit) @global.define
  (#any-of? @_defvar "defvar" "defparameter" "defconstant"))
@local.scope

(list_lit
  .
  (sym_lit) @_def
  .
  (sym_lit) @global.define
  ((sym_lit) @local.bind)*
  (list_lit
    (sym_lit) @local.bind)*
  (#any-of? @_def "defsetf"))
@local.scope

(list_lit
  .
  (sym_lit) @_deftest
  .
  (sym_lit) @global.define
  (#eq? @_deftest "deftest"))
@local.scope

(for_clause
  .
  (sym_lit) @local.bind)

(with_clause
  .
  (sym_lit) @local.bind)

(loop_macro)
@local.scope

(list_lit
  . (sym_lit) @_d
  . (list_lit . (sym_lit) @local.bind)
  (#any-of? @_d "dotimes" "dolist" "do-symbols" "do-all-symbols" "do-external-symbols"))
@local.scope

(list_lit
  . (sym_lit) @_d
  . (list_lit
      (list_lit
        . (sym_lit) @local.bind))
  (#any-of? @_d "do" "do*"))
@local.scope

(list_lit
  . (sym_lit) @_db
  . (list_lit 
      (sym_lit) @local.bind
      (#not-lua-match? @local.bind "^&.*"))
  (#any-of? @_db "destructuring-bind" "multiple-value-bind"))
@local.scope

(list_lit
  . (sym_lit) @_db
  . (list_lit
      (list_lit
        . (sym_lit) @local.bind
      (#not-lua-match? @local.bind "^&.*")))
  (#any-of? @_db "destructuring-bind" "multiple-value-bind"))
@local.scope

(list_lit
  . (sym_lit) @_db
  . (list_lit
      (list_lit
        (list_lit
         . (sym_lit) @local.bind)))
  (#any-of? @_db "destructuring-bind" "multiple-value-bind"))
@local.scope

(list_lit
  . (sym_lit) @_l
  . (list_lit
      (list_lit . (sym_lit) @local.bind))
  (#any-of? @_l "let" "let*"))
@local.scope

(list_lit
  . (sym_lit) @_l
  . (list_lit
      (list_lit 
        . (sym_lit) @local.define
        . (list_lit (sym_lit) @local.bind)
        (#not-lua-match? @local.bind "^&.*"))
      @local.scope)
  (#any-of? @_l "flet" "labels" "macrolet"))
@local.scope

(list_lit
  . (sym_lit) @_dc
  . (sym_lit) @global.define
  (#any-of? @_dc "defclass" "defstruct" "deftype" "define-compiler-macro" "define-modify-macro" "define-setf-expander" "defpackage"))
@local.scope

(list_lit
  . (sym_lit) @_dc
  . (sym_lit)
  . (list_lit)
  . (list_lit 
      (list_lit))
  (#eq? @_dc "defclass"))
@local.scope

(list_lit
  . (sym_lit) @_ds
  . (sym_lit) 
  (#eq? @_ds "defstruct"))
@local.scope

(list_lit
  . (sym_lit) @_d
  (list_lit
    (sym_lit) @local.bind
    (#not-lua-match? @local.bind "^&.*"))
  (#any-of? @_d "deftype" "define-compiler-macro" "define-modify-macro" "define-setf-expander"))
@local.scope


