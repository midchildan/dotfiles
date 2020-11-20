""""""""""""""""""""
"  Initialization  "
""""""""""""""""""""
call plug#begin()
" colorschemes
Plug 'morhetz/gruvbox'
Plug 'midchildan/molokai'

call plug#end()


"""""""""""""
"  Editing  "
"""""""""""""
set encoding=utf-8



""""""""
"  UI  "
""""""""
" colors
if has('gui_running')
  let s:color_level = 2
elseif &t_Co < 256 && $TERM !~? '.*-256color'
  let s:color_level = 0
elseif !has('termguicolors')
  let s:color_level = 1
else
  let s:color_level = 2
  if !has('nvim') && $TERM =~? 'screen'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif
endif

if s:color_level >=? 2
  set termguicolors
  if exists('+pumblend')
    set pumblend=15 winblend=15
  endif
endif
if s:color_level >=? 1
  set background=dark
  try
    colorscheme gruvbox
    set cursorline
  catch /E185:/ " colorscheme doesn't exist
  endtry
endif

set number
""""""""""""
"  Search  "
""""""""""""


"""""""""""
"  Cache  "
"""""""""""


"""""""""""""""""
"  Keybindings  "
"""""""""""""""""


""""""""""
"  Misc  "
""""""""""


