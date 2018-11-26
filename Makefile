jvm-prepl:
	clj -J-Dclojure.server.repl="{:port 5555 :accept clojure.core.server/io-prepl}"

node-prepl:
	clj -J-Dclojure.server.repl="{:port 6666 :accept cljs.server.node/prepl}"

browser-prepl:
	clj -J-Dclojure.server.repl="{:port 6666 :accept cljs.server.browser/prepl}"
