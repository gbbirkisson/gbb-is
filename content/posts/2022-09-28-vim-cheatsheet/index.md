---
author: "Guðmundur Björn Birkisson"
title: "Vim Cheatsheet"
date: "2022-09-28"
description: "My cheat sheet for vim"
tags:
- shell
- vim
---

This is my vim cheat sheet.

<!-- vim-markdown-toc GFM -->

* [Basics](#basics)
	* [The verbs](#the-verbs)
	* [The nouns (motions)](#the-nouns-motions)
	* [The nouns (text objects)](#the-nouns-text-objects)
	* [The nouns (parameterized text objects)](#the-nouns-parameterized-text-objects)
* [Commands](#commands)
* [Cursor](#cursor)
* [Plugin commands](#plugin-commands)

<!-- vim-markdown-toc -->

## Basics

Syntax of commands is broken into **verbs** + **nouns**. So for example:

`d` for delete
`w` for word

### The verbs
- `d`: Delete
- `c`: Change
- `<` or `>`: Indent
- `v`: Visual select
- `y`: Yank (copy)
- `gc`: Toggle comments (commentary plugin)

### The nouns (motions)
- `h`, `j`, `k`, `l`: Left, Down, Up, Right
- `w`: Forward by a word
- `b`: Back by a word
- `3j`: Down 3 lines
- `$`: Start of line
- `0` (zero): End of line
- `gg`: Beginning of file
- `G`: End of file

### The nouns (text objects)
- `iw`: Inner word (works inside word)
- `it`: Inner tag (inside html)
- `i"`: Inner quotes (`i'` also works)
- `ip`: Inner paragraph
- `as`: A sentance

### The nouns (parameterized text objects)
- `f`: Find next character (`F` to go backwards)
- `t`: Upto but not including (`T` to go backwards)
- `/`: Search (i.e. `c/stuff`)

## Commands

- `.`: Rerun last command
- `u`: Undo
- `ctrl` + `r`: Redo
- `p`: Paste
- `A`: Insert at end of line
- `o`: Insert line below
- `O`: Insert line above

## Cursor

- `zt`: Move cursor to top
- `zz`: Move cursor to middle
- `zb`: Move cursor to buttom
- `ctrl` + `d`: Move cursor 1/2 page down
- `ctrl` + `u`: Move cursor 1/2 page up 

## Plugin commands

- `:Rg`: Search with ripgrep
- `ctrl` + `p`: Open file working dir
- `ctrl` + `j`: Switch buffer (close buffer with `:bd`)
