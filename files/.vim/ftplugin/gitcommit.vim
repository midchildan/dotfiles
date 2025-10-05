" save commit message to register g
func! s:save_commitmsg()
  let @g=''
  silent! keepmarks keepjumps keeppatterns g/\v(^$)|^([^#].*$)/y G
  let @g=@g[1:]
endf

augroup vimrc_gitcommit
  autocmd!
  au BufWritePost COMMIT_EDITMSG silent call <SID>save_commitmsg()
augroup END
