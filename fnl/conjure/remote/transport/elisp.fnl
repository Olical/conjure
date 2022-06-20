(module conjure.remote.transport.elisp
  {autoload {a conjure.aniseed.core
             str conjure.aniseed.string
             text conjure.text
             stack conjure.stack}})

(defn- err [...]
  (error (str.join [*module-name* ": " ...])))

(def- symbol-char-pat "[a-zA-Z0-9_-]")
(def- number-char-pat "[0-9.-]")
(def- whitespace-char-pat "%s")

(defn- read* [cs ctxs result]
  (if (a.empty? cs)
    result
    (let [prev-cs cs
          c (a.first cs)
          cs (a.rest cs)
          ctx (stack.peek ctxs)]

      (if
        ;; Previous char was \, we just treat this character as plain text.
        ;; Even if it's a closing quote.
        (= :escaped-string ctx)
        (read* cs (stack.pop ctxs) (.. result c))

        ;; We're in a string. It ends when we hit a closing quote.
        (= :string ctx)
        (if
          ;; The string is finished.
          (= "\"" c)
          (read* cs (stack.pop ctxs) result)

          ;; We're escaping the next character.
          (= "\\" c)
          (read* cs (stack.push ctxs :escaped-string) result)

          ;; It's a character inside a string.
          (read* cs ctxs (.. result c)))

        ;; We're in a symbol, this ends at the end of the input or when we see
        ;; a non-symbol character.
        (= :symbol ctx)
        (if
          ;; It's a plain symbol character. Include it!
          (string.find c symbol-char-pat)
          (read* cs ctxs (.. result c))

          ;; Anything else closes the symbol. We step backwards once so this
          ;; unknown character can be processed.
          (read* prev-cs (stack.pop ctxs) result))

        ;; We are in a number. Keep reading until then end then parse it. This might throw!
        (= :number ctx)
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

        ;; We're not inside anything right now.
        (a.nil? ctx)
        (if
          ;; Begin a string.
          (= "\"" c)
          (read* cs (stack.push ctxs :string) "")

          ;; Begin a symbol. We'll treat these like strings too.
          (= ":" c)
          (read* cs (stack.push ctxs :symbol) "")

          ;; Drop whitespace.
          (string.find c whitespace-char-pat)
          (read* cs ctxs result)

          ;; Handle numbers. We start at the first character of the number then
          ;; keep adding characters until we hit a non-number character. At
          ;; that point we parse it.
          ;; We use the previous character for the start, this is so that the
          ;; "when do we parse the number" logic doesn't have to be repeated.
          (string.find c number-char-pat)
          (read* prev-cs (stack.push ctxs :number) "")

          ;; Handle unknown characters, just halt.
          (err "Unknown character: " c))

        ;; Catch all, stop processing if we're confused.
        (err "Unknown `ctx`: " ctx)))))

(defn read [s]
  (read* (text.chars s) [] nil))

; (read "(\"Class\" \": \" (:value \"clojure.lang.PersistentArrayMap\" 0) (:newline) \"Contents: \" (:newline) \"  \" (:value \"a\" 1) \" = \" (:value \"1\" 2) (:newline) \"  \" (:value \"b\" 3) \" = \" (:value \"2\" 4) (:newline))")

(read "  :foo-bar :baz  10 ")
