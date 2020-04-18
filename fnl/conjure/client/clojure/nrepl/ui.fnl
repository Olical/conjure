(module conjure.client.clojure.nrepl.ui
  {require {client conjure.client
            log conjure.log
            text conjure.text
            str conjure.aniseed.string
            a conjure.aniseed.core
            state conjure.client.clojure.nrepl.state}})

(defn display [lines opts]
  (client.with-filetype :clojure log.append lines opts))

(defn display-result [resp opts]
  (local opts (or opts {}))
  (display
    (if
      resp.out
      (text.prefixed-lines
        resp.out
        (if
          opts.simple-out? "; "
          opts.raw-out? ""
          "; (out) "))

      resp.err
      (text.prefixed-lines resp.err "; (err) ")

      resp.value
      (when (not (and opts.ignore-nil? (= "nil" resp.value)))
        (text.split-lines resp.value))

      nil)))

(defn- flatten-test-results [results]
  (->> results
       (a.vals)
       (a.map a.vals)
       (unpack)
       (a.concat)
       (unpack)
       (a.concat)))

(defn display-test-result [{: results : summary}]
  "Abandon all hope ye who enter here."
  (display
    (if results
      (a.concat
        (->> (flatten-test-results results)
             (a.filter #(not= :pass (a.get $1 :type)))
             (a.map
               (fn [{: context : ns :type status :var name
                     : actual : expected : message
                     : file : line
                     :error err}]
                 (a.concat
                   [(str.join ["; [" ns "/" name "] " (string.upper status)
                               (when (not (a.empty? context))
                                 (.. " (" (text.left-sample context 32) ")"))
                               " " file ":"
                               line])]
                   (when (not (a.empty? message))
                     (text.prefixed-lines message "; "))
                   (if
                     err (text.prefixed-lines err "; ")

                     (not= expected actual)
                     (a.concat
                       ["; Expected:"]
                       (text.split-lines expected)
                       [""]
                       ["; Actual:"]
                       (text.split-lines actual)
                       [""])))))
             (unpack)
             (a.concat))
        [(.. "; [total] "
             (if (= 0 summary.fail)
               "OK"
               "FAILED")
             " "
             summary.pass "/" summary.test
             " assertions passed (" summary.var
             " tests, " summary.error " errors)")])
      ["; No results"])))

(defn display-given-sessions [sessions cb]
  (let [current (a.get-in state [:conn :session])]
    (display (a.concat [(.. "; Sessions (" (a.count sessions) "):")]
                       (a.map-indexed (fn [[idx session]]
                                        (.. ";  " idx " - " session
                                            (if (= current session)
                                              " (current)"
                                              "")))
                                      sessions))
             {:break? true})
    (when cb
      (cb sessions))))
