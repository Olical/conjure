(module conjure.client.common-lisp.parser
  {autoload {a conjure.aniseed.core
             text conjure.text
             str conjure.aniseed.string
             trn conjure.remote.transport.slynk
             log conjure.log}})

(defn display-stdout [msg]
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

(defn- get-return-value [table]
  (let [ [[res [stdout valu]] eval-id] table]
    (values stdout valu)))

(defn- display-error [rest]
  (let [ [eval-id b err & rest] rest]
    (display-stdout (str.join "\n" err))))

(defn parse-result [received]
  (let [[return & rest] 
        (unpack (trn.parse-string-to-nested-list received))]
    (match return
      ":return" (get-return-value rest)
      ":debug"  (display-error rest)
      _ (display-stdout (.. "Unsure how to parse " return)))))
                    
