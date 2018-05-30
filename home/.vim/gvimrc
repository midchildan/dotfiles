" set PATH
let s:path=system("source ~/.zshrc; echo echo VIMPATH'${PATH}' | $SHELL")
let $PATH=matchstr(s:path, 'VIMPATH\zs.\{-}\ze\n')

set termguicolors
set cmdheight=1
set cursorline
set confirm

if has('gui_macvim')
  set lines=40
  set columns=120
  set guifont=Menlo\ Regular:h14
  set guitablabel=%M%t
  set guioptions-=T
  set transparency=15
endif

colorscheme molokai
