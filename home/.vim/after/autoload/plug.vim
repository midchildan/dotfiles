if has('*plug#begin')
  finish
endif

autocmd VimEnter * echom '[WARN] vim-plug not installed'

func plug#begin(...)
endf

func plug#end()
endf

func plug#(...)
endf

command -nargs=+ -bar Plug call plug#(<args>)
