"""""""""""""
"  Plugins  "
"""""""""""""
call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'fatih/vim-go', {'for': 'go'}
Plug 'junegunn/fzf', {'dir': '~/.local/opt/fzf', 'do': '~/.local/libexec/fzf/install'}
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-peekaboo'
Plug 'ledger/vim-ledger', {'for': 'ledger'}
Plug 'lervag/vimtex', {'for': 'tex'}
Plug 'LnL7/vim-nix', {'for': 'nix'}
Plug 'majutsushi/tagbar'
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
Plug 'mhinz/vim-signify'
Plug 'rdnetto/YCM-generator', {'branch': 'stable',
  \ 'on': ['YcmGenerateConfig', 'CCGenerateConfig']}
Plug 'rust-lang/rust.vim', {'for': 'rust'}
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'tomasr/molokai'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'Valloric/YouCompleteMe', {
  \ 'do': './install.py --clang-completer --tern-completer --racer-completer'}
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
Plug 'w0rp/ale'
" filetype plugin indent and syntax is handled by plug#end
call plug#end()

if !has('nvim')
  packadd! matchit
  runtime ftplugin/man.vim
endif

"""""""""""""
"  Editing  "
"""""""""""""
set encoding=utf-8
set backspace=indent,eol,start
set expandtab
set shiftwidth=2
set softtabstop=2
set autoindent

" swap leader key (\) and space
let mapleader="\<Space>"
noremap \ <Space>

""""""""
"  UI  "
""""""""
set colorcolumn=81
set number
set ruler
set showcmd
set noshowmode
set cmdheight=1
set laststatus=2
set display=lastline
set showmatch
set wildmenu
set title
set mouse=a
if $TERM =~? '.*-256color' && has('termguicolors')
  set cursorline
  set termguicolors
  colorscheme molokai
  if !has('nvim') && $TERM ==? 'screen-256color'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif
endif
if has('nvim')
  set inccommand=split
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
let g:tex_flavor='latex'

" QuickFix "
au QuickfixCmdPost [^lA-Z]* botright cwindow
au QuickfixCmdPost l* botright lwindow
if executable('rg')
  set grepprg=rg\ --vimgrep\ --hidden
endif

" FZF "
command! -bang -nargs=* Grep
  \ call fzf#vim#grep('rg --vimgrep --color=always '.shellescape(<q-args>), 1, <bang>0)

" EasyMotion"
let g:EasyMotion_use_migemo=1

" UltiSnips "
let g:UltiSnipsExpandTrigger='<C-x><C-j>'
let g:UltiSnipsSnippetsDir='~/.vim/after/UltiSnips'

" YouCompleteMe "
let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]
let g:ycm_key_invoke_completion=''
let g:ycm_global_ycm_extra_conf='~/.vim/ycm_extra_conf.py'
let g:ycm_rust_src_path='~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src'

" airline "
let g:airline_skip_empty_sections=1
if $USE_POWERLINE
  let g:airline_powerline_fonts=1
endif

" undotree "
let g:undotree_WindowLayout=2
