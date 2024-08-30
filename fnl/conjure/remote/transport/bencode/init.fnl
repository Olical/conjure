(local {: autoload} (require :nfnl.module))
(local impl (autoload :conjure.remote.transport.bencode.impl))
(local a (autoload :conjure.aniseed.core))

(fn new []
  {:data ""})

(fn decode-all [bs part]
  (var progress 1)
  (var end? false)
  (let [s (.. bs.data part)
        acc []]
    (while (and (< progress (a.count s)) (not end?))
      (let [(msg consumed) (impl.decode s progress)]
        (if (a.nil? msg)
          (set end? true)
          (do
            (table.insert acc msg)
            (set progress consumed)))))
    (a.assoc bs :data (string.sub s progress))
    acc))

(fn encode [...]
  (impl.encode ...))

{: new
 : decode-all
 : encode}
