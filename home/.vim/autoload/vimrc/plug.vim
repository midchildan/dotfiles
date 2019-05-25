func! vimrc#plug#go(info)
  if !executable('go')
    return
  endif

  GoInstallBinaries
endf

func! vimrc#plug#ycm(info)
  let completers = {
        \ 'cmake' : '--clang-completer',
        \ 'cargo' : '--rust-completer',
        \ 'mono' : '--cs-completer',
        \ 'npm' : '--ts-completer',
        \ }

  let args = [ './install.py' ]
  for [cmd, flag] in items(completers)
    if executable(cmd)
      call add(args, flag)
    endif
  endfor

  !/usr/libexec/java_home -V >/dev/null 2>&1
  if !v:shell_error
    call add(args, '--java-completer')
  endif

  execute "!" . join(args)
endf
