" set PATH
let s:path=system("source ~/.zshrc; echo echo VIMPATH'${PATH}' | $SHELL")
let $PATH=matchstr(s:path, 'VIMPATH\zs.\{-}\ze\n')

set lines=40
set columns=120
set cmdheight=1
set cursorline
set guifont=Monospace\ 13
set guitablabel=%M%t
set guioptions-=T
set confirm
colorscheme molokai
