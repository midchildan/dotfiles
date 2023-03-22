func! s:should_trigger_completion() abort
  let col = col('.') - 1
  return col && getline('.')[col - 1] !~# '\s'
endf

func! vimrc#coc#cr() abort
  if exists('*coc#on_enter')
    return "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"
  endif

  return "\<CR>"
endf

func! vimrc#coc#confirm_completion(fallback) abort
  if exists('*coc#pum#visible') && coc#pum#visible()
    return coc#pum#confirm()
  endif

  return a:fallback
endf

func! vimrc#coc#cycle_completion(fallback, is_forwards) abort
  if !exists('*coc#pum#visible')
    return a:fallback
  elseif coc#pum#visible()
    return a:is_forwards ? coc#pum#next(1) : coc#pum#prev(1)
  elseif s:should_trigger_completion()
    return coc#refresh()
  endif

  return a:fallback
endf

func! vimrc#coc#scroll_up(fallback) abort
  if exists('*coc#float#has_scroll') && coc#float#has_scroll()
    return coc#float#scroll(0)
  endif

  return a:fallback
endf

func! vimrc#coc#scroll_down(fallback) abort
  if exists('*coc#float#has_scroll') && coc#float#has_scroll()
    return coc#float#scroll(1)
  endif

  return a:fallback
endf

func! vimrc#coc#i_scroll_up(fallback) abort
  if exists('*coc#float#has_scroll') && coc#float#has_scroll()
    return "\<C-r>=coc#float#scroll(0)\<CR>"
  endif

  return a:fallback
endf

func! vimrc#coc#i_scroll_down(fallback) abort
  if exists('*coc#float#has_scroll') && coc#float#has_scroll()
    return "\<C-r>=coc#float#scroll(1)\<CR>"
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
