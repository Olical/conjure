.PHONY: build nvim dev test-prepls

SRC_FILES = $(shell find src -type f -name '*')

build: rplugin/node/conjure.js

rplugin/node/conjure.js: deps.edn $(SRC_FILES)
	clojure --main cljs.main --compile-opts cljsc_opts.edn --compile conjure.main
	nvim +UpdateRemotePlugins +q

nvim:
	NVIM_NODE_LOG_FILE=logs/node.log NVIM_LISTEN_ADDRESS=/tmp/nvim nvim

dev:
	(echo "(require 'conjure.dev) (conjure.dev/connect!)" && cat) |\
		NVIM_LISTEN_ADDRESS=/tmp/nvim \
		clj -Adev\
		-J-Dclojure.server.dev="{:port 5885 :accept cljs.server.node/prepl}"\
		--eval "(clojure.core.server/remote-prepl \"127.0.0.1\" 5885 *in* prn :valf identity)"

test-prepls:
	clj -Atest\
		-J-Dclojure.server.jvm="{:port 5555 :accept clojure.core.server/io-prepl}" \
		-J-Dclojure.server.node="{:port 5556 :accept cljs.server.node/prepl}" \
		-J-Dclojure.server.browser="{:port 5557 :accept cljs.server.browser/prepl}"
