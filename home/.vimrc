"NeoBundle Scripts-----------------------------
if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Add or remove your Bundles here:
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'msanders/snipmate.vim'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'tomasr/molokai'
NeoBundleLazy 'LaTeX-Box-Team/LaTeX-Box', {
			\ 'autoload':{ 'filetypes':[ 'tex', 'plaintex' ]}
			\ }

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-------------------------"Bundles

"editing
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set backspace=indent,eol,start
set autoindent
set smartindent

"UI
set colorcolumn=81
set number
set ruler
set showcmd
set cmdheight=1
set laststatus=2
set display=lastline
set showmatch
set wildmenu
set mouse=a
syntax enable

"search
set incsearch
set hlsearch
set ignorecase
set smartcase
set wrapscan

"backup
set dir=$HOME/.vim/tmp
set backup
set backupdir=$HOME/.vim/tmp
set undofile
set undodir=$HOME/.vim/tmp

" syntastic
let g:syntastic_always_populate_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0
