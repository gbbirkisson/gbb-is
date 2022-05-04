---
author: "Guðmundur Björn Birkisson"
title: "Makefile Help"
date: "2022-05-04"
description: "Create makefiles with documentation"
tags:
  - make
  - shell
  - template
---

I find it terrably convenient to create makefiles in my projects. Usually they are pretty small, but in some cases they grow to become quite large. A neat trick you can do is to add some rudimentary documentation to your makefiles and include a `help` target in your makefile to print those docs. I usually then assign the `help` target as the default so the docs will show when you run `make` in your project.

Here is small example of how this would look like:

```makefile
.PHONY: build test release help
.DEFAULT_GOAL:=help

export SOMEFILE := somefile.txt

${SOMEFILE}: ## Build file '${SOMEFILE}' with name defined as variable
	echo test > ${SOMEFILE}

build: ${SOMEFILE} ## Build everything

test: build ## Test something
	echo "fake test"

release: test ## Release something
	echo "fake release"

help: ## Show this help
	$(eval HELP_COL_WIDTH:=13)
	@echo "Makefile targets:"
	@grep -E '[^\s]+:.*?## .*$$' ${MAKEFILE_LIST} | grep -v grep | envsubst | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-${HELP_COL_WIDTH}s\033[0m %s\n", $$1, $$2}'
```

> **NOTE:** One thing to keep in mind, is that any variable that will show up in the help text has to be exported so `envsubst` can read it, i.e. `export SOMEFILE := somefile.txt`.

Running `make` will then output this convenient help:

```console
$ make
Makefile targets:
  somefile.txt  Build file 'somefile.txt' with name defined as variable
  build         Build everything
  test          Test something
  release       Release something
  help          Show this help
```

