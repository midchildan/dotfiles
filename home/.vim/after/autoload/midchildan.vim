function! s:uniq(list)
  let visited={}
  for item in a:list
    let visited[item] = 1
  endfor
  return keys(visited)
endfunction

function! midchildan#fzf_compilers(is_buffer, bang)
  let compilers = split(globpath(&rtp, "compiler/*.vim"), "\n")
  if has('packages')
    let compilers += split(globpath(&packpath, "pack/*/opt/*/compiler/*.vim"), "\n")
  endif
  return fzf#run(fzf#wrap('compilers', {
  \ 'source':  s:uniq(map(compilers, "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')")),
  \ 'sink':    a:is_buffer ? 'compiler' : 'compiler!',
  \ 'options': a:is_buffer ? '+m --prompt="BCompilers> "' : '+m --prompt="Compilers> "'
  \}, a:bang))
endfunction
