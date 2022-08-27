(module conjure.client.common-lisp.parser
  {autoload {a conjure.aniseed.core
             text conjure.text
             str conjure.aniseed.string
             log conjure.log}})

(defn- display-stdout [msg]
  "Simple display to log"
  (when (and (not= nil msg) (not= "" msg))
    (log.append (text.prefixed-lines msg "; "))))

(defn escape-string [in]
  "puts leading slashes infront of \\ and \"
  so that slynk can correctly interpret the results."
  (fn replace [in pat rep]
    (let [(s c) (string.gsub in pat rep)] s))
  (-> in
    (replace "\\" "\\\\")
    (replace "\"" "\\\"")))
    
(defn wrap-message [msg]
  "if we have a message, escape it and wrap it in quotation marks"
  (when (not (a.nil? msg))
    (str.join [ "\"" (escape-string msg) "\""])))

(defn wrap-message-or-nil [msg]
  "Wrap a message as above, but return a nil string if it is nil"
  (if (a.nil? msg)
    :nil
    (wrap-message msg)))

(defn- string-stream [str]
  "Convert a string into a byte-value iterator"
  (var index 1)
  (fn []
    (let [r (str:byte index)]
      (set index (+ index 1))
      r)))

(defn parse-string-to-nested-list [string-to-parse]
  "
  take a string'd form, such as '(:return (:ok (blah)) 1)'
  and return it as a fennel list: [:return [:ok ['blah']] 1]

  Note that there is no string parsing, so (1) is ['1']
  "
  (var return-val []) 
  ;; a list of tables that we are adding data to
  (var stack [return-val]) 
  ;; the currently read element
  (var word []) 
  ;; state variables
  (var opened-quote false)
  (var escaped false)

  ;; Processing functions 
  (fn get-stack []
    (. stack (length stack)))

  (fn add-to-word [b]
    (table.insert word b)
    (set escaped false))
   
  (fn slash-escape [b]
    (if escaped
      (add-to-word b)
      (set escaped true)))

  (fn insert-word-and-clear []  
    (set opened-quote false)
    (table.insert (get-stack) (string.char (unpack word)))
    (set word []))

  (fn finish-word []
    (when (not (a.empty? word))
      (insert-word-and-clear)))

  (fn process-whitespace [b]
    (if opened-quote
      (add-to-word b)
      (finish-word)))

  (fn open-close-quote [b]
    "we have a quote byte that we track strings on"
    (if escaped
      (add-to-word b)
      (if opened-quote
        (insert-word-and-clear)
        (set opened-quote true))))

  (fn open-paren [b]
    "when given an open paren, push a new list and point stack to that"
    (if opened-quote
      (add-to-word b)
      (let [ new-table []]
        (table.insert (get-stack) new-table)
        (table.insert stack new-table))))

  (fn close-paren [b]
    "when given close paren, finish word, pop stack"
    (if opened-quote
      (add-to-word b)
      (when (> (length stack) 1)
        (finish-word)
        (table.remove stack))))

  (let [slash-byte (string.byte "\\")
        quote-byte (string.byte "\"")
        paren-open (string.byte "(")
        paren-close (string.byte ")")
        space-byte (string.byte " ")
        tab-byte   (string.byte "\t")
        newline-byte (string.byte "\n")]
    (each [b (string-stream string-to-parse)]
       (match b
          slash-byte (slash-escape b)
          quote-byte (open-close-quote b)
          ; parens!
          paren-open (open-paren b)
          paren-close (close-paren b)
          ; whitespace should finish word
          space-byte (process-whitespace b)
          tab-byte (process-whitespace b)
          newline-byte (process-whitespace b)
          ; everything else is inserted
          _          (add-to-word b))))
  (finish-word)
  return-val)

(defn- get-return-value [table]
  (let [ [[res [stdout valu]] eval-id] table]
    (values stdout valu)))

(defn- display-error [rest]
  (let [ [eval-id b err & rest] rest]
    (display-stdout (str.join "\n" err))))

(defn parse-result [received]
  (let [[return & rest] 
        (unpack (parse-string-to-nested-list received))]
    (match return
      ":return" (get-return-value rest)
      ":debug"  (display-error rest)
      _ (display-stdout (.. "Unsure how to parse " return)))))
                    
