" vim:foldmethod=marker
" File: plugin/mmarkdown.vim
" Author: Hiroyuki Tanaka <hryktnk@gmail.com>
" WebPage: https://github.com/tanahiro/vim-mmarkdown
" License: MIT

if !has('ruby')
  finish
endif

"" Initialzie {{{
if !exists('g:mmarkdown_workdir')
  let home = substitute($HOME, '\\', '/', 'g')
  let g:mmarkdown_workdir=home.'/mmarkdown'
  unlet home
endif
if !exists('g:mmarkdown_html_dir')
  let home = substitute($HOME, '\\', '/', 'g')
  let g:mmarkdown_html_dir=home.'/mmarkdown/html'
  unlet home
endif

if !isdirectory(g:mmarkdown_workdir)
  call mkdir(iconv(g:mmarkdown_workdir, &encoding, &termencoding), 'p')
endif
if !isdirectory(g:mmarkdown_html_dir)
  call mkdir(iconv(g:mmarkdown_html_dir, &encoding, &termencoding), 'p')
endif
" }}}

" Autocommand {{{
augroup mmarkdown
  autocmd!

  au BufWinEnter *.mmd set filetype=mmarkdown
augroup END
" }}}

" Command {{{
command! MMarkdownIndex call mmarkdown#base#index()
" }}}

" Mapping {{{
if !hasmapto('<Plug>MMarkdownIndex')
  nmap <silent><unique> <Leader>mm <Plug>MMarkdownIndex
endif
nnoremap <unique><script> <Plug>MMarkdownIndex :MMarkdownIndex<CR>
" }}}

