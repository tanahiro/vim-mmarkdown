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

  ## File name and dir name
  html_filename = VIM::evaluate("mmarkdown#base#html_file_name()")

  ## Parse markdown
  md_string = File.open(VIM::Buffer.current.name).read
  ## placeholder
  md_header = {}
  md_header_regexp =
    /^\s*%(title|template)\s+([\s[:alpha:][:digit:]#-\/_+]*?)\n/
  md_string.lines[0..9].each {|line|
    if match = md_header_regexp.match(line)
      md_header[match[1]] = match[2].chomp
    end

    if match = /^%toc\s*([1-6]?$)/.match(line)
      md_header["toc"] = match[1].chomp
      md_string.gsub!(/^%toc\s*([1-6]?$)/, '')
    end
  }
  md_string.gsub!(md_header_regexp, '')
  ## wiki link
  wiki_link_regexp =
    /\[\[([[:alpha:][:digit:]][[:alpha:][:digit:] ,\[\]=_\+-\.\/]*)\]\]/
  md_string.gsub!(wiki_link_regexp, '[\1](\1.html)')

  mmarkdown = MMarkdown.new(md_string)

  html_string = mmarkdown.to_str

  html_dirname = File.dirname(html_filename)
  unless Dir.exists?(html_dirname)
    require 'fileutils'
    FileUtils.mkdir_p(html_dirname)
  end

  File.open(html_filename, 'w') {|f|
    if md_header["template"]
      template_dir = File.join(VIM::evaluate("g:mmarkdown_workdir"), "template")

      if Dir.exists?(template_dir)
        template_file =
          File.join(template_dir, md_header["template"] + ".html")

        if File.exists?(template_file)
          File.open(template_file, 'r') {|tmplt|
            tmplt_html = tmplt.read

            tmplt_html.gsub!('%title%', md_header["title"])

            if md_header["toc"]
              toc_level = md_header["toc"].to_i
              unless (1 <= toc_level and toc_level <= 6)
                toc_level = 3
              end

              html_toc  = "<div class='toc'>\n"
              html_toc += "<h1>Table of Contents</h1>\n"
              html_toc += mmarkdown.toc_html(toc_level)
              html_toc += "</div>"
              tmplt_html.gsub!('%toc%', html_toc)
            else
              tmplt_html.gsub!('%toc%', '')
            end

            tmplt_html.gsub!('%content%', html_string)

            f.write(tmplt_html)
          }
        else
          VIM::message("couldn't find the template file")
        end
      else
        VIM::message("couldn't find the template directory")
      end
    else
      f.write(html_string)
    end
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
    wiki_link_regexp =
      /\[\[([[:alpha:][:digit:]][[:alpha:][:digit:] ,\[\]=_\+-\.\/]*)\]\]/
    links = []
    line.scan(wiki_link_regexp) {|match|
      links << [match[0], $~.begin(0), $~.end(0)]
    }

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

function! mmarkdown#base#html_file_name() "{{{
  let html_filename = ""

  ruby << EOF
  mmd_filename  = VIM::Buffer.current.name
  mmd_dirname   =
    File.dirname(mmd_filename.gsub(VIM::evaluate("g:mmarkdown_workdir"), ""))

  html_dirname = File.join(VIM::evaluate("g:mmarkdown_html_dir"), mmd_dirname)

  html_filename =
    File.join(html_dirname,
              File.basename(mmd_filename.gsub(/\.mmd\Z/, ".html")))
  VIM::command("let html_filename=\"#{html_filename}\"")
EOF
  return html_filename
endfunction "}}}

function! mmarkdown#base#selected_part_to_html() range "{{{
  let str=""
  let html=""
  for linenum in range(a:firstline, a:lastline)
    let str .= getline(linenum)
    let str .= "\n"
  endfor

  ruby << EOF
  require 'mmarkdown'

  str = VIM::evaluate("str").force_encoding('utf-8')
  html = MMarkdown.new(str).to_str
  html.gsub!("\"", "\\\"")

  VIM::command("let html=\"#{html}\"")
EOF
  redir @+>
  silent execute "echo html"
  redir END
endfunction "}}}

function! mmarkdown#base#open_html(filename) "{{{
  let html_filename = ""

  if a:filename == ""
    let html_filename = mmarkdown#base#html_file_name()
  else
    let html_filename = a:html_filename
  endif

  silent execute ":!".g:mmarkdown_viewer." ".html_filename

endfunction "}}}

