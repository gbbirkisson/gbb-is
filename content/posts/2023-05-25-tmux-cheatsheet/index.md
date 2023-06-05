---
author: "Guðmundur Björn Birkisson"
title: "Tmux Cheatsheet"
date: "2023-05-25"
description: "My cheat sheet for tmux"
tags:
- shell
- tmux
- cheatsheet
---

This is my tmux cheat sheet 🚀

<!-- vim-markdown-toc GFM -->

* [Basics](#basics)
    * [Panes and Windows](#panes-and-windows)
    * [TPM](#tpm)
* [Commands](#commands)

<!-- vim-markdown-toc -->

## Basics

Start any command with the tmux prefix: `<c-space>` (default is `<c-b>` but that is silly)!

### Panes and Windows

| Panes | Windows | Sessions |
| --- | --- | --- |
| `"` `%` new below/right <br> `x` close (`<c-d>` easier) <br> `←` `↓` `↑` `→` move focus <br> `h` `j` `k` `l` move focus <br> `z` zoom in/out | `c` new window <br> `&` close <br> `1`-`9` switch window <br> `p` `n` prev/next window <br> `,` rename <br> | `d` detach session <br> `$` rename <br> `s` select session |

### TPM

| TPM |
| --- |
| `I` Install plugins |

## Commands

Run in a terminal:

```console
$ tmux <command>
```

| Command |
| --- |
| `a` attach to session <br> `a -t <name>` attach to target session <br> `new -s <name>` new session session <br> `ls` list active sessions |

