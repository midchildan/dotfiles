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

func! vimrc#toggle_recursive_path()
  if index(split(&path, ','), '**') >= 0
    set path-=** path?
  else
    set path+=** path?
  endif
endf

func! vimrc#toggle_virtualedit()
  if empty(&virtualedit)
    set virtualedit=all virtualedit?
  else
    set virtualedit= virtualedit?
  endif
endf
