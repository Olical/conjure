(module conjure.bencode-stream
  {require {bencode conjure.bencode
            a conjure.aniseed.core}})

(defn new []
  {:data ""})

(defn decode-all [bs part]
  (var progress 1)
  (var end? false)
  (let [s (.. bs.data part)
        acc []]
    (while (and (< progress (a.count s)) (not end?))
      (let [(msg consumed) (bencode.decode s progress)]
        (if (a.nil? msg)
          (set end? true)
          (do
            (table.insert acc msg)
            (set progress consumed)))))
    (a.assoc bs :data (string.sub s progress))
    acc))
