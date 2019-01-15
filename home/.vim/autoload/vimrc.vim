func! s:uniq(list)
  let l:visited={}
  for item in a:list
    let l:visited[item] = 1
  endfor
  return keys(l:visited)
endf

func! vimrc#refresh()
  if exists(':SignifyRefresh')
    SignifyRefresh
  endif
  diffupdate
  syntax sync fromstart
  redraw!
endf

func! vimrc#fzf_compilers(is_buffer, bang)
  let l:compilers = split(globpath(&rtp, "compiler/*.vim"), "\n")
  if has('packages')
    let l:compilers += split(globpath(&packpath, "pack/*/opt/*/compiler/*.vim"), "\n")
  endif
  return fzf#run(fzf#wrap('compilers', {
  \ 'source':  s:uniq(map(l:compilers, "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')")),
  \ 'sink':    a:is_buffer ? 'compiler' : 'compiler!',
  \ 'options': a:is_buffer ? '+m --prompt="BCompilers> "' : '+m --prompt="Compilers> "'
  \}, a:bang))
endf

func! vimrc#toggle_show_whitespace()
  if &list
    if exists(':IndentLinesDisable')
      IndentLinesDisable
    endif
    setlocal nolist nocursorcolumn list?
  else
    IndentLinesEnable
    setlocal list cursorcolumn list?
  endif
endf

func! vimrc#toggle_recursive_path()
  if index(split(&path, ','), '**') >= 0
    set path-=** path?
  else
    set path+=** path?
  endif
endf

func! vimrc#toggle_textwidth()
  if !exists('s:textwidth')
    let s:textwidth=80
  endif

  if &textwidth
    let s:textwidth = &textwidth
    let &textwidth = 0
  else
    let &textwidth = s:textwidth
  endif

  set textwidth?
endf

func! vimrc#toggle_virtualedit()
  if empty(&virtualedit)
    set virtualedit=all virtualedit?
  else
    set virtualedit= virtualedit?
  endif
endf
