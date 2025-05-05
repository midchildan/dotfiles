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
