---
author: "Guðmundur Björn Birkisson"
title: "Make a makefile make sense"
date: "2022-12-07"
description: "Digging into make one advanced makefile to see how it works."
tags:
  - make
  - shell
---

I stumbled across a makefile at work that did not make any sense to me. I had to have a sit down with a colleague, that explained what in the world was going on. Here is a snippet from that makefile:

```makefile
Q = $(if $(filter 1,$V),,@)
M = $(shell printf "\033[34;1m▶\033[0m")

BASE          = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
POETRY        = poetry

$(POETRY): ; $(info $(M) checking POETRY…)

$(BASE): | $(POETRY) ; $(info $(M) checking PROJECT…)

.venv: pyproject.toml poetry.lock | $(BASE) ; $(info $(M) retrieving dependencies…) @ ## Install python dependencies
	$Q cd $(BASE) && $(POETRY) run pip install -U pip
	$Q cd $(BASE) && $(POETRY) install --no-interaction
	@touch $@
```

Lets break this down. First couple of lines are pretty simple:

```makefile
# Q == '' unless the env variable V=1 then Q == '@'
Q = $(if $(filter 1,$V),,@)

# You can use M to print a fancy blue arrow :)
M = $(shell printf "\033[34;1m▶\033[0m")
```

Next lines are a bit more cryptic:

```makefile
# BASE just the PWD, why make this so complicated?
BASE          = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
# POETRY is just a binary name
POETRY        = poetry

$(POETRY): ; $(info $(M) checking POETRY…)
# ... Is sugar for writing ...
$(POETRY):
	$(info $(M) checking POETRY…)

$(BASE): | $(POETRY) ; $(info $(M) checking PROJECT…)
# ... Is sugar for writing ...
$(BASE): | $(POETRY)
	$(info $(M) checking PROJECT…)
```

And in case you were wondering, these lines do absolutley nothing. Maybe the author intended to do something clever in these targets, but as they stand, they are useless.

And now for the last, most interesting bit:

```makefile
.venv: pyproject.toml poetry.lock | $(BASE) ; $(info $(M) retrieving dependencies…) @ ## Install python dependencies
	$Q cd $(BASE) && $(POETRY) run pip install -U pip
	$Q cd $(BASE) && $(POETRY) install --no-interaction
	@touch $@

# ... Is sugar for writing ...

.venv: pyproject.toml poetry.lock | $(BASE)
	$(info $(M) retrieving dependencies…) @ ## Install python dependencies
	$Q cd $(BASE) && $(POETRY) run pip install -U pip
	$Q cd $(BASE) && $(POETRY) install --no-interaction
	@touch $@

```

... and breaking that down:

```makefile
# You have to types of prerequisites:
#   targets : normal-prerequisites | order-only-prerequisites
#
# Meaning that pyproject.toml and poetry.lock are normal and $(BASE) is order-only.
# Order-only prerequisites are never checked when determining if the target is out of date!
.venv: pyproject.toml poetry.lock | $(BASE)
	# Log retrieving dependencies, and do not log the comment (##)
	$(info $(M) retrieving dependencies…) @ ## Install python dependencies
	
	# If V=1 print the commands, otherwise not. And "cd $(BASE)" does nothing.
	$Q cd $(BASE) && $(POETRY) run pip install -U pip
	$Q cd $(BASE) && $(POETRY) install --no-interaction

	# Touch the .venv folder to indicate that it has been modified
	@touch $@
```
