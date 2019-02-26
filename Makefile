.PHONY: build nvim dev test-prepls

SRC_FILES = $(shell find src -type f -name '*')

build: rplugin/node/conjure.js

rplugin/node/conjure.js: deps.edn compile-opts.edn $(SRC_FILES)
	clojure --main cljs.main --compile-opts compile-opts.edn --compile conjure.main
	nvim +UpdateRemotePlugins +q

nvim:
	mkdir -p logs
	NVIM_LISTEN_ADDRESS=/tmp/conjure-nvim NVIM_NODE_LOG_FILE=logs/node.log nvim

dev:
	npm install
	(echo "(require 'conjure.dev) (conjure.dev/connect!)" && cat) |\
		NVIM_LISTEN_ADDRESS=/tmp/conjure-nvim\
		clj -Adev\
		-J-Dclojure.server.dev="{:port 5885, :accept cljs.server.node/prepl, :args [{:env-opts {:port 5895}}]}"\
		--main tubular.core --port 5885

test-prepls:
	clj -Atest\
		-J-Dclojure.server.jvm="{:port 5555, :accept clojure.core.server/io-prepl}" \
		-J-Dclojure.server.node="{:port 5556, :accept cljs.server.node/prepl, :args [{:env-opts {:port 5576}}]}"\
		-J-Dclojure.server.browser="{:port 5557, :accept cljs.server.browser/prepl}"
