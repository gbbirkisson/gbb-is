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

This is my vim cheat sheet.

<!-- vim-markdown-toc GFM -->

- [Basics, Verbs, Movements](#basics-verbs-movements)
- [Add, Copy, Paste, Cut, Delete](#add-copy-paste-cut-delete)
- [Change, Replace, Undo, Repeat](#change-replace-undo-repeat)
- [Find, Save, Quit](#find-save-quit)
- [Advanced](#advanced)

<!-- vim-markdown-toc -->

## Basics, Verbs, Movements

Syntax of commands is broken into **number** + **verbs** + **nouns**. So for example:

`2` for two <br>
`d` for delete <br>
`w` for word <br>

| Basics | Verbs | Movements |
| --- | --- | --- |
| `h`<br>`j` move<br>`k` around<br>`l` | `d` delete<br>`c` change<br>`<` `>` indent<br>`v` visual select<br>`y` yank<br> | `w` `W` forward 1 word __*__<br>`b` `B` backwards 1 word __*__<br>`0` `$` front and end of line<br>`H` `M` `L` top, middle, bottom of screen<br>`gg` to beginning of doc<br>`G` to end of doc<br>`ctrl`+`u` 1/2 page up<br>`ctrl`+`d` 1/2 down<br>`%` to matching brace, bracket, etc... |

__*__ the latter (`W` and `B`) use whitespace as boundaries.

## Add, Copy, Paste, Cut, Delete

| Add | Copy/Paste | Cut/Delete |
| --- | --- | --- |
| `i` insert<br>`I` insert start of line<br>`a` insert after cursor<br>`A` insert end of line<br>`o` new line below<br>`O` new line above | `yl` yank char<br>`yw` yank word<br>`yy` yank line<br>`Y` yank line<br>`p` paste afer current line<br>`P` paste before current line| `dl` delete char<br>`dw` delete word<br>`dd` delete line<br> `x` delete char (same as `dl`)<br>`X` delete char before cursor |

Note that deletions also act as cut.

## Change, Replace, Undo, Repeat

| Change | Replace | Undo/Repeat |
| --- | --- | --- |
| `cl` change char<br>`cw` change word<br>`cc` change line<br>`C` change from cursor to end of line<br>`sl` change char<br>`S` change line | `r` replace single char<br>`R` replace until stop typing<br>`~` change char case | `u` undo<br>`U` undo current line<br>`ctrl`+`r` redo<br>`.` repeat command |

## Find, Save, Quit

| Find | Save/Quit |
| --- | --- |
| `/` search forward<br>`?` search backwards<br>`n` next hit<br>`N` prev hit | `:w` save<br>`:q` quit<br>`ZZ` save and quit |

## Advanced

| Text objects | Cursor Position |
| --- | --- |
| `iw` inner word (select whole word)<br>`it` inner tag (select inside tag)<br>`i"` inner quotes<br>`i'` inner quotes<br>`ip` inner paragraph | `zt` scroll so cursor is on top<br>`zz` scroll so cursor is in middle<br>`zb` scroll so cursor is on bottom |

Run bash command on all lines: `:% ! grep mysearch`

Delete lines sed style: `:g!/pattern/d`
