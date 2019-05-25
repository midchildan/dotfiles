func! vimrc#plug#go(info)
  if !executable('go')
    return
  endif

  GoInstallBinaries
endf
