---
author: "Guðmundur Björn Birkisson"
title: "Vim Cheatsheet"
date: "2022-09-28"
description: "My cheat sheet for vim"
tags:
- shell
- vim
- cheatsheet
---

This is my vim cheat sheet 🚀

<!-- vim-markdown-toc GFM -->

- [Basics](#basics)
  - [Basic verbs and movements](#basic-verbs-and-movements)
  - [Add, Copy, Paste, Cut, Delete](#add-copy-paste-cut-delete)
  - [Change, Replace, Undo, Repeat](#change-replace-undo-repeat)
  - [More Nouns](#more-nouns)
- [Commands](#commands)
  - [Find, Save, Quit](#find-save-quit)
  - [Replace/Delete](#replacedelete)
  - [Bash](#bash)
- [Macros](#macros)
- [Other](#other)
  - [Multicursor edit](#multicursor-edit)
  - [Clipboard](#clipboard)
  - [Cursor Position](#cursor-position)
  - [Misc](#misc)
- [Plugins](#plugins)

<!-- vim-markdown-toc -->

## Basics

### Basic verbs and movements

Syntax of commands is broken into **number** + **verbs** + **nouns**. So for example `2dw` means, delete two words:

`2` for two <br>
`d` for delete <br>
`w` for word <br>


| Basics | Verbs | Nouns / Movements |
| --- | --- | --- |
| `h`<br> `j` move<br> `k` around<br> `l` | `d` delete<br> `c` change<br> `<` `>` indent<br> `v` `V` visual select __*__<br> `y` yank<br> | `w` `W` forward 1 word __**__<br> `e` `E` to last character in current word __**__ <br> `b` `B` backwards 1 word __**__<br> `0` `$` front and end of line<br> `gg` `G` cursor to beginning/end of doc<br> `<c-u>` `<c-d>` ½ page up/down<br> `%` to matching brace, bracket, etc...<br> `*` `#` to next/previous instance of the same word |

> __*__ : the latter (`V`) selects whole lines. <br> __**__ : the latter (`W`, `B`, `E`) use whitespace as boundaries.

### Add, Copy, Paste, Cut, Delete

| Add | Copy/Paste | Cut/Delete |
| --- | --- | --- |
| `i` insert<br> `I` insert start of line<br>`a` insert after cursor<br>`A` insert end of line<br>`o` insert on new line below<br>`O` insert on new line above | `yl` yank char<br>`yw` yank word<br>`yy` `Y` yank line<br> `p` paste afer current line<br>`P` paste before current line| `dl` delete char<br>`dw` delete word<br>`dd` delete line<br> `x` delete char (same as `dl`)<br>`X` delete char before cursor |

> **Note**: Deletions always work like cut, that is, deleted object is put into a register so that it can be pasted later.

### Change, Replace, Undo, Repeat

| Change | Replace | Undo/Repeat |
| --- | --- | --- |
| `cl` change char<br> `cw` change word<br>`cc` change line<br>`C` change from cursor to end of line<br>`sl` change char<br>`S` change line | `r` replace single char<br>`R` replace until stop typing<br>`~` change char case | `u` undo<br>`U` undo current line<br>`<c-r>` redo<br>`.` repeat command |

### More Nouns

| Nouns / Movements |
| --- |
| `iw` inner word (select whole word)<br>  `it` inner tag (select inside tag) <br>`ip` inner paragraph <br>`i"` `i'` inner quotes |

> **Note**: Use `a` instead of `i` in these examples to include trailing whitespaces.

## Commands

### Find, Save, Quit

| Find | Save/Quit |
| --- | --- |
| `/` `?` search forwards/backwards<br> `n` next hit<br>`N` prev hit | `:w` save<br>`:q` quit<br>`ZZ` save and quit |

### Replace/Delete

| Command |
| --- |
| `:s/<old>/<new>` replace old with new on selected lines <br> `:%s/<old>/<new>/g` replace old with new globally <br> `:s/\(\d\+\)/number \1` using regex capture groups __*__ <br> `:g/<pattern>/d` delete line matching pattern | 

> __*__ : This command becomes `:s(\d+)/number \1` if using vscode vim plugin. That is because you need to use javascript regex.

### Bash

| Command |
| --- |
| `:!grep "find this string" %` |

> **Note**:  The file you have opened is `%` in this example!

## Macros

| Create | Apply | View |
| --- | --- | --- |
| `qr` start recording __*__ <br> _do anything when recording_ <br> `q` in normal mode to finish | `@r` apply macro | `:reg r` look at __r__ register <br> `:reg` look at all registers |

> __*__ : You can use any letter `a` to `z` instead of `r`, these are just register names!

## Other

### Multicursor edit

You can kind of do multi cursor edit by using visual block mode. For example commenting out 4 lines would be:
- `0` go to begining of line
- `<c-v>` enter visual block mode
- `3j` also select next 3 lines
- `I` insert at begining
- `//` add comment
- `<ESC>` exit insert mode

### Clipboard

| Clipboard |
| --- |
| `"+p` paste from clipboard <br> `"+yy` yank line to clipboard |

> **Note**: The clipboard is the `+` register. To access a register you start with `"`.

### Cursor Position

| Cursor Position |
| --- |
| `H` `M` `L` move cursor to top/middle/bottom of screen <br> `zt` `zz` `zb` scroll so cursor is on top/middle/bottom | 

### Misc

| Misc | 
| --- |
| `=` auto indent selection, i.e. `=ap`, `=G` |

## Plugins

| Plugin | Command |
| --- | --- |
| [nvim-comment](https://github.com/terrortylor/nvim-comment) | `gc<motion>` comment out selection |
