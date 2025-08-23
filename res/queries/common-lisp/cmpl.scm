(defun_header
    function_name: ((sym_lit) @global.define)*)
@local.scope

(defun_header
  lambda_list:
  (list_lit
    (sym_lit) @local.define
    (#not-lua-match? @local.define "^&.*")
    (#not-lua-match? @local.define "^_$")))
@local.scope

(defun_header
  lambda_list:
  (list_lit
    (list_lit
      (sym_lit) @local.define
      (#not-lua-match? @local.define "^&.*")
      (#not-lua-match? @local.define "^_$"))))
@local.scope

(defun) @local.scope

(list_lit
  .
  [(sym_lit) @_defvar
   (package_lit
    package: _ @_pkg
    symbol: _ @_defvar)]
  .
  (sym_lit) @global.define
  (#eq? @_pkg "cl")
  (#any-of? @_defvar "defvar" "defparameter" "defconstant"))
@local.scope

(list_lit
  .
  [(sym_lit) @_def
   (package_lit
    package: _ @_pkg
    symbol: _ @_def)]
  .
  (sym_lit) @global.define
  ((sym_lit) @local.bind
             (#not-lua-match? @local.bind "^&.*")
             (#not-lua-match? @local.bind "^_$"))
  (#eq? @_pkg "cl")
  (#any-of? @_def "defsetf"))
@local.scope

(list_lit
  .
  [(sym_lit) @_def
   (package_lit
    package: _ @_pkg
    symbol: _ @_def)]
  .
  (sym_lit) @global.define
  (_)*
  (list_lit
    (sym_lit) @local.bind
    (#not-lua-match? @local.bind "^&.*")
    (#not-lua-match? @local.bind "^_$"))
  (#eq? @_pkg "cl")
  (#any-of? @_def "defsetf"))
@local.scope

(list_lit
  .
  [(sym_lit) @_deftest
   (package_lit
    package: _ @_pkg
    symbol: _ @_deftest)]
  .
  (sym_lit) @global.define
  (#eq? @_pkg "cl")
  (#eq? @_deftest "deftest"))
@local.scope

(for_clause
  .
  (sym_lit) @local.bind
  (#not-lua-match? @local.bind "^_$"))

(with_clause
  .
  (sym_lit) @local.bind
  (#not-lua-match? @local.bind "^_$"))

(loop_macro)
@local.scope

(list_lit
  . 
  [(sym_lit) @_d
   (package_lit
    package: _ @_pkg
    symbol: _ @_d)]
  . (list_lit . 
              (sym_lit) @local.bind
              (#not-lua-match? @local.bind "^_$"))
  (#eq? @_pkg "cl")
  (#any-of? @_d "dotimes" "dolist" "do-symbols" "do-all-symbols" "do-external-symbols"))
@local.scope

(list_lit
  . 
  [(sym_lit) @_d
   (package_lit
    package: _ @_pkg
    symbol: _ @_d)]
  . (list_lit
      (list_lit
        . (sym_lit) @local.bind
        (#not-lua-match? @local.bind "^_$")))
  (#eq? @_pkg "cl")
  (#any-of? @_d "do" "do*"))
@local.scope

(list_lit
  . 
  [(sym_lit) @_db
   (package_lit
    package: _ @_pkg
    symbol: _ @_db)]
  . (list_lit 
      (sym_lit) @local.bind
      (#not-lua-match? @local.bind "^&.*")
      (#not-lua-match? @local.bind "^_$"))
  (#eq? @_pkg "cl")
  (#any-of? @_db "destructuring-bind" "multiple-value-bind"))
@local.scope

(list_lit
  . 
  [(sym_lit) @_db
   (package_lit
    package: _ @_pkg
    symbol: _ @_db)]
  . (list_lit
      (list_lit
        . (sym_lit) @local.bind
      (#not-lua-match? @local.bind "^&.*")
      (#not-lua-match? @local.bind "^_$")))
  (#eq? @_pkg "cl")
  (#any-of? @_db "destructuring-bind" "multiple-value-bind"))
@local.scope

(list_lit
  . 
  [(sym_lit) @_db
   (package_lit
    package: _ @_pkg
    symbol: _ @_db)]
  . (list_lit
      (list_lit
        (list_lit
          (sym_lit) @local.bind
          (#not-lua-match? @local.bind "^&.*")
          (#not-lua-match? @local.bind "^_$"))))
  (#eq? @_pkg "cl")
  (#any-of? @_db "destructuring-bind" "multiple-value-bind"))
@local.scope

(list_lit
  . 
  [(sym_lit) @_l
   (package_lit
    package: _ @_pkg
    symbol: _ @_l)]
  . (list_lit
      (list_lit . 
                (sym_lit) @local.bind
                (#not-lua-match? @local.bind "^_$")))
  (#eq? @_pkg "cl")
  (#any-of? @_l "let" "let*"))
@local.scope

(list_lit
  . 
  [(sym_lit) @_l
   (package_lit
    package: _ @_pkg
    symbol: _ @_l)]
  . (list_lit
      (list_lit 
        . (sym_lit) @local.define
        . (list_lit (sym_lit) @local.bind)
        (#not-lua-match? @local.bind "^&.*")
        (#not-lua-match? @local.bind "^_$"))
      @local.scope)
  (#eq? @_pkg "cl")
  (#any-of? @_l "flet" "labels" "macrolet"))
@local.scope

(list_lit
  . 
  [(sym_lit) @_dc
   (package_lit
    package: _ @_pkg
    symbol: _ @_dc)]
  . (sym_lit) @global.define
  (#eq? @_pkg "cl")
  (#any-of? @_dc "defclass" "defstruct" "deftype" "define-compiler-macro" "define-modify-macro" "define-setf-expander" "defpackage"))
@local.scope

(list_lit
  . 
  [(sym_lit) @_dc
   (package_lit
    package: _ @_pkg
    symbol: _ @_dc)]
  . (sym_lit)
  . (list_lit)
  . (list_lit 
      (list_lit))
  (#eq? @_pkg "cl")
  (#eq? @_dc "defclass"))
@local.scope

(list_lit
  . 
  [(sym_lit) @_ds
   (package_lit
    package: _ @_pkg
    symbol: _ @_ds)]
  . (sym_lit) 
  (#eq? @_pkg "cl")
  (#eq? @_ds "defstruct"))
@local.scope

(list_lit
  . 
  [(sym_lit) @_d
   (package_lit
    package: _ @_pkg
    symbol: _ @_d)]
  (list_lit
    (sym_lit) @local.bind
    (#not-lua-match? @local.bind "^&.*")
    (#not-lua-match? @local.bind "^_$"))
  (#eq? @_pkg "cl")
  (#any-of? @_d "deftype" "define-compiler-macro" "define-modify-macro" "define-setf-expander"))
@local.scope


