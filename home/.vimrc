" plugins
call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'fatih/vim-go', {'for': 'go'}
Plug 'ledger/vim-ledger', {'for': 'ledger'}
Plug 'lervag/vimtex', {'for': 'tex'}
Plug 'majutsushi/tagbar', {'on': 'TagbarToggle', 'for': 'go'}
Plug 'mileszs/ack.vim', {'on': 'Ack'}
Plug 'rdnetto/YCM-generator', {'branch': 'stable',
  \ 'on': ['YcmGenerateConfig', 'CCGenerateConfig']}
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'scrooloose/syntastic'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'tomasr/molokai'
Plug 'tpope/vim-surround'
Plug 'Valloric/YouCompleteMe', {
  \ 'do': './install.py --clang-completer --tern-completer'}
" filetype plugin indent and syntax is handled by plug#end
call plug#end()

" editing
set encoding=utf-8
set backspace=indent,eol,start
set expandtab
set shiftwidth=2
set softtabstop=2
set autoindent

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

" search
set incsearch
set hlsearch
set ignorecase
set smartcase
set wrapscan

" cache
if !has('nvim')
  set viminfo+=n~/Library/Caches/vim/viminfo
endif
set dir=~/Library/Caches/vim/swap
set backup
set backupdir=~/Library/Caches/vim/backup
set undofile
set undodir=~/Library/Caches/vim/undo

" filetype recognition
let g:tex_flavor='latex'

" syntastic
let g:syntastic_always_populate_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0
let g:syntastic_go_checkers=['golint', 'govet', 'errcheck']
let g:syntastic_mode_map={'mode': 'active', 'passive_filetypes': ['go']}

" ultisnips
let g:UltiSnipsExpandTrigger='<C-x><C-j>'
let g:UltiSnipsSnippetsDir='~/.vim/after/UltiSnips'

" youcompleteme
let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]
let g:ycm_key_invoke_completion=''
let g:ycm_autoclose_preview_window_after_insertion=1
let g:ycm_global_ycm_extra_conf='~/.vim/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
