.PHONY: dev prepls compile
	
dev:
	CONJURE_LOG_PATH=logs/conjure.log \
	CONJURE_PREPL_SERVER_PORT=5885 \
	CONJURE_JOB_OPTS=" " \
	CONJURE_ALLOWED_DIR="$(shell pwd)" \
		nvim -c "source plugin/conjure.vim" src/conjure/main.clj

prepls:
	clj -Aprepls \
		-J-Dclojure.server.jvm="{:port 5555 :accept clojure.core.server/io-prepl}" \
		-J-Dclojure.server.node="{:port 5556 :accept cljs.server.node/prepl}" \
		-J-Dclojure.server.browser="{:port 5557 :accept cljs.server.browser/prepl}"

SOURCES := $(shell find src -type f)

classes: deps.edn $(SOURCES)
	mkdir -p classes
	rm -rf classes/*
	clojure -Cfast \
		-J-Dclojure.compiler.direct-linking=true \
		-J-Dclojure.compiler.elide-meta="[:doc :file :line :added]" \
		--eval "$(shell echo "$(SOURCES)" | scripts/compile-str.sh)"
	touch classes

compile: classes
