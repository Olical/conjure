.PHONY: prepl

prepl:
	clj -J-Dclojure.server.repl="{:port 5555 :accept clojure.core.server/io-prepl}"
