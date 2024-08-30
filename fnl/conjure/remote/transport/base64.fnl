;; From https://stackoverflow.com/a/35303321/455137
;; Converted to Fennel by antifennel.

(local b "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")

(fn encode [data]
  (.. (: (.. (data:gsub "."
                        (fn [x]
                          (var (r b) (values "" (x:byte)))
                          (for [i 8 1 (- 1)]
                            (set r
                                 (.. r
                                     (or (and (> (- (% b (^ 2 i))
                                                    (% b
                                                       (^ 2
                                                          (- i 1))))
                                                 0)
                                              :1)
                                         :0))))
                          r)) :0000)
         :gsub "%d%d%d?%d?%d?%d?"
         (fn [x]
           (when (< (length x) 6) (lua "return \"\""))
           (var c 0)
           (for [i 1 6]
             (set c
                  (+ c
                     (or (and (= (x:sub i i) :1) (^ 2 (- 6 i)))
                         0))))
           (b:sub (+ c 1) (+ c 1))))
      (. ["" "==" "="] (+ (% (length data) 3) 1))))

(fn decode [data]
  (set-forcibly! data (string.gsub data (.. "[^" b "=]") ""))
  (: (data:gsub "."
                (fn [x]
                  (when (= x "=") (lua "return \"\""))
                  (var (r f) (values "" (- (b:find x) 1)))
                  (for [i 6 1 (- 1)]
                    (set r
                         (.. r
                             (or (and (> (- (% f (^ 2 i))
                                            (% f
                                               (^ 2 (- i 1))))
                                         0)
                                      :1)
                                 :0))))
                  r)) :gsub
     "%d%d%d?%d?%d?%d?%d?%d?"
     (fn [x]
       (when (not= (length x) 8) (lua "return \"\""))
       (var c 0)
       (for [i 1 8]
         (set c
              (+ c
                 (or (and (= (x:sub i i) :1) (^ 2 (- 8 i)))
                     0))))
       (string.char c))))

{: encode
 : decode}
