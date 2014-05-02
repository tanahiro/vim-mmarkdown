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

syn match mmarkdownPlaceholder /^\s*%toc\%(\s.*\)\?$/
      \ contains=VimwikiPlaceholderParam
syn match mmarkdownPlaceholder /^\s*%title\%(\s.*\)\?$/
      \ contains=mmarkdownPlaceholderParam
syn match mmarkdownPlaceholder /^\s*%template\%(\s.*\)\?$/
      \ contains=mmarkdownPlaceholderParam
syn match mmarkdownPlaceholderParam /\s.*/ contained

hi def link mmarkdownEq Special
hi def link mmarkdownBlockEq Special

hi def link mmarkdownWikiLink Underlined

hi def link mmarkdownPlaceholder SpecialKey
hi def link mmarkdownPlaceholderParam String

let b:current_syntax = "mmarkdown"

