---
author: "Guðmundur Björn Birkisson"
title: "Mise, Direnv and Poetry"
date: "2024-07-24"
description: "Use mise, direnv and poetry to manage your dependencies"
tags:
- shell
- development
- python
---

Both [direnv](https://direnv.net/) and [mise](https://mise.jdx.dev/) are tools that hardly need
any introduction. If they do not ring any bells I highly recommend you read up on them. They are
great at managing dependencies and general configuration for your projects. There are some
caveats though that you need to be aware of when using them together. In this post I am going to
show how I use these tools to manage python dependencies with [uv](https://docs.astral.sh/uv/),
[poetry](https://python-poetry.org/) and plain old
[pip](https://pip.pypa.io/en/stable/installation/).

<!-- vim-markdown-toc GFM -->

* [Configuring dotenv](#configuring-dotenv)
     * [use_mise.sh](#use_misesh)
     * [layout_uv.sh](#layout_uvsh)
     * [layout_poetry.sh](#layout_poetrysh)
     * [layout_pip.sh](#layout_pipsh)
* [Project with uv](#project-with-uv)
* [Projects with poetry or pip](#projects-with-poetry-or-pip)

<!-- vim-markdown-toc -->

## Configuring dotenv

I am going to start at the deep end here by going over the configuration needed for `direnv`. We
are going to create new commands that we can use in our `.envrc` files. We do that by adding
these two corresponding files in the `$HOME/.config/direnv/lib` directory.

### use_mise.sh

> Note that this is only needed if you are actually using the `.tool-versions` file in your
> project.

This script ensures that the `mise` path is correctly set in `direnv`. It also prints out any
tools that are currently missing. It is important that this command is always the first command
in our `.envrc` file.

```bash
#!/usr/bin/env bash

use_mise() {
    if ! has mise; then
        log_error "bin \`mise\` not found"
        return
    fi

    direnv_load mise direnv exec

    IFS=$'\n'
    for l in $(mise current 2>&1 | grep "not installed"); do
        log_error "$l"
    done
    unset IFS
}
```

### layout_uv.sh

This script ensures that `uv` installs required interpreters, sets up a virtual environment and
syncs dependencies to the environment. It also activates the virtual environment in your shell.

```bash
#!/usr/bin/env bash

layout_uv() {
    UV=$(which uv || true)
    if has mise; then
        UV=$(mise which uv || true)
    fi

    if [ -z "$UV" ]; then
        log_error "bin \`uv\` not found"
        return
    fi

    VIRTUAL_ENV="$(pwd)/.venv"
    export VIRTUAL_ENV

    PYPROJECT_TOML="${PYPROJECT_TOML:-pyproject.toml}"
    if [ ! -f "$PYPROJECT_TOML" ]; then
        log_error "no \`$PYPROJECT_TOML\` found"
        log_status "creating a \`$PYPROJECT_TOML\` with \`uv\`"
        $UV init
    fi

    if [ ! -d "$VIRTUAL_ENV" ]; then
        log_status "installing python interpreters with \`uv\`"
        $UV python install -q
        log_status "creating venv with \`uv\`"
        $UV venv .venv -q
    fi

    log_status "syncing venv with \`uv\`"
    $UV sync

    PATH_add "$VIRTUAL_ENV/bin"
}
```

### layout_poetry.sh

This script ensures that `poetry` has setup a virtual environment and has installed required
dependencies. It also automatically activates the virtual environment and informs you of any
problems with the environment.

```bash
#!/usr/bin/env bash

layout_poetry() {
    POETRY=$(which poetry || true)
    if has mise; then
        POETRY=$(mise which poetry || true)
    fi

    if [ -z "$POETRY" ]; then
        log_error "bin \`poetry\` not found"
        return
    fi

    PYPROJECT_TOML="${PYPROJECT_TOML:-pyproject.toml}"
    if [ ! -f "$PYPROJECT_TOML" ]; then
        log_error "no \`$PYPROJECT_TOML\` found"
        log_status "creating a \`$PYPROJECT_TOML\` with \`poetry\`"
        touch README.md
        $POETRY init -q
        $POETRY install --no-root
    fi

    if [ -d ".venv" ]; then
        VIRTUAL_ENV="$(pwd)/.venv"
    else
        VIRTUAL_ENV="$($POETRY env list --full-path | head -1 | awk '{print $1}')"
    fi

    if [ -z "$VIRTUAL_ENV" ] || [ ! -d "$VIRTUAL_ENV" ]; then
        log_status "creating venv with \`poetry\`"
        $POETRY install
        VIRTUAL_ENV="$($POETRY env list --full-path | head -1 | awk '{print $1}')"
    fi

    if has mise; then
        mise current python | sed 's/ /\n/g' | rg -q "$($POETRY run python -V | rg -o '\d+\.\d+\.\d+')" || {
            log_error "python venv version and .tool-versions does not match"
        }
    fi

    log_status "running poetry check"
    $POETRY check --ansi >/dev/null || true

    PATH_add "$VIRTUAL_ENV/bin"
    export POETRY_ACTIVE=1
    export VIRTUAL_ENV
}
```

### layout_pip.sh

This script ensures that a virtual environment is created and the `requirements.txt` file is
installed with `pip`. It also automatically activates the virtual environment.

```bash
#!/usr/bin/env bash

layout_pip() {
    PYTHON=$(which python || true)
    if has mise; then
        PYTHON=$(mise which python || true)
    fi

    if [ -z "$PYTHON" ]; then
        log_error "bin \`python\` not found"
        return
    fi

    VIRTUAL_ENV="$(pwd)/.venv"
    export VIRTUAL_ENV

    REQ_TXT="${REQ_TXT:-requirements.txt}"
    if [ ! -f "$REQ_TXT" ]; then
        log_error "no \`$REQ_TXT\` found"
        log_status "creating a \`$REQ_TXT\`"
        touch $REQ_TXT
    fi

    BIN="$VIRTUAL_ENV/bin"

    if [ ! -d "$VIRTUAL_ENV" ]; then
        log_status "creating venv with \`python\`"
        $PYTHON -m venv $VIRTUAL_ENV

        log_status "installing requirements from \`$REQ_TXT\`"
        $BIN/pip install -r $REQ_TXT
    fi

    if has mise; then
        mise current python | sed 's/ /\n/g' | rg -q "$($BIN/python -V | rg -o '\d+\.\d+\.\d+')" || {
            log_error "python venv version and .tool-versions does not match"
        }
    fi

    PATH_add "$BIN"
}
}
```

## Project with uv

Now we have everything to setup our project.

```console
# Create project dir and cd into it
$ mkdir myproject && cd myproject

# Create .tool-versions file
$ echo uv 0.4.17 > .tool-versions

# Install needed tools
$ mise install
mise all runtimes are installed

# Create .envrc file, remember that `use mise` should always be the first command
$ echo "use mise # Should always be first command in file" > .envrc && \
  echo layout uv >> .envrc

# Allow .envrc file
$ direnv allow
direnv: loading /tmp/myproject/.envrc
direnv: using mise
direnv: no `pyproject.toml` found
direnv: creating a `pyproject.toml` with `uv`
Initialized project `myproject`
direnv: installing python interpreters with `uv`
direnv: creating venv with `uv`
direnv: syncing venv with `uv`
Resolved 1 package in 2ms
Audited in 0.00ms
direnv: export +VIRTUAL_ENV ~PATH
```

Now, everytime you open up this directory, direnv will whip up your environment 🎉 You can
verify that the virtual environment is activated by running these commands.

```console
# Exit and enter our project directory again
$ cd myproject/
direnv: loading /tmp/myproject/.envrc
direnv: using mise
direnv: syncing venv with `uv`
Resolved 1 package in 1ms
Audited in 0.01ms
direnv: export ~PATH

$ which python
/tmp/myproject/.venv/bin/python
```

## Projects with poetry or pip

The process above can be replicated for `poetry`  or `pip` by using their respective *layouts*.
