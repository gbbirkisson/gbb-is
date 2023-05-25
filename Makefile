.DEFAULT_GOAL:=help

Q = $(if $(filter 1,$V),,@)
M = $(shell printf "\033[34;1m▶\033[0m")

.PHONY:	_deps
_deps:
	$(info $(M) Check dependencies)
	$(Q) cat .tool-versions | awk '{print $$1}' | xargs -I {} asdf current {} 2>&1 | grep -oP "asdf install .*[^\"]" | xargs -I {} bash -c "set -x; {}"

.PHONY:	serve
serve: _deps ## Serve site locally
	$(info $(M) Serving website)
	$(Q) hugo serve

help: ## Show help
	$(info $(M) Makefile targets:)
	$(eval HELP_COL_WIDTH:=13)
	@grep -E '[^\s]+:.*?## .*$$' ${MAKEFILE_LIST} | grep -v grep | envsubst | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-${HELP_COL_WIDTH}s\033[0m %s\n", $$1, $$2}'
