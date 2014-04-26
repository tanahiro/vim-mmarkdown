" vim:foldmethod=marker
" File: synatx/mmarkdown.vim
" Author: Hiroyuki Tanaka <hryktnk@gmail.com>
" WebPage: https://github.com/tanahiro/vim-mmarkdown
" License: MIT

runtime! syntax/markdown.vim
unlet! b:current_syntax

let g:mmarkdown_WikiLinkPrefix = '[['
let g:mmarkdown_WikiLinkSuffix = ']]'

syn region mmarkdownEq start="\\(" end="\\)"
syn region mmarkdownBlockEq start="\\\[" end="\\\]"

syn region mmarkdownWikiLink start="\[\[" end="\]\]"

hi def link mmarkdownEq Special
hi def link mmarkdownBlockEq Special

hi def link mmarkdownWikiLink Underlined

let b:current_syntax = "mmarkdown"

