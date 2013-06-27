LSC = $(patsubst src/%.ls, build/%.js, $(shell find src -name "*.ls" -type f | sort))
APP = "./build/app"

clean:
	@rm -rf build
	@echo "\033[1;33mClean done!\033[m"

build: $(LSC)
	@echo "\033[1;33mYep!\033[m"

build/%.js: src/%.ls
	@mkdir -p $(@D)
	@./node_modules/.bin/lsc -pcb $< > $@


serve_fn = fswatch ./src 'kill `pidof fswatch` &&	\
	kill `pidof node` && 											      \
	make build &&																    \
	node $(KEYS) $(1)'

serve: build
	@clear
	@echo "Start watching \033[1;33m$(shell pwd)\033[m"
	@node $(KEYS) $(APP) &
	@while true; do $(call serve_fn, $(APP)); done

.PHONY: clean build watch serve test install