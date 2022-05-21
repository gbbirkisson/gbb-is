---
author: "Guðmundur Björn Birkisson"
title: "Bash Script Cheatsheet"
date: "2022-05-21"
description: "Templates for a nice bash scripts"
tags:
  - bash
  - shell
  - template
---

The motivation here is to remember bash script best practices, and also to create user friendly scripts. There is a very nice [gist](https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca) that goes into detail many of the things I mention here. This [article](http://redsymbol.net/articles/unofficial-bash-strict-mode/) is also very helpful. There are 2 examples here:

- [General script magic](#general-script-magic)
- [Sophisticated argument parsing](#sophisticated-argument-parsing)


#### General script magic

So here is a strange script that covers most of the things that would be helpful:

```bash
#!/usr/bin/env bash

set -e # Exit immediately if some command has a non-zero exit code
set -u # Exit with error if you use variables that have not been defined
set -o pipefail # Prevent errors in pipeline from being masked

#set -euo pipefail # This is the commands above combined

#set -x # Uncomment for debugging

# Handy way of getting information about the script itself
SCRIPT_DIR="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"
SCRIPT_NAME=$(basename $0)
SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_NAME"

# Nice logging functions with colorized output
log-lines() { for a in "$@"; do printf "\n  $a" 1>&2 ;done ;printf "\n" 1>&2 ;}
log-info() { printf "$(tput setaf 2)INFO$(tput sgr0): $1" 1>&2; log-lines "${@:2}"; }
log-warn() { printf "$(tput setaf 3)WARN$(tput sgr0): $1" 1>&2; log-lines "${@:2}"; }
log-error() { printf "$(tput setaf 1)ERROR$(tput sgr0): $1" 1>&2; log-lines "${@:2}"; exit 1; }
highlight() { d="";	for a in "$@"; do printf "$(tput bold)$(tput setaf 5)$d$a$(tput sgr0)";	d=" "; done; }

# Function to print out error message and usage examples
usage() {
    cat 1>&2 <<EOF
Usage: $SCRIPT_NAME NAME AGE

Examples:
  $ $SCRIPT_NAME Bob 10

EOF
    (log-error "")
    echo -n "  " 1>&2
}

# Easy way for making arguments mandatory
name=${1:?"NAME <- missing parameter $(usage)"}
age=${2:?"AGE <- missing parameter $(usage)"}

# Example of how to use the logging functions
log-info "Running script with parameters:" "SCRIPT_DIR: $SCRIPT_DIR" "SCRIPT_NAME: $SCRIPT_NAME" "SCRIPT_PATH: $(highlight $SCRIPT_PATH)" "NAME: $name" "AGE: $age"

# How to run some cleanup when the script exits
function finish() {
    log-warn "Exiting script"
}
trap finish EXIT

# Creation of arrays
addresses=(
    "738 Ferrell Street"
    "1237 Mapleview Drive"
    "2070 Cambridge Court"
)

# Change internal field seperator to be less eager
IFS=$'\n\t'
for address in ${addresses[@]}; do
    log-info "$address"
done

# Overriding argument to the script
set -- echo Override Arguments

# Execute arguments
$@

# Log error and exit
log-error "Example of failure in the script"

# Replace current shell with command. Has the effect that the finish function is never executed
exec "$@"
```

Now running the script with no parameters will give you an nice error message:

```console
$ ./script.sh
Usage: script.sh NAME AGE

Examples:
  $ script.sh Bob 10

ERROR: 
  ./script.sh: line 40: 1: NAME <- missing parameter
```

And running it with the proper parameters gives you something like this:

```console
$ ./script.sh Bob 10
INFO: Running script with parameters:
  SCRIPT_DIR: /home/bob
  SCRIPT_NAME: script.sh
  SCRIPT_PATH: /home/bob/script.sh
  NAME: Bob
  AGE: 10
INFO: 738 Ferrell Street
INFO: 1237 Mapleview Drive
INFO: 2070 Cambridge Court
Override Arguments
ERROR: Example of failure in the script
WARN: Exiting script
```

#### Sophisticated argument parsing

Sometimes you need more fine grained controll over your argument parsing. Then this is a nice approach:

```bash
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME=$(basename $0)

# Nice logging functions with colorized output
log-lines() { for a in "$@"; do printf "\n  $a" 1>&2 ;done ;printf "\n" 1>&2 ;}
log-error() { printf "$(tput setaf 1)ERROR$(tput sgr0): $1" 1>&2; log-lines "${@:2}"; exit 1; }

usage() {
    cat 1>&2 <<EOF
Usage: $SCRIPT_NAME [OPTIONS] FILE LINENR
Print out a specific line number in a file.

Options:
  -i, --iter=  Number of times to print line [default: 1]
  -h, --help   Print this dialog

Examples:
  $ $SCRIPT_NAME /etc/hosts 1
  $ $SCRIPT_NAME /etc/hosts 1 -i 12
EOF
    if [ ! -z $1 ]; then
        echo "" 1>&2
        (log-error "")
        echo -n "  " 1>&2
    fi
    exit 1
}

# Set default iter to 1
ITER=1

# Iterate over arguments and parse them
while [ "$#" -gt 0 ]; do
    case $1 in
    -h | --help)
        usage
        ;;
    -i)
        shift
        ITER="$1"
        ;;
    --iter=*)
        ITER=$(echo $1 | awk '{split($0,r,"="); print r[2]}')
        ;;
    *)
        if [ "${FILE:-unset}" == "unset" ]; then FILE=$1
        elif [ "${LINENR:-unset}" == "unset" ]; then LINENR=$1
        fi
        ;;
    esac
    shift
done

# Make sure required parameters are set
FILE=${FILE:?"<- parameter missing $(usage FILE)"}
LINENR=${LINENR:?"<- parameter missing $(usage LINENR)"}

# Run iterations
for i in $(seq $ITER); do
    sed -n ${LINENR}p $FILE
done
```

Now you have a very nice interface:

```console
$ ./script.sh
Usage: script.sh [OPTIONS] FILE LINENR
Print out a specific line number in a file.

Options:
  -i, --iter=  Number of times to print line [default: 1]
  -h, --help   Print this dialog

Examples:
  $ script.sh /etc/hosts 1
  $ script.sh /etc/hosts 1 -i 12

ERROR: 
  ./script.sh: line 58: FILE: <- parameter missing
```

And using correct parameters:

```console
$ ./script.sh /etc/hosts 1 -i 4
# Host addresses
# Host addresses
# Host addresses
# Host addresses
```