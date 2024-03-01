(ql:quickload :cl-collider)

(in-package :sc-user)
(named-readtables:in-readtable :sc)

;; please check *sc-synth-program*, *sc-plugin-paths*, *sc-synthdefs-path*
;; if you have different path then set to
;;
;; (setf *sc-synth-program* "/path/to/scsynth")
;; (setf *sc-plugin-paths* (list "/path/to/plugin_path" "/path/to/extension_plugin_path"))
;; (setf *sc-synthdefs-path* "/path/to/synthdefs_path")

;; `*s*` defines the server for the entire session
;; functions may use it internally.

(setf *s* (make-external-server "localhost" :port 48800))
(server-boot *s*)

;; in Linux, maybe you need to call this function
#+linux
(jack-connect)

;; Hack music
(defvar *synth*)
(setf *synth* (play (sin-osc.ar [320 321] 0 .2)))

;; Stop music
(free *synth*)

;; Quit SuperCollider server
(server-quit *s*)
