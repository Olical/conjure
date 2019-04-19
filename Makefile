.PHONY: dev prepls compile test test-watch
	
dev:
	CONJURE_LOG_PATH=logs/conjure.log \
	CONJURE_PREPL_SERVER_PORT=5885 \
	CONJURE_JOB_OPTS="-A:dev" \
	CONJURE_ALLOWED_DIR="$(shell pwd)" \
		nvim -c "source plugin/conjure.vim" src/conjure/main.clj

prepls:
	clj -A:dev \
		-J-Dclojure.server.jvm="{:port 5555 :accept clojure.core.server/io-prepl}" \
		-J-Dclojure.server.node="{:port 5556 :accept cljs.server.node/prepl}" \
		-J-Dclojure.server.browser="{:port 5557 :accept cljs.server.browser/prepl}"

SOURCES := $(shell find src -type f)

classes: deps.edn $(SOURCES)
	rm -rf classes
	mkdir classes
	clojure -Sforce -C:fast \
		-J-Dclojure.compiler.direct-linking=true \
		-J-Dclojure.compiler.elide-meta="[:doc :file :line :added]" \
		--eval "(compile 'conjure.main)"

compile: classes

test:
	clojure -A:test

test-watch:
	clojure -A:test --watch
