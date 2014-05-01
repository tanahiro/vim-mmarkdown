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

    file_name = File.basename(link).gsub(/ /, '\\ ') + '.mmd'
    dir_name  = File.dirname(link).gsub(/ /, '\\ ')

    unless link == ""
      VIM::command("let dir='#{dir_name}'")
      VIM::command("let file='#{file_name}'")
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
    col += 1 ## value is different from return value of col('.')

    line  = $curbuf.line
    regexp = /\[\[([[:alpha:][:digit:]][[:alpha:][:digit:] -\.\/]*)\]\]/
    links = []
    line.scan(regexp) {|match| links << [match[0], $~.begin(0), $~.end(0)] }

    link = ""
    links.each {|l|
      link_begin = line[0..l[1]].bytesize
      link_end   = line[0..l[2]].bytesize - 1
      if (link_begin <= col) and (col <= link_end)  ## including '[[' and ']]'
        link = l[0]
        break
      end
    }

    VIM::command("let link=\"#{link}\"")
EOF

  return link
endfunction "}}}

