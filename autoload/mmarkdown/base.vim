" vim:foldmethod=marker
" File: autoload/mmarkdown/base.vim
" Author: Hiroyuki Tanaka <hryktnk@gmail.com>
" WebPage: https://github.com/tanahiro/vim-mmarkdown
" License: MIT

if !has("ruby")
  finish
endif

function! mmarkdown#base#index() "{{{
  call mmarkdown#base#openfile(g:mmarkdown_workdir.'/index.mmd', 'edit')
endfunction "}}}

function! mmarkdown#base#openfile(filename, split) "{{{
  let command=':'
  if a:split == 'split'
    let command.='sp'
  elseif a:split == 'vsplit'
    let command.='vs'
  elseif a:split == 'edit'
    let command.='e'
  else
    let command.='e'
  endif
  execute command.' '.a:filename
endfunction "}}}

function! mmarkdown#base#to_html(filename) "{{{
  ruby << EOF
  require 'mmarkdown'

  mmd_filename  = VIM::Buffer.current.name
  html_filename = VIM::evaluate("g:mmarkdown_html_dir") + "/"
  html_filename += File.basename(mmd_filename.gsub(/\.mmd\Z/, ".html"))

  md_string = File.open(mmd_filename).read
  md_string.gsub!(/\[\[(\w[\w -\/]*)\]\]/, '[\1](\1)')

  html_string = MMarkdown.new(md_string).to_str

  File.open(html_filename, 'w') {|f|
    f.write(html_string)
  }

  #VIM::message("HTML file generated as #{html_filename}")
EOF
endfunction "}}}

function! mmarkdown#base#follow_wiki_link(split) "{{{
  let dir  = ""
  let file = ""

  ruby << EOF
    VIM::command('let link=mmarkdown#base#detect_wiki_link()')

    link = VIM::evaluate('link')

    unless link == ""
      VIM::command("let dir=\"#{File.dirname(link)}\"")
      VIM::command("let file=\"#{File.basename(link)}.mmd\"")
    end
EOF
  if file != ""
    if dir != "."
      let dir = g:mmarkdown_workdir.'/'.dir
      if !isdirectory(dir)
        call mkdir(iconv(dir, &encoding, &termencoding), 'p')
      endif
    else
      let dir = g:mmarkdown_workdir
    endif

    call mmarkdown#base#openfile(dir.'/'.file, a:split)
  endif
endfunction "}}}

function! mmarkdown#base#detect_wiki_link() "{{{
  let link=""

  ruby << EOF
    row, col = $curwin.cursor

    line  = $curbuf.line
    links = line.scan(/\[\[(\w[\w -\/]*)\]\]/).map {|x| x[0]}

    indices = []
    links.each {|l|
      indices << [line.match(l).begin(0), line.match(l).end(0)]
    }

    link = ""
    links.zip(indices) { |l, i|
      if (i[0] - 2<= col) and (col + 2<= i[1]) ## include '[[' and ']]'
        link = l
        break
      end
    }

    VIM::command("let link=\"#{link}\"")
EOF

  return link
endfunction "}}}

