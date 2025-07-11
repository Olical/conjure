;; Sample snd/s7 code
;;
;;--------------------------------------------------------------------------------
;; NOTES:
;;
;;   1. This was tested with version 25.5 of snd downloaded from Sourceforge and
;;      compiled on a Macbook Air 15-inch M3 2024 running Sequoia (15.5). The
;;      snd program is compiled with the defaults and includes s7 scheme and no
;;      GUI.
;;
;;   2. Running `snd` outside of the directory that it was compiled in can
;;      result in errors when evaluating some forms. A symptom of doing so is
;;      not finding the `with-sound` macro.
;;
;;      To be able to run `snd` outside of the directory where it was compiled
;;      set the SND_PATH environment variable before running Neovim with
;;      Conjure to use the snd-s7 client.
;;
;;      ```console
;;      $ export SND_PATH=~/Playground/Snd/snd-25.5
;;      ```
;;
;;--------------------------------------------------------------------------------

;; Using relative paths from the main repo directory.
;;
;; Start here and evaluated in order.
;;   1. Create a sound consisting of two violin tones and save in "test.snd" file.
;;
;;      test.snd will be overwritten each time that you evaluate this form.
;;      `.snd` files are "Sun/NeXT audio data: mono, 44100 Hz" files; not `.wav` files.
;;
;;      From "clm-load" section of https://ccrma.stanford.edu/software/snd/snd/sndscm.html
(with-sound
  ()
  (fm-violin 0 1 440 .1)  ; inline comments are removed
  (fm-violin 1 1 660 .1)) ; "test.snd"

(play 0)
(play)

;;   2. The value passed to scale-channel determines the volume of the sound.
(begin
  (open-sound "test.snd")
  (scale-channel 1.5)
  (save-sound-as "test-scaled.wav"))

(play 1)
(play)

(open-sound "test-scaled.wav") ; #<sound 2>
(play 2)

;; This makes the previous sound lounder.
(scale-channel 2.0) ; 2.0
(play)

(scale-channel 0.5) ; 0.5
(play)


;;   3. Load some other sounds.
;;
;;      This assumes that you started Neovim in the clone of the Conjure repo
;;      on the branch that this is on.
(open-sound "dev/snd-s7/one-tone.snd") ; #<sound 3>
(play 3)
(play)

(open-sound "dev/snd-s7/three-tone.snd") ; #<sound 4>
(play 4)
(play)


;;--------------------------------------------------------------------------------

;; Get info about S7 run-time.

(*s7* 'version) ; "s7 11.5, 30-June-2025"
(*s7* 'max-string-length) ; 1073741824
(*s7* 'history-size) ; 8
(*s7* 'history-enabled) ; #f
(*s7* 'print-length) ; 40
(*s7* 'cpu-time) ; 0.024151
(*s7* 'filenames) ; ("*stdout*" "*stderr*" "*stdin*"...)
(*s7* 'gc-info) ; (1 547 1000000)
(*s7* 'memory-usage)

