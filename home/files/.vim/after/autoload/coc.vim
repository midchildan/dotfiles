if has('*coc#expandableOrJumpable') || has('*coc#refresh')
  finish
endif

func coc#expandableOrJumpable()
  return 0
endf

func coc#refresh()
  return "\<Tab>"
endf
