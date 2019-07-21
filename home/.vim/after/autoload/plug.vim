if has('*plug#begin')
  finish
endif

func plug#begin(...)
  let s:count = 0
endf

func plug#end()
  if v:vim_did_enter
    return
  endif

  filetype plugin indent on
  if !exists('g:syntax_on')
    syntax enable
  endif

  autocmd VimEnter * echom '[WARN] vim-plug not present'
    \ . printf(' (%d plugins not loaded)', s:count)
endf

func plug#(...)
  let s:count += 1
endf

command -nargs=+ -bar Plug call plug#(<args>)
