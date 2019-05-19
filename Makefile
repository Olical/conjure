.PHONY: compile
	
SOURCES := $(shell find src -type f)

classes: deps.edn $(SOURCES)
	rm -rf classes
	mkdir classes
	clojure -Sforce -A:tools:compile

compile: classes
