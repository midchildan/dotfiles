"""""""""""""
"  conceal  "
"""""""""""""
let g:tex_conceal='adbmgs'
setlocal conceallevel=2

""""""""""""
"  vimtex  "
""""""""""""
let g:vimtex_fold_enabled=1
let g:vimtex_fold_manual=0
let g:vimtex_quickfix_mode=0
let g:vimtex_compiler_engine='_'
let g:vimtex_compiler_latexmk_engines = {
  \ '_' : '',
  \ 'platex' : '-pdfdvi',
  \ 'uplatex' :  '-pdfdvi',
  \ }
if has('nvim') && !has('clientserver')
  let g:vimtex_compiler_progname='nvr'
endif

if isdirectory('/Applications/Skim.app')
  let g:vimtex_view_method='skim'
endif
