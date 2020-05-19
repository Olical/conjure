.PHONY: deps compile test

deps:
	scripts/dep.sh Olical aniseed origin/develop
	scripts/dep.sh Olical bencode origin/master

compile:
	rm -rf lua
	deps/aniseed/scripts/compile.sh
	deps/aniseed/scripts/embed.sh aniseed conjure
	cp deps/bencode/bencode.lua lua/conjure/bencode.lua

test:
	rm -rf test/lua
	deps/aniseed/scripts/test.sh
