.PHONY: compile
	
SOURCES := $(shell find src -type f)

classes: deps.edn $(SOURCES)
	rm -rf classes
	mkdir classes
	clojure -Sforce -A:tools -C:fast \
		-J-Dclojure.compiler.direct-linking=true \
		-J-Dclojure.compiler.elide-meta="[:doc :file :line :added]" \
		--main conjure.tools.compile

compile: classes
