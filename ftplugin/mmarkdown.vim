" vim:foldmethod=marker
" File: ftplugin/mmarkdown.vim
" Author: Hiroyuki Tanaka <hryktnk@gmail.com>
" WebPage: https://github.com/tanahiro/vim-mmarkdown
" License: MIT

" Command {{{
command! -buffer MMarkdownToHTML
      \ silent w <bar>
      \ call mmarkdown#base#to_html(expand("%")) <bar>
      \ echo 'MMarkdown: Converted to HTML'
command! -range MMarkdownPartToHTML
      \ <line1>,<line2>call mmarkdown#base#selected_part_to_html()

command! -buffer MMarkdownFollowLink call mmarkdown#base#follow_wiki_link('e')
command! -buffer MMarkdownFollowLinkSplit
      \ call mmarkdown#base#follow_wiki_link('split')
command! -buffer MMarkdownFollowLinkVSplit
      \ call mmarkdown#base#follow_wiki_link('vsplit')
" }}}

" Mapping {{{
if !hasmapto('<Plug>MMarkdownToHTML')
  nmap <buffer> <Leader>mh <Plug>MMarkdownToHTML
endif
nnoremap <script><buffer> <Plug>MMarkdownToHTML :MMarkdownToHTML<CR>

if !hasmapto('<Plug>MMarkdownPartToHTML')
  vmap <buffer> <Leader>mh <Plug>MMarkdownPartToHTML
endif
vnoremap <script><buffer> <Plug>MMarkdownPartToHTML :MMarkdownPartToHTML<CR>

if !hasmapto('<Plug>MMarkdownFollowLink')
  nmap <silent><buffer> <CR> <Plug>MMarkdownFollowLink
endif
nnoremap <silent><script><buffer>
      \ <Plug>MMarkdownFollowLink :MMarkdownFollowLink<CR>

if !hasmapto('<Plug>MMarkdownFollowLinkSplit')
  nmap <silent><buffer> <C-CR> <Plug>MMarkdownFollowLinkSplit
endif
nnoremap <silent><script><buffer>
      \ <Plug>MMarkdownFollowLinkSplit :MMarkdownFollowLinkSplit<CR>

if !hasmapto('<Plug>MMarkdownFollowLinkVSplit')
  nmap <silent><buffer> <S-CR> <Plug>MMarkdownFollowLinkVSplit
endif
nnoremap <silent><script><buffer>
      \ <Plug>MMarkdownFollowLinkVSplit :MMarkdownFollowLinkVSplit<CR>

" }}}

