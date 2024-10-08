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

* [Basics](#basics)
    * [Basic verbs](#basic-verbs)
    * [Basic Nouns (movements)](#basic-nouns-movements)
    * [Add, Copy, Paste, Cut, Delete](#add-copy-paste-cut-delete)
    * [Change, Replace, Undo, Repeat](#change-replace-undo-repeat)
    * [More Nouns](#more-nouns)
* [Commands](#commands)
    * [Find, Save, Quit](#find-save-quit)
    * [Replace/Delete](#replacedelete)
    * [Bash](#bash)
* [Macros](#macros)
* [Clipboard & Buffers](#clipboard--buffers)
* [Cursor](#cursor)
* [Windows](#windows)
* [Misc](#misc)
* [Plugins](#plugins)
* [Quick lists](#quick-lists)

<!-- vim-markdown-toc -->

## Basics

Syntax of commands is broken into **number** + **verbs** + **nouns**. So for example `2dw` means, delete two words:

`2` for two <br>
`d` for delete <br>
`w` for word <br>

### Basic verbs

| Basics | Verbs |
| --- | --- |
| `h`<br> `j` move<br> `k` around<br> `l` | `d` delete<br> `c` change<br> `<` `>` indent<br> `v` `V` visual select __*__<br> `y` yank<br> |

> __*__ : the latter (`V`) selects whole lines. <br> __*__ : `u` `U` to lower/upper case selection in visual mode. <br> __*__ : `o` in visual mode will move the cursor from beginning to end.

### Basic Nouns (movements)

| Horizontal Movements | Vertical Movements |
| --- | --- |
| `w` `W` forward 1 word __*__<br> `b` `B` backwards 1 word __*__<br> `e` `E` to last character in current word __*__ <br> `ge` `gE` to end of previous word __*__<br> `0` `$` front and end of line<br> `^` first non-whitespace char in line <br> `%` to matching brace, bracket, etc... | `gg` `G` beginning/end of doc<br> `{` `}` up/down 1 paragraph<br> `<c-u>` `<c-d>` up/down ½ page <br> `*` `#` to next/previous instance of the same word <br> `f<?>` `F<?>` go on top of next/prev `<?>` __**__ <br> `t<?>` `T<?>` go to next/prev `<?>` __**__ <br> `;` `,` next/previous go to |

> __*__ : the latter (`W`, `B`, `E`, `gE`) use whitespace as boundaries. <br> ___**___ : `<?>` can be any character.

### Add, Copy, Paste, Cut, Delete

| Add | Copy/Paste | Cut/Delete |
| --- | --- | --- |
| `i` insert<br> `I` insert start of line<br>`a` insert after cursor<br>`A` insert end of line<br>`o` insert on new line below<br>`O` insert on new line above | `yl` yank char<br>`yw` yank word<br>`yy` `Y` yank line<br> `p` paste after current line<br>`P` paste before current line| `dl` delete char<br>`dw` delete word<br>`dd` delete line<br> `x` delete char (same as `dl`)<br>`X` delete char before cursor |

> **Note**: Deletions always work like cut, that is, deleted object is put into a register so that it can be pasted later.

### Change, Replace, Undo, Repeat

| Change | Replace | Undo/Repeat |
| --- | --- | --- |
| `cl` change char<br> `cw` change word<br>`cc` change line<br>`C` change from cursor to end of line<br>`sl` change char<br>`S` change line | `r` replace single char<br>`R` replace until stop typing<br>`~` change char case | `u` undo<br>`U` undo current line<br>`<c-r>` redo<br>`.` repeat command |

### More Nouns

| Nouns / Movements |
| --- |
| `iw` inner word (select whole word)<br>  `it` inner tag (select inside tag) <br>`ip` inner paragraph <br>`i"` `i'` inner quotes <br> `a{` brackets and everything inside |

> **Note**: Use `a` instead of `i` in these examples to include whitespaces or surrounding symbol.

> **Note**: Doing these outside selected pair will jump to next one. For example doing `vi(` outside a `()` pair will jump to the next `(` and select everything inside those brackets. Doing `va(` will include the brackets.

## Commands

### Find, Save, Quit

| Find | Save/Quit |
| --- | --- |
| `/` `?` search forwards/backwards<br> `n` next hit<br>`N` prev hit | `:w` save<br>`:q` quit<br>`ZZ` save and quit |

### Replace/Delete

| Command |
| --- |
| `:s/<old>/<new>` replace old with new on selected lines <br> `:%s/<old>/<new>/g` replace old with new globally <br> `:%s/<old>/<new>/gc` replace old with new with confirmation <br> `:s/\(\d\+\)/number \1` using regex capture groups <br> `:g/<pattern>/d` delete line matching pattern |

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

## Clipboard & Buffers

| Clipboard | Buffers |
| --- | --- |
| `"+p` paste from clipboard __*__ <br> `"+yy` yank line to clipboard __*__ |`:ls` list buffers <br> `:b <?>` switch buffer __**__ <br> `:bd <?>` close buffer __**__ |

> __*__: The clipboard is the `+` register. To access a register you start with `"`. <br>
> __**__: `<?>` is optional and can be a number or part of name.

## Cursor

| Multicursor edit | Cursor Position |
| --- | --- |
| e.g. commenting out 4 lines would be: <br><br> `0` go to beginning of line <br> `<c-v>` enter visual block mode <br> `3j` also select next 3 lines <br> `I` insert at beginning <br> `//` add comment <br> `<ESC>` exit insert mode | `H` `M` `L` move cursor to top/middle/bottom of screen <br> `zt` `zz` `zb` scroll so cursor is on top/middle/bottom |

## Windows

| Create | Manipulate | Navigate |
| --- | --- | --- |
| `<c-w>s` split (horizontally) <br> `<c-w>v` split vertically <br> `<c-w>o` close others <br> `<c-w>c` close | `<c-w>H` <br> `<c-w>J` move window <br> `<c-w>K` around <br> `<c-w>L` <br> <br> `<c-w>x` swap positions <br> | `<c-w>h` <br> `<c-w>j` move cursor <br> `<c-w>k` around windows <br> `<c-w>l` <br> <br> `<c-w>w` move to next <br> |

## Misc

| Netrw | Misc |
| --- | --- |
| `:Ex` open netrw <br> `%` create file in netrw | `:so` source open file <br> `<c-a>` increment number |

## Plugins

Kickstart your nvim configuration with [kickstart](https://github.com/nvim-lua/kickstart.nvim).

| Commands |
| --- |
| `:Telescope keymaps` search in keymaps <br> `:GenTocGFM` generate markdown toc <br> `:Mason` list tools (`i` to install) <br>

| Navigation |
| --- |
| `<leader>sf` search files <br> `<leader>sg` grep files <br> `s` jump forward/backward/to other windows |

> **Note**: Jump commands come from the [Flash plugin](https://github.com/folke/flash.nvim).

| Code |
| --- |
| `gd` go to definition __*__ <br> `gr` go to references __*__ <br> `gc<motion>` comment out selection <br> `=` auto indent selection, i.e. `=ap`, `=G` <br> `K` Display symbol info  |

> __*__ : Select up and down with `<c-p>` and `<c-n>`.

## Quick lists

Quick lists are useful when searching for a word in your project, and get a list of all the files containing that word.

You can open up quick list of all the files in your project containing `foo` by opening up telescope, searching for `foo` and pressing `<c-q>`.

Then replace `foo` with bar by running `:cdo s/foo/bar/ | update`. Close all buffers opened by this command by running `:cfdo bd`.
