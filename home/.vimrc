" plugins
call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'LaTeX-Box-Team/LaTeX-Box', {'for': ['tex', 'plaintex']}
Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
Plug 'mileszs/ack.vim', {'on': 'Ack'}
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'scrooloose/syntastic'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'tomasr/molokai'
Plug 'tpope/vim-surround'
Plug 'Valloric/YouCompleteMe', {
  \ 'do': './install.py --clang-completer --gocode-completer'}
call plug#end()

" editing
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set backspace=indent,eol,start
set autoindent
set smartindent
filetype plugin indent on

" UI
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

" search
set incsearch
set hlsearch
set ignorecase
set smartcase
set wrapscan

" backup
set dir=~/.vim/tmp
set backup
set backupdir=~/.vim/tmp
set undofile
set undodir=~/.vim/tmp

" syntastic
let g:syntastic_always_populate_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0

" youcompleteme
let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]
let g:ycm_key_invoke_completion=''
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_global_ycm_extra_conf='~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
