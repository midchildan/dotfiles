"""""""""""""
"  Plugins  "
"""""""""""""
call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'deton/jasegment.vim'
Plug 'fatih/vim-go', {'for': 'go'}
Plug 'junegunn/fzf', {'dir': '~/.local/opt/fzf', 'do': './install'}
Plug 'junegunn/fzf.vim'
Plug 'ledger/vim-ledger', {'for': 'ledger'}
Plug 'lervag/vimtex', {'for': 'tex'}
Plug 'majutsushi/tagbar', {'on': 'TagbarToggle', 'for': 'go'}
Plug 'mhinz/vim-signify'
Plug 'rdnetto/YCM-generator', {'branch': 'stable',
  \ 'on': ['YcmGenerateConfig', 'CCGenerateConfig']}
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'scrooloose/syntastic'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'tomasr/molokai'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'Valloric/YouCompleteMe', {
  \ 'do': './install.py --clang-completer --tern-completer'}
" filetype plugin indent and syntax is handled by plug#end
call plug#end()

"""""""""""""
"  Editing  "
"""""""""""""
set encoding=utf-8
set backspace=indent,eol,start
set expandtab
set shiftwidth=2
set softtabstop=2
set autoindent
set linebreak

""""""""
"  UI  "
""""""""
set colorcolumn=81
set number
set ruler
set showcmd
set cmdheight=1
set laststatus=2
set display=lastline
set showmatch
set wildmenu
set title
set mouse=a
if $TERM =~? '.*-256color' && has('+termguicolors')
  set cursorline
  set termguicolors
  colorscheme molokai
endif

""""""""""""
"  Search  "
""""""""""""
set incsearch
set hlsearch
set ignorecase
set smartcase
set wrapscan

"""""""""""
"  Cache  "
"""""""""""
if !has('nvim')
  set viminfo+=n~/.cache/vim/viminfo
endif
set dir=~/.cache/vim/swap
set backup
set backupdir=~/.cache/vim/backup
set undofile
set undodir=~/.cache/vim/undo
for d in [&dir, &backupdir, &undodir]
  if !isdirectory(d)
    call mkdir(iconv(d, &encoding, &termencoding), 'p')
  endif
endfor

""""""""""
"  Misc  "
""""""""""
" Filetype Recognition "
let g:tex_flavor='latex'
au BufRead,BufNewFile *.cuh setfiletype cuda

" QuickFix "
set grepprg=rg\ --vimgrep\ --hidden
au QuickfixCmdPost [^lA-Z]* cwindow
au QuickfixCmdPost l* lwindow

" FZF "
" See BurntSushi/ripgrep#37
command! -bang -nargs=* Grep
  \ call fzf#vim#grep('rg --vimgrep --color=always '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)

" EasyMotion"
let g:EasyMotion_use_migemo=1

" Syntastic "
let g:syntastic_always_populate_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0
let g:syntastic_go_checkers=['golint', 'govet', 'errcheck']
let g:syntastic_mode_map={'mode': 'active', 'passive_filetypes': ['go']}

" UltiSnips "
let g:UltiSnipsExpandTrigger='<C-x><C-j>'
let g:UltiSnipsSnippetsDir='~/.vim/after/UltiSnips'

" YouCompleteMe "
let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]
let g:ycm_key_invoke_completion=''
let g:ycm_global_ycm_extra_conf='~/.vim/ycm_extra_conf.py'
