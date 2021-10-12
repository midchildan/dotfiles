setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
if executable('black')
  setlocal formatprg=black\ --quiet\ -
elseif executable('yapf')
  setlocal formatprg=yapf
endif
