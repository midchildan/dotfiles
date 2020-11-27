""""""""""""""""""""
"  Initialization  "
""""""""""""""""""""
call plug#begin('~/.vim/plugged')
" editing
Plug 'junegunn/vim-easy-align'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-commentary'
Plug 'machakann/vim-sandwich'
Plug 'easymotion/vim-easymotion', {'on': [
  \ '<Plug>(easymotion-j)', '<Plug>(easymotion-k)',
  \ '<Plug>(easymotion-s2)', '<Plug>(easymotion-overwin-f2)',
  \ '<Plug>(easymotion-sn)', '<Plug>(easymotion-tn)' ]}

" completion and linting
Plug 'w0rp/ale'
Plug '/usr/share/doc/fzf/examples' | Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-snippets'
" XXX: coc-snippets isn't completely compatible w/ UltiSnips snippets
" Run ':CocInstall coc-ultisnips' to show UltiSnips snippets
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" utilities
Plug 'direnv/direnv.vim'
Plug 'tpope/vim-fugitive'
Plug 'machakann/vim-highlightedyank'
Plug 'RRethy/vim-illuminate'
Plug 'junegunn/vim-peekaboo'
Plug 'mhinz/vim-signify'
Plug 'wellle/context.vim', {'on': 'ContextToggle'}
Plug 'junegunn/gv.vim', {'on': 'GV'}
Plug 'Yggdroot/indentLine', {'on': 'IndentLinesEnable'}
Plug 'Yilin-Yang/vim-markbar', {'on': '<Plug>ToggleMarkbar'}
Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTreeFind']}
Plug 'CoatiSoftware/vim-sourcetrail',
\ {'for': ['c', 'cpp', 'cuda', 'java', 'python']}
Plug 'majutsushi/tagbar', {'on': 'TagbarToggle'}
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'

" colorschemes
Plug 'midchildan/molokai'
Plug 'altercation/vim-colors-solarized'

" filetypes
" TODO: Add more coc extensions. For the time being, install w/:CocInstall.
Plug 'midchildan/ft-confluence.vim'
Plug 'ledger/vim-ledger', {'for': 'ledger'}
Plug 'LnL7/vim-nix', {'for': 'nix'}
Plug 'rust-lang/rust.vim', {'for': 'rust'}

" just for fun
Plug 'vim/killersheep', {'on': 'KillKillKill'}

" filetype plugin indent and syntax is handled by plug#end
call plug#end()

augroup vimrc
	  autocmd!
augroup END

"""""""""""""
"  Editing  "
"""""""""""""
set encoding=utf-8
set belloff=all
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932,default,latin1
set fileformats=unix,dos,mac
set backspace=indent,eol,start
set expandtab
set smarttab
set shiftwidth=2
set softtabstop=2
set autoindent
set copyindent
set preserveindent
set formatoptions+=jmB
set omnifunc=syntaxcomplete#Complete


""""""""
"  UI  "
""""""""
" colors
syntax enable
set cursorline
colorscheme molokai

set number
""""""""""""
"  Search  "
""""""""""""
set hlsearch


"""""""""""
"  Cache  "
"""""""""""
set dir=~/.cache/vim/swap//
set backup
set backupdir=~/.cache/vim/backup
set undofile
set undodir=~/.cache/vim/undo
for s:d in [&dir, &backupdir, &undodir]
  if !isdirectory(s:d)
    call mkdir(iconv(s:d, &encoding, &termencoding), 'p')
  endif
endfor

"""""""""""""""""
"  Keybindings  "
"""""""""""""""""


""""""""""
"  Misc  "
""""""""""


