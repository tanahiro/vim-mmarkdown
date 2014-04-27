" vim:foldmethod=marker
" File: autoload/mmarkdown/base.vim
" Author: Hiroyuki Tanaka <hryktnk@gmail.com>
" WebPage: https://github.com/tanahiro/vim-mmarkdown
" License: MIT

function! mmarkdown#base#index() "{{{
  call mmarkdown#base#openfile(g:mmarkdown_workdir.'/index.mmd')
endfunction "}}}

function! mmarkdown#base#openfile(filename) "{{{
  execute ':e '.a:filename
endfunction "}}}

function! mmarkdown#base#to_html(filename) "{{{
  if (has("ruby"))
    ruby << EOF
    require 'mmarkdown'

    mmd_filename  = VIM::Buffer.current.name
    html_filename = VIM::evaluate("g:mmarkdown_html_dir") + "/"
    html_filename += File.basename(mmd_filename.gsub(/\.mmd\Z/, ".html"))

    md_string = File.open(mmd_filename).read
    html_string = MMarkdown.new(md_string).to_str

    File.open(html_filename, 'w') {|f|
      f.write(html_string)
    }

    VIM::message("HTML file generated as #{html_filename}")
EOF
  else
    echo "Cannot generate HTML. Ruby not available"
  endif
endfunction "}}}

