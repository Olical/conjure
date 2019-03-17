.PHONY: dev prepls

dev:
	CONJURE_LOG_PATH=logs/conjure.log \
	CONJURE_PREPL_SERVER_PORT=5885 \
		nvim -c "source plugin/conjure.vim" src/conjure/main.clj

prepls:
	clj -Aprepls \
		-J-Dclojure.server.jvm="{:port 5555 :accept clojure.core.server/io-prepl}" \
		-J-Dclojure.server.node="{:port 5556 :accept cljs.server.node/prepl}" \
		-J-Dclojure.server.browser="{:port 5557 :accept cljs.server.browser/prepl}"

