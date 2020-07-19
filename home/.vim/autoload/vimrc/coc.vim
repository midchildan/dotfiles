func! s:should_trigger_completion() abort
  let col = col('.') - 1
  return col && getline('.')[col - 1] !~# '\s'
endf

func! vimrc#coc#tab() abort
  if pumvisible()
    let selected = exists('*complete_info') ? complete_info()['selected'] : 1
    return (selected == -1) ? "\<Down>\<C-y>" : "\<C-y>"
  elseif coc#expandableOrJumpable()
    return "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>"
  elseif s:should_trigger_completion()
    return coc#refresh()
  endif
  return "\<Tab>"
endf
