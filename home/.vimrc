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
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'Valloric/YouCompleteMe', {
  \ 'do': './install.py --clang-completer --tern-completer --racer-completer'}
Plug 'rdnetto/YCM-generator', {'branch': 'stable',
  \ 'on': ['YcmGenerateConfig', 'CCGenerateConfig']}
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" utilities
Plug 'tpope/vim-fugitive'
Plug 'machakann/vim-highlightedyank'
Plug 'junegunn/vim-peekaboo'
Plug 'mhinz/vim-signify'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'

" colorschemes
Plug 'tomasr/molokai'
Plug 'altercation/vim-colors-solarized'

" filetypes
Plug 'fatih/vim-go', {'for': 'go'}
Plug 'ledger/vim-ledger', {'for': 'ledger'}
Plug 'LnL7/vim-nix', {'for': 'nix'}
Plug 'rust-lang/rust.vim', {'for': 'rust'}
Plug 'lervag/vimtex', {'for': 'tex'}

" filetype plugin indent and syntax is handled by plug#end
call plug#end()

if !has('nvim')
  packadd! matchit
  runtime ftplugin/man.vim
endif

augroup vimrc
  autocmd!
augroup END

"""""""""""""
"  Editing  "
"""""""""""""
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932,default,latin1
set fileformats=unix,dos,mac
set backspace=indent,eol,start
set expandtab
set shiftwidth=2
set softtabstop=2
set autoindent
set formatoptions+=jmB

" jump to the last known cursor position
au vimrc BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

" enable brackted paste mode
if !has('nvim') && has('patch-8.0.0238') && $TERM =~? 'screen'
  let &t_BE = "\<Esc>[?2004h"
  let &t_BD = "\<Esc>[?2004l"
  exec "set t_PS=\<ESC>[200~ | set t_PE=\<ESC>[201~"
endif

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
set lazyredraw
set showmatch
set wildmenu
set title
set mouse=a

" colors
if $TERM =~? '.*-256color' && $TERM_PROGRAM !=? 'Apple_Terminal'
  set cursorline
  set termguicolors
  colorscheme molokai
  if !has('nvim') && $TERM =~? 'screen'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif
endif
if exists('+inccommand')
  set inccommand=split
endif

" show whitespace errors
hi link WhitespaceError Error
au vimrc Syntax * syn match WhitespaceError /\s\+$\| \+\ze\t/

""""""""""""
"  Search  "
""""""""""""
set incsearch
set hlsearch
set ignorecase
set smartcase
set wrapscan
set tags=./tags;,tags

"""""""""""
"  Cache  "
"""""""""""
if !has('nvim')
  set viminfo+=n~/Library/Caches/vim/viminfo
endif
set dir=~/Library/Caches/vim/swap
set backup
set backupdir=~/Library/Caches/vim/backup
set undofile
set undodir=~/Library/Caches/vim/undo
for s:d in [&dir, &backupdir, &undodir]
  if !isdirectory(s:d)
    call mkdir(iconv(s:d, &encoding, &termencoding), 'p')
  endif
endfor

"""""""""""""""""
"  Keybindings  "
"""""""""""""""""
let mapleader="\<Space>"
let maplocalleader="\<Space>\<Space>"
" XXX: Workaround for <Nop> bug in vim/vim#1548, neovim/neovim#6241
nnoremap <Space> \
xnoremap <Space> \

" a more logical mapping for Y
nnoremap Y y$
" break undo before deleting a whole line
inoremap <C-u> <C-g>u<C-u>
" a more powerful <C-l>
nnoremap <silent> <Leader><C-l> :nohlsearch<CR>:call vimrc#refresh()<CR>

" find merge conflict marker
nnoremap <silent> <Leader>fc /\v^[<=>]{7}( .*<Bar>$)<CR>
xnoremap <silent> <Leader>fc /\v^[<=>]{7}( .*<Bar>$)<CR>
onoremap <silent> <Leader>fc /\v^[<=>]{7}( .*<Bar>$)<CR>
" find whitespace errors
nnoremap <silent> <Leader>f<Space> /\s\+$\<Bar> \+\ze\t<CR>
xnoremap <silent> <Leader>f<Space> /\s\+$\<Bar> \+\ze\t<CR>
onoremap <silent> <Leader>f<Space> /\s\+$\<Bar> \+\ze\t<CR>

" text objects
xnoremap <silent> ae gg0oG$
onoremap <silent> ae :<C-u>exe "normal! m`"<Bar>keepjumps normal! ggVG<CR>
xnoremap <silent> al <Esc>0v$
onoremap <silent> al :<C-u>normal! 0v$<CR>
xnoremap <silent> il <Esc>^vg_
onoremap <silent> il :<C-u>normal! ^vg_<CR>
" XXX: Same feature as vim/vim#958
xmap im <Plug>(textobj-sandwich-literal-query-i)
omap im <Plug>(textobj-sandwich-literal-query-i)
xmap am <Plug>(textobj-sandwich-literal-query-a)
omap am <Plug>(textobj-sandwich-literal-query-a)

