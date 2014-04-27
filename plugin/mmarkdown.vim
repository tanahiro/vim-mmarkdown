" vim:foldmethod=marker
" File: plugin/mmarkdown.vim
" Author: Hiroyuki Tanaka <hryktnk@gmail.com>
" WebPage: https://github.com/tanahiro/vim-mmarkdown
" License: MIT

"" Initialzie {{{
if !exists('g:mmarkdown_workdir')
  let g:mmarkdown_workdir=$HOME.'/mmarkdown'
endif
if !exists('g:mmarkdown_html_dir')
  let g:mmarkdown_html_dir=$HOME.'/mmarkdown/html'
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

command! MMarkdownToHTML call mmarkdown#base#to_html(expand("%"))
" }}}

" Mapping {{{
if !hasmapto('<Plug>MMarkdownIndex')
  nmap <silent><unique> <Leader>mm <Plug>MMarkdownIndex
endif
nnoremap <unique><script> <Plug>MMarkdownIndex :MMarkdownIndex<CR>

if !hasmapto('<Plug>MMarkdownToHTML')
  nmap <silent><unique> <Leader>mh <Plug>MMarkdownToHTML
endif
nnoremap <unique><script> <Plug>MMarkdownToHTML :MMarkdownToHTML<CR>
" }}}

