func! vimrc#plug#go(info)
  if !executable('go')
    return
  endif

  if a:info.status != 'unchanged' || a:info.force
    GoInstallBinaries
  endif
endf
