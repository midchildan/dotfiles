setlocal noexpandtab
setlocal tabstop=4
setlocal shiftwidth=4

if executable('gofmt')
  setlocal formatprg=gofmt
endif
