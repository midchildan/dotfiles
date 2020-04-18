func! vimrc#plug#ycm(info)
  let completers = {
        \ 'cmake' : '--clangd-completer',
        \ 'cargo' : '--rust-completer',
        \ 'go' : '--go-completer',
        \ 'javac' : '--java-completer',
        \ 'mono' : '--cs-completer',
        \ 'npm' : '--ts-completer',
        \ }

  let args = [ './install.py' ]
  for [cmd, flag] in items(completers)
    if executable(cmd)
      call add(args, flag)
    endif
  endfor

  execute "!" . join(args)
endf