" toggles
nnoremap <silent> <Leader>tf :NERDTreeToggle<CR>
nnoremap <silent> <Leader>th :setlocal bufhidden! bufhidden?<CR>
nnoremap <silent> <Leader>tl :ALEToggle<CR>
nnoremap <silent> <Leader>ts :setlocal spell! spell?<CR>
nnoremap <silent> <Leader>tt :TagbarToggle<CR>
nnoremap <silent> <Leader>tu :UndotreeToggle<CR>
nnoremap <silent> <Leader>tv :call vimrc#toggle_virtualedit()<CR>
nnoremap <silent> <Leader>t# :setlocal relativenumber! relativenumber?<CR>
nnoremap <silent> <Leader>t<Space> :AirlineToggleWhitespace<CR>

" FZF mappings
imap <C-x><C-x><C-f> <Plug>(fzf-complete-path)
imap <C-x><C-x><C-k> <Plug>(fzf-complete-word)
imap <C-x><C-x><C-l> <Plug>(fzf-complete-line)
inoremap <silent> <C-x><C-x><C-j> <Esc>:Snippets<CR>
nnoremap <silent> <Leader>gf :Files<CR>
nnoremap <silent> <Leader>gb :Buffers<CR>
nnoremap <silent> <Leader>g/ :Lines<CR>
nnoremap <silent> <Leader>g<C-]> :Tags <C-r>=expand("<cword>")<CR><CR>
nnoremap <silent> <Leader>q: :History:<CR>
nnoremap <silent> <Leader>q/ :History/<CR>
nnoremap <silent> <Leader>' :Marks<CR>
nnoremap <silent> <Leader>/ :BLines<CR>
nnoremap <silent> <Leader>: :Commands<CR>
nnoremap <silent> <Leader><C-o> :History<CR>
nnoremap <silent> <Leader><C-]> :BTags <C-r>=expand("<cword>")<CR><CR>

" easymotion
nmap <Leader>j <Plug>(easymotion-j)
xmap <Leader>j <Plug>(easymotion-j)
omap <Leader>j <Plug>(easymotion-j)
nmap <Leader>k <Plug>(easymotion-k)
xmap <Leader>k <Plug>(easymotion-k)
omap <Leader>k <Plug>(easymotion-k)
nmap <Leader>s <Plug>(easymotion-s2)
xmap <Leader>s <Plug>(easymotion-s2)
omap <Leader>s <Plug>(easymotion-s2)
nmap <Leader>s <Plug>(easymotion-overwin-f2)
nmap g/ <Plug>(easymotion-sn)
xmap g/ <Plug>(easymotion-sn)
omap g/ <Plug>(easymotion-tn)

" vim-easy-align
nmap g= <Plug>(EasyAlign)
xmap g= <Plug>(EasyAlign)

" vim-sandwich
nmap s <Nop>
xmap s <Nop>

" youcompleteme
nnoremap <silent> <LocalLeader>K :YcmCompleter GetDoc<CR>
nnoremap <silent> <LocalLeader>[i :YcmCompleter GetType<CR>
nnoremap <silent> <LocalLeader><C-]> :YcmCompleter GoTo<CR>

""""""""""
"  Misc  "
""""""""""
let g:tex_flavor='latex'

" See :h :DiffOrig
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
  \ | wincmd p | diffthis

" QuickFix "
au vimrc QuickfixCmdPost [^lA-Z]* botright cwindow
au vimrc QuickfixCmdPost l* botright lwindow

let s:has_rg = executable('rg')
if s:has_rg
  set grepprg=rg\ --vimgrep\ --hidden
endif

" FZF "
command! -bang Compilers
  \ call vimrc#fzf_compilers(0, <bang>0)
command! -bang BCompilers
  \ call vimrc#fzf_compilers(1, <bang>0)
if s:has_rg
  command! -bang -nargs=* Grep
    \ call fzf#vim#grep('rg --vimgrep --color=always '.shellescape(<q-args>), 1, <bang>0)
else
  command! -bang -nargs=* Grep
    \ call fzf#vim#grep('grep -r --line-number '.shellescape(<q-args>).' *', 0, <bang>0)
endif

" EasyMotion"
let g:EasyMotion_do_mapping=0
let g:EasyMotion_smartcase=1
let g:EasyMotion_use_migemo=1

" EditorConfig
let g:EditorConfig_exclude_patterns=['fugitive://.*', '\(M\|m\|GNUm\)akefile']

" UltiSnips "
let g:UltiSnipsExpandTrigger='<C-x><C-j>'

" YouCompleteMe "
let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]
let g:ycm_key_invoke_completion=''
let g:ycm_global_ycm_extra_conf='~/.vim/ycm_extra_conf.py'
let g:ycm_rust_src_path='~/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src'

" airline "
let g:airline_skip_empty_sections=1
if $USE_POWERLINE
  let g:airline_powerline_fonts=1
endif

" undotree "
let g:undotree_WindowLayout=2

" VimR "
if has('gui_vimr')
  source ~/.config/nvim/ginit.vim
endif
