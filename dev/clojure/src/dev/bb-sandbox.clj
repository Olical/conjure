(ns bb-sandbox)

(def test-vector [1 2 3])
;; This should obviously work
(nth test-vector 2)
;; This should obviously not work
(nth test-vector 3)
