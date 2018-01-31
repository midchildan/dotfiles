" save commit message to register l (l:last)
func! s:save_commitmsg()
  let @l=''
  silent! keepmarks keepjumps keeppatterns g/\v(^$)|^([^#].*$)/y L
  let @l=@l[1:]
endf

augroup vimrc_gitcommit
  autocmd!
  au BufWritePost COMMIT_EDITMSG silent call <SID>save_commitmsg()
augroup END
