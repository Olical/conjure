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

compile:
	mkdir -p classes
	clojure -Cfast \
		-J-Dclojure.compiler.direct-linking=true \
		-J-Dclojure.compiler.elide-meta="[:doc :file :line :added]" \
		--eval " \
			(compile 'conjure.action) \
			(compile 'conjure.code) \
			(compile 'conjure.dev) \
			(compile 'conjure.main) \
			(compile 'conjure.nvim) \
			(compile 'conjure.pool) \
			(compile 'conjure.rpc) \
			(compile 'conjure.ui) \
			(compile 'conjure.util) \
		"
