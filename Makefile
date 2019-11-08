.PHONY: test prepls dev depot fennel

test:
	./bin/kaocha

prepls:
	clj -A:dev:cljs \
		-J-Dclojure.server.jvm="{:port 5555 :accept clojure.core.server/io-prepl}" \
		-J-Dclojure.server.node="{:port 5556 :accept cljs.server.node/prepl}" \
		-J-Dclojure.server.browser="{:port 5557 :accept cljs.server.browser/prepl}"

dev:
	CONJURE_LOG_PATH=logs/conjure.log \
	CONJURE_PREPL_SERVER_PORT=5885 \
	CONJURE_JOB_OPTS="-A:dev" \
	CONJURE_ALLOWED_DIR="$(shell pwd)" \
	nvim -S dev/load.vim

depot:
	clojure -A:depot -m depot.outdated.main -a test,cljs,dev,depot

fennel:
	mkdir -p tools
	if [ ! -d tools/fennel ]; then  git clone https://github.com/bakpakin/Fennel.git tools/fennel; fi
	cd tools/fennel && git fetch && git checkout 0.3.0
	tools/fennel/fennel -e '(print "Success!")'
	@echo "If that doesn't look okay, make sure you have a Lua interpretor installed."
