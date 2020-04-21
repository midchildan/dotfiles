""""""""""""""""""""
"  Initialization  "
""""""""""""""""""""
set nocompatible
filetype plugin indent on
syntax enable

if exists(':packadd') ==# 2
  silent! packadd! cfilter
endif
if !has('nvim')
  runtime macros/matchit.vim
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
set smarttab
set shiftwidth=2
set softtabstop=2
set autoindent
set copyindent
set preserveindent
set formatoptions+=jmB
set omnifunc=syntaxcomplete#Complete

" jump to the last known cursor position
au vimrc BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

" enable bracketed paste mode
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
set listchars=tab:>\ ,trail:-,nbsp:+
set cmdheight=1
set laststatus=2
set display=lastline
set lazyredraw
set showmatch
set wildmenu
set wildignorecase
set nofoldenable
set title
set mouse=a
set path+=** " XXX: substitute for fuzzy finders

" cursor shape
if !has('nvim') && $TERM =~? '\(xterm\|screen\)'
  let &t_SI = "\<Esc>[6 q"
  let &t_EI = "\<Esc>[2 q"
  if exists('+t_SR')
    let &t_SR = "\<Esc>[4 q"
  endif
endif

if exists('+inccommand')
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
set tags=./tags;,tags

"""""""""""
"  Cache  "
"""""""""""
" XXX: Backups and undofiles are disabled, as it is sometimes undesirable on a
"      remote environment.
set nobackup
set noundofile

"""""""""""""""""
"  Keybindings  "
"""""""""""""""""
let mapleader="\<Space>"
let maplocalleader="\<CR>"
" XXX: Workaround for <Nop> bug in vim/vim#1548, neovim/neovim#6241
nnoremap <Space> \
xnoremap <Space> \

" make Y consistent with C and D
nnoremap Y y$
" make & preserve flags and create a visual mode equivalent
nnoremap & :&&<CR>
xnoremap & :&&<CR>
" break undo before deleting a whole line
inoremap <C-u> <C-g>u<C-u>
" a more powerful <C-l>
nnoremap <silent> <Leader><C-l> :noh<CR>:dif<CR>:syn sync fromstart<CR>:redr!<CR>

" find merge conflict marker
nnoremap <silent> <Leader>fc /\v^[<=>]{7}( .*<Bar>$)<CR>
xnoremap <silent> <Leader>fc /\v^[<=>]{7}( .*<Bar>$)<CR>
onoremap <silent> <Leader>fc /\v^[<=>]{7}( .*<Bar>$)<CR>
" find whitespace errors
nnoremap <silent> <Leader>f<Space> /\s\+$\<Bar> \+\ze\t<CR>
xnoremap <silent> <Leader>f<Space> /\s\+$\<Bar> \+\ze\t<CR>
onoremap <silent> <Leader>f<Space> /\s\+$\<Bar> \+\ze\t<CR>
" find full-width punctuation marks
nnoremap <silent> <Leader>f. /\v(\.<Bar>．<Bar>。)<CR>
xnoremap <silent> <Leader>f. /\v(\.<Bar>．<Bar>。)<CR>
onoremap <silent> <Leader>f. /\v(\.<Bar>．<Bar>。)<CR>
nnoremap <silent> <Leader>f, /\v(,<Bar>，<Bar>、)<CR>
xnoremap <silent> <Leader>f, /\v(,<Bar>，<Bar>、)<CR>
onoremap <silent> <Leader>f, /\v(,<Bar>，<Bar>、)<CR>
nnoremap <silent> <Leader>f! /\v(!<Bar>！)<CR>
xnoremap <silent> <Leader>f! /\v(!<Bar>！)<CR>
onoremap <silent> <Leader>f! /\v(!<Bar>！)<CR>
nnoremap <silent> <Leader>f? /\v(\?<Bar>？)<CR>
xnoremap <silent> <Leader>f? /\v(\?<Bar>？)<CR>
onoremap <silent> <Leader>f? /\v(\?<Bar>？)<CR>

" text objects
xnoremap <silent> al <Esc>0v$
onoremap <silent> al :<C-u>normal! 0v$<CR>
xnoremap <silent> il <Esc>^vg_
onoremap <silent> il :<C-u>normal! ^vg_<CR>
xnoremap <silent> a, gg0oG$
onoremap <silent> a, :<C-u>exe "normal! m`"<Bar>keepjumps normal! ggVG<CR>

" toggles
nnoremap <silent> <Leader>th :setlocal bufhidden! bufhidden?<CR>
nnoremap <silent> <Leader>ts :setlocal spell! spell?<CR>
nnoremap <silent> <Leader>t# :setlocal relativenumber! relativenumber?<CR>
nnoremap <silent> <Leader>t~ :set ignorecase! ignorecase?<CR>

" 3-way merge
nnoremap <silent> <Leader>1 :diffget LOCAL<CR>
nnoremap <silent> <Leader>2 :diffget BASE<CR>
nnoremap <silent> <Leader>3 :diffget REMOTE<CR>

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
