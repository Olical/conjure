;; Sample snd/s7 code
;;
;;--------------------------------------------------------------------------------
;; NOTES:
;;
;;   1. This was tested with version 23.5 of snd downloaded from Sourceforge and
;;      compiled on a Macbook Air 13-inch Early 2015 running Monterey (12.6.7).
;;      snd program is compiled without a GUI (--without-gui).
;;
;;      **********************************************************************
;;      *** Unfortunately, it doesn't accept multi-line input being sent   ***
;;      *** to it from Conjure.                                            ***
;;      **********************************************************************
;;
;;   2. Setting command to "snd" or "snd -noinit" doesn't make a difference in
;;      the snd REPL accepting multi-line input.
;;
;;      - On the Neovim command line:
;;          :let g:conjure#client#snd#stdio#command="snd -noinit"
;;          :echo g:conjure#client#snd#stdio#command
;;
;;   3. Setting command to "snd -noinit" results in no return value from the
;;      REPL.
;;
;;   4. Turn on debugging to see what's being sent to and received from the snd
;;      REPL.
;;
;;      - On the Neovim command line:
;;          :let g:conjure#debug=v:true
;;          :echo g:conjure#debug
;;      
;;--------------------------------------------------------------------------------

;; From https://github.com/Olical/conjure/issues/507
;;  - @kflak (Kenneth Flak) 06/24/2023
;;  Changed to use test.snd.
;;  - This doesn't work because the snd/s7 REPL that this was originally tested
;;    with. See the NOTES above.
(begin
  (open-sound "test.snd")
  (scale-channel 0.1)
  (save-sound-as "test-scaled.wav"))

;; Start here and evaluated in order.
;;   1. Create a sound consisting of two violin tones and save in "test.snd" file.
;;      test.snd will be overwritten each time that you evaluate this form.
;;      From "clm-load" section of https://ccrma.stanford.edu/software/snd/snd/sndscm.html
(with-sound () (fm-violin 0 1 440 .1) (fm-violin 1 1 660 .1)) ;=> "test.snd"
(play 0) ;; I think this is 0.
(play)   ;; What sound instance does this play? Seems like the last one loaded
         ;; or created; not played.

;;   2. The value passed to scale-channel determines the volume of the sound.
(begin (open-sound "test.snd") (scale-channel 1.5) (save-sound-as "test-scaled.wav"))
(play 1) ;; test-scaled.wav is 1.
(open-sound "test-scaled.wav")
(play 2) ;; should be 2.

(scale-channel 2.0) ;; This makes the previous sound (#2) lounder.
(play 2) ;; check it out

;;   3. Load some other sounds.
;;      This assumes that you started Neovim in the clone of the Conjure repo
;;      on the branch that this is on.
(open-sound "dev/snd-s7/one-tone.snd")
(play 3)

(open-sound "dev/snd-s7/three-tone.snd")
(play 4)

