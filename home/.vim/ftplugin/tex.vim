"""""""""""""
"  conceal  "
"""""""""""""
let g:tex_conceal='adbmgs'
setlocal conceallevel=2
hi Conceal guibg=black guifg=cyan

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

if executable('zathura')
  let g:vimtex_view_method = 'zathura'
elseif executable('okular')
  let g:vimtex_view_general_viewer = 'okular'
  let g:vimtex_view_general_options = '--unique @pdf\#src:@line@tex'
  let g:vimtex_view_general_options_latexmk = '--unique'
endif

if !exists('g:ycm_semantic_triggers')
  let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers.tex = [
  \ 're!\\[A-Za-z]*cite[A-Za-z]*(\[[^]]*\]){0,2}{[^}]*',
  \ 're!\\[A-Za-z]*ref({[^}]*|range{([^,{}]*(}{)?))',
  \ 're!\\hyperref\[[^]]*',
  \ 're!\\includegraphics\*?(\[[^]]*\]){0,2}{[^}]*',
  \ 're!\\(include(only)?|input){[^}]*',
  \ 're!\\\a*(gls|Gls|GLS)(pl)?\a*(\s*\[[^]]*\]){0,2}\s*\{[^}]*',
  \ 're!\\includepdf(\s*\[[^]]*\])?\s*\{[^}]*',
  \ 're!\\includestandalone(\s*\[[^]]*\])?\s*\{[^}]*']
