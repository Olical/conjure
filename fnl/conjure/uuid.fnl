(module conjure.uuid)

;; Adapted from https://gist.github.com/jrus/3197011

; local random = math.random
; local function uuid()
;     local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
;     return string.gsub(template, '[xy]', function (c)
;         local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
;         return string.format('%x', v)
;     end)
; end

(math.randomseed (os.time)) 

(defn v4 []
  (string.gsub
    "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    "[xy]"
    #(string.format
       "%x"
       (or (and (= $1 "x") (math.random 0 0xf))
           (math.random 8 0xb)))))

(comment
  (v4))
