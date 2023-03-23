func! vimrc#coc#cr() abort
  if exists('*coc#on_enter')
    return "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"
  endif

  return "\<CR>"
endf

func! vimrc#coc#complete_or(fallback) abort
  if !exists('*coc#pum#visible') || coc#pum#visible()
    return a:fallback
  endif

  let col = col('.') - 1
  if col && getline('.')[col - 1] !~# '\s'
    return coc#refresh()
  endif

  return a:fallback
endf

func! vimrc#coc#n_float_scroll_or(fallback, is_down) abort
  if exists('*coc#float#has_scroll') && coc#float#has_scroll()
    return coc#float#scroll(a:is_down)
  endif

  return a:fallback
endf

func! vimrc#coc#i_float_scroll_or(fallback, is_down) abort
  if exists('*coc#float#has_scroll') && coc#float#has_scroll()
    return "\<C-r>=coc#float#scroll(" . a:is_down . ")\<CR>"
  endif

  return a:fallback
endf

func! vimrc#coc#show_doc()
  if exists('*CocAction') && CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endf
