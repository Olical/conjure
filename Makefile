.PHONY: dev prepls clean compile
	
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

clean:
	rm -rf classes

classes: clean deps.edn $(SOURCES)
	mkdir classes
	clojure -Sforce -C:fast \
		-J-Dclojure.compiler.direct-linking=true \
		-J-Dclojure.compiler.elide-meta="[:doc :file :line :added]" \
		--eval "(compile 'conjure.main)"

compile: classes
