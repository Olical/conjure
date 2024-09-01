(local {: autoload} (require :nfnl.module))
(local a (autoload :conjure.aniseed.core))
(local str (autoload :conjure.aniseed.string))
(local text (autoload :conjure.text))
(local stack (autoload :conjure.stack))

(fn err [...]
  (error (str.join [*module-name* ": " ...])))

(local symbol-char-pat "[a-zA-Z0-9_-]")
(local number-char-pat "[0-9.-]")
(local whitespace-char-pat "%s")

;; Beware, here be dragons. Really cool magic dragons, but dragons all the same.
;; Grab a coffee, put on your seat belt. Good luck.
(fn read* [cs ctxs result]
  (if (a.empty? cs)
    result
    (let [prev-cs cs
          c (a.first cs)
          cs (a.rest cs)
          {:name ctx-name
           :value ctx-value} (or (stack.peek ctxs) {})]

      (if
        ;; Are we inside a list right now? Do we have a value to work with? If
        ;; so we capture the result inside it then continue on.
        (and (= :list ctx-name) (not= nil result))
        (do
          (table.insert ctx-value result)
          (read* prev-cs ctxs nil))

        ;; Previous char was \, we just treat this character as plain text.
        ;; Even if it's a closing quote.
        (= :escaped-string ctx-name)
        (read* cs (stack.pop ctxs) (.. result c))

        ;; We're in a string. It ends when we hit a closing quote.
        (= :string ctx-name)
        (if
          ;; The string is finished.
          (= "\"" c)
          (read* cs (stack.pop ctxs) result)

          ;; We're escaping the next character.
          (= "\\" c)
          (read* cs (stack.push ctxs {:name :escaped-string}) result)

          ;; It's a character inside a string.
          (read* cs ctxs (.. result c)))

        ;; We're in a symbol, this ends at the end of the input or when we see
        ;; a non-symbol character.
        (= :symbol ctx-name)
        (if
          ;; It's a plain symbol character. Include it!
          (string.find c symbol-char-pat)
          (read* cs ctxs (.. result c))

          ;; Anything else closes the symbol. We step backwards once so this
          ;; unknown character can be processed.
          (read* prev-cs (stack.pop ctxs) result))

        ;; We are in a number. Keep reading until then end then parse it. This might throw!
        (= :number ctx-name)
        (if
          ;; Check that we're still in the number.
          (string.find c number-char-pat)
          (read*
            cs ctxs
            (let [result (.. result c)]
              ;; If we're on the last character of the input, we concat _and_ parse.
              (if (a.empty? cs)
                (tonumber result)
                result)))

          ;; As soon as we're outside of the number, do two things.
          ;;  1. Parse the number, which might throw an error!
          ;;  2. Recur onto the previous character for processing.
          (read* prev-cs (stack.pop ctxs) (tonumber result)))

        ;; If we're in a list or nothing at all, we look for more context clues for the next value.
        (or (= :list ctx-name) (a.nil? ctx-name))
        (if
          ;; Begin a string.
          (= "\"" c)
          (read* cs (stack.push ctxs {:name :string}) "")

          ;; Begin a symbol. We'll treat these like strings too.
          (= ":" c)
          (read* cs (stack.push ctxs {:name :symbol}) "")

          ;; Start a list, this is where the fun begins.
          (= "(" c)
          (read* cs (stack.push ctxs {:name :list :value []}) nil)

          ;; End a list, capture the value and pop upwards.
          (= ")" c)
          (read* cs (stack.pop ctxs) ctx-value)

          ;; Drop whitespace.
          (string.find c whitespace-char-pat)
          (read* cs ctxs result)

          ;; Handle numbers. We start at the first character of the number then
          ;; keep adding characters until we hit a non-number character. At
          ;; that point we parse it.
          ;; We use the previous character for the start, this is so that the
          ;; "when do we parse the number" logic doesn't have to be repeated.
          (string.find c number-char-pat)
          (read* prev-cs (stack.push ctxs {:name :number}) "")

          ;; Handle unknown characters, just halt.
          (err "Unknown character: " c))

        ;; Catch all, stop processing if we're confused.
        (err "Unknown `ctx`: " ctx-name)))))

(fn read [s]
  (read* (text.chars s) [] nil))

{: read}
