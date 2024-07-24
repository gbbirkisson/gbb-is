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
show how I use these tools to manage python dependencies with
[poetry](https://python-poetry.org/).

<!-- vim-markdown-toc GFM -->

* [Configuring dotenv](#configuring-dotenv)
    * [use_mise.sh](#use_misesh)
    * [layout_poetry.sh](#layout_poetrysh)
* [Setting up a project](#setting-up-a-project)

<!-- vim-markdown-toc -->

## Configuring dotenv

I am going to start at the deep end here by going over the configuration needed for *direnv*. We
are going to create two new commands that we can use in our `.envrc` files. We do that by adding
these two corresponding files in the `$HOME/.config/direnv/lib` directory.

### use_mise.sh

This script ensures that the *mise* path is correctly set in *direnv*. It also prints out any
tools that are currently missing. It is important that this command is always the first command
in our `.envrc` file. More on that later.

```bash
use_mise() {
        direnv_load mise direnv exec
        IFS=$'\n'
        for l in $(mise current 2>&1 | grep "not installed"); do
                tput setaf 3
                log_status "$l"
                tput sgr0
        done
        unset IFS
}
```

### layout_poetry.sh

This script ensures that *poetry* is setup and has the correct dependencies installed. It also
automatically activates the virtual environment and informs you of any problems with the
environment.

```bash
#!/bin/sh

layout_poetry() {
        PYPROJECT_TOML="${PYPROJECT_TOML:-pyproject.toml}"
        if [ ! -f "$PYPROJECT_TOML" ]; then
                log_status "No pyproject.toml found. Executing \`poetry init\` to create a \`$PYPROJECT_TOML\` first."
                poetry init -q
                poetry install --no-root
        fi

        if [ -d ".venv" ]; then
                VIRTUAL_ENV="$(pwd)/.venv"
        else
                VIRTUAL_ENV="$(poetry env list --full-path | head -1 | awk '{print $1}')"
        fi

        if [ -z "$VIRTUAL_ENV" ] || [ ! -d "$VIRTUAL_ENV" ]; then
                log_status "No virtual environment exists. Executing \`poetry install\` to create one."
                poetry install
                VIRTUAL_ENV="$(poetry env list --full-path | head -1 | awk '{print $1}')"
        fi

        mise current python | sed 's/ /\n/g' | rg -q "$(poetry run python -V | rg -o '\d+\.\d+\.\d+')" || {
                tput setaf 3
                log_status "python venv version and .tool-versions does not match"
                tput sgr0
        }
        poetry check --ansi >/dev/null || true

        PATH_add "$VIRTUAL_ENV/bin"
        export POETRY_ACTIVE=1
        export VIRTUAL_ENV
}
```

## Setting up a project

Now we have everything to setup our project.

```console
# Create project dir and cd into it
$ mkdir myproject && cd myproject

# Create empty README (to make poetry happy)
$ touch README.md

# Create .tool-versions file
$ cat << EOF > .tool-versions
poetry 1.8.3
python 3.12.4
EOF

# Install needed tools
$ mise install
mise all runtimes are installed

# Create .envrc file, remember that `use mise` should always be the first command
$ cat << EOF > .envrc
use mise # Should always be first command in file
layout poetry
EOF

# Allow .envrc file
$ direnv allow
direnv: loading myproject/.envrc
direnv: using mise
direnv: No pyproject.toml found. Executing `poetry init` to create a `pyproject.toml` first.
Updating dependencies
Resolving dependencies... (0.1s)

Writing lock file
direnv: export +POETRY_ACTIVE +VIRTUAL_ENV ~PATH
```

Now, everytime you open up this directory, direnv will whip up your environment 🎉 You can verify that the virtual environment is activated by running these commands.

```console
# Exit and enter our project directory again
$ cd myproject/
direnv: loading /tmp/myproject/.envrc
direnv: using mise
direnv: export +POETRY_ACTIVE +VIRTUAL_ENV ~PATH

$ which python
$HOME/.cache/pypoetry/virtualenvs/myproject-MbtnTutz-py3.12/bin/python
```
