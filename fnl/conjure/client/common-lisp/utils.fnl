(module conjure.client.common-lisp.utils
  {autoload {a conjure.aniseed.core
             nvim conjure.aniseed.nvim
             bridge conjure.bridge
             mapping conjure.mapping
             text conjure.text
             log conjure.log
             str conjure.aniseed.string
             config conjure.config
             client conjure.client
             remote conjure.remote.swank}})

;;;; Common-lisp parser-utils
;;;; various functions mainly dealing with parsing the
;;;; string messages from swank/slynk into proper common
;;;; lisp forms.

(defn- string-stream [str]
  "Convert a string into a byte-value iterator"
  (var index 1)
  (fn []
    (let [r (str:byte index)]
      (set index (+ index 1))
      r)))

(defn- display-stdout [msg]
  "Displays the given `msg` on the log with comment-prefix"
  (when (and (not= nil msg) (not= "" msg))
    (log.append (text.prefixed-lines msg comment-prefix))))


(defn- inner-results [received]
  "A string of '(:return (:ok (blah)) 1)' should just give us the blah"
  ;; this is super hacky, but it seems to work, so we're going with it
  ;; until something better comes along.

  ;; TODO don't do this:
  (local search-string "(:return (:ok (")
  (local tail-size 5) ;; TODO: once we fix up the increments, this will change
  (let [(idx len) (string.find received search-string 1 true)]
    (string.sub received
                (+ idx len)
                (- (string.len received) tail-size))))

(defn- parse-separated-list [string-to-parse]
  "Take a string of quoted components and return an array of those values,
  ie: (I'm using single instead of double quotes in the example for ease)

  'this is' not the 'the\' output'
  => ['this is' 'the\' output'] (length of 2)

  We must be able to correctly deal with escaped values.
  This is the form that SWANK gives us, along the lines of:
      (:return (:ok ('stdout-things' 'results-of-eval')) 1)
  "
  (var opened-quote nil)
  (var escaped false)
  (var stack [])
  (var vals [])

  (local slash-byte (string.byte "\\"))
  (local quote-byte (string.byte "\""))

  (fn maybe-insert [b]
    "insert the value, and reset the escape flag"
    (when opened-quote
      (table.insert stack b)
      (set escaped false)))

  (fn maybe-close [b]
    "When we reach a quote, we could be starting/stopping
    a value, or we could have escaped this byte, etc"
    (if opened-quote
      (do
        (when (not escaped)
          ; move the entire stack into vals and clear
          (set opened-quote false)
          (table.insert
            vals
            (string.char
              (unpack stack)))
          (set stack []))
        (when escaped
          ;; if we've escaped this quote, put it in.
          (maybe-insert b)))
      (do
        (when escaped
          (log.dbg "Received an escaped quote outside of expected values"))
        (set opened-quote true))))

  (fn slash-escape [b]
    "process a \\ value, which could be escaped or escaping something else"
    (if escaped
      (maybe-insert b)
      (set escaped true)))

  (fn dispatch [b]
    "process each byte that comes in"
    (match b
      slash-byte (slash-escape b)
      quote-byte (maybe-close b)
      _ (maybe-insert b)))

  (each [b (string-stream string-to-parse)]
    (dispatch b))
  ;;finally return vals
  vals)

(defn parse-result [received]
  "Given the form  :return  :ok  \"\" \"(1 2 \\\"3\\\" 4)\")) 1) we want)])
  to extract both
  - the stdout, which is the first delimited quoted component
  - the result, which is the second delimited quoted component

  If there has been an error, it will not look like a result, so more parsing
  will be needed"
  (fn result? [response]
    (text.starts-with response "(:return (:ok ("))

  ;; TODO - parse debug messages properly and show them in a nice way
  ;; I'm not sure what the proper conjure way is here.
  (when (not (result? received))
    ;;super hack; taking out the first quoted component and hoping it is
    ;; a nice message.
    (let [(msg) (pick-values 1 (parse-separated-list received))]
      (display-stdout (. msg 1))))

  (when (result? received)
    (unpack (parse-separated-list (inner-results received)))))


(defn- escape-string [in]
  "puts leading slashes infront of \\ and \"
  so that swank can correctly interpret the results."
  (fn replace [in pat rep]
    (let [(s c) (string.gsub in pat rep)] s))
  (-> in
      (replace "\\" "\\\\")
      (replace "\"" "\\\"")))
